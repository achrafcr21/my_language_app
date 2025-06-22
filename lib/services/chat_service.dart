import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/language_analysis_service.dart';

class ChatService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String? _apiKey = dotenv.env['OPENAI_API_KEY'];
  final List<Map<String, String>> _conversationHistory = [];
  String _currentLevel = 'B2';
  String _currentLanguage = 'en';
  bool _isInitialized = false;
  
  // Stream controller para notificar cambios en los mensajes
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  List<ChatMessage> _messages = [];

  final LanguageAnalysisService _languageAnalysis = LanguageAnalysisService();

  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal() {
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar nivel y lenguaje
      _currentLevel = prefs.getString('current_level') ?? 'B2';
      _currentLanguage = prefs.getString('current_language') ?? 'en';
      
      // Cargar mensajes
      final messagesJson = prefs.getString('messages');
      if (messagesJson != null) {
        final List<dynamic> decoded = json.decode(messagesJson);
        _messages = decoded.map((item) {
          try {
            return ChatMessage.fromJson(item);
          } catch (e) {
            print('Error parsing message: $e');
            return ChatMessage(
              content: 'Error loading message',
              isUser: false,
              timestamp: DateTime.now(),
              hasError: true,
            );
          }
        }).toList();
        _messagesController.add(_messages);
      }
      
      // Cargar historial de conversación para ChatGPT
      final history = prefs.getStringList('chat_history');
      if (history != null) {
        _conversationHistory.clear();
        for (var item in history) {
          try {
            final map = json.decode(item) as Map<String, dynamic>;
            _conversationHistory.add(map.cast<String, String>());
          } catch (e) {
            print('Error parsing chat history: $e');
          }
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar mensajes válidos
      final validMessages = _messages.where((msg) => msg.content.isNotEmpty).toList();
      await prefs.setString('messages', json.encode(
        validMessages.map((msg) => msg.toJson()).toList()
      ));
      
      // Guardar historial de conversación
      final validHistory = _conversationHistory.where((map) => 
        map.containsKey('role') && map.containsKey('content') &&
        map['content']!.isNotEmpty
      ).toList();
      await prefs.setStringList('chat_history',
        validHistory.map((map) => json.encode(map)).toList()
      );
      
      // Guardar configuración
      await prefs.setString('current_level', _currentLevel);
      await prefs.setString('current_language', _currentLanguage);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  void addMessage(ChatMessage message) {
    if (message.content.isEmpty) return;
    
    _messages.add(message);
    _messagesController.add(_messages);
    _saveChatHistory();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(userMessage);

    try {
      // Analizar el nivel de lenguaje del usuario
      final analysis = await _languageAnalysis.analyzeUserInput(content);
      
      // Preparar el contexto para la API
      final systemPrompt = '''Eres un tutor de idiomas amigable y paciente. 
El estudiante tiene un nivel ${analysis.level}. 
Fortalezas: ${analysis.strengths.join(', ')}
Áreas a mejorar: ${analysis.areasToImprove.join(', ')}
Ajusta tus respuestas a su nivel y enfócate en ayudarle a mejorar.''';

      _conversationHistory.add({
        'role': 'system',
        'content': systemPrompt,
      });

      _conversationHistory.add({
        'role': 'user',
        'content': content,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': _conversationHistory,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiContent = data['choices'][0]['message']['content'] as String;

        if (aiContent.isNotEmpty) {
          _conversationHistory.add({
            'role': 'assistant',
            'content': aiContent,
          });

          // Sugerir temas de práctica basados en el análisis
          final suggestedTopics = _languageAnalysis.getSuggestedTopics();
          
          final aiMessage = ChatMessage(
            content: aiContent,
            isUser: false,
            timestamp: DateTime.now(),
            quickReplies: suggestedTopics,
          );
          addMessage(aiMessage);
        } else {
          throw Exception('Empty response from API');
        }
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      addMessage(ChatMessage(
        content: 'Lo siento, ha ocurrido un error. Por favor, intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
        hasError: true,
      ));
    }
  }

  Stream<ChatMessage> sendMessageStream(String content) async* {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(userMessage);

    try {
      // Analizar el nivel de lenguaje del usuario
      final analysis = await _languageAnalysis.analyzeUserInput(content);
      
      // Preparar el contexto para la API
      final systemPrompt = '''Eres un tutor de idiomas amigable y paciente. 
El estudiante tiene un nivel ${analysis.level}. 
Fortalezas: ${analysis.strengths.join(', ')}
Áreas a mejorar: ${analysis.areasToImprove.join(', ')}
Ajusta tus respuestas a su nivel y enfócate en ayudarle a mejorar.''';

      _conversationHistory.add({
        'role': 'system',
        'content': systemPrompt,
      });

      _conversationHistory.add({
        'role': 'user',
        'content': content,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': _conversationHistory,
          'temperature': 0.7,
          'max_tokens': 1000,
          'stream': true,
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        String accumulatedContent = '';

        for (var line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            try {
              final data = json.decode(line.substring(6));
              final content = data['choices'][0]['delta']['content'] as String?;
              
              if (content != null && content.isNotEmpty) {
                accumulatedContent += content;
                yield ChatMessage(
                  content: accumulatedContent,
                  isUser: false,
                  timestamp: DateTime.now(),
                );
              }
            } catch (e) {
              print('Error parsing streaming response: $e');
            }
          }
        }

        if (accumulatedContent.isNotEmpty) {
          _conversationHistory.add({
            'role': 'assistant',
            'content': accumulatedContent,
          });
          
          // Sugerir temas de práctica basados en el análisis
          final suggestedTopics = _languageAnalysis.getSuggestedTopics();
          
          final finalMessage = ChatMessage(
            content: accumulatedContent,
            isUser: false,
            timestamp: DateTime.now(),
            quickReplies: suggestedTopics,
          );
          addMessage(finalMessage);
        }
      } else {
        throw Exception('Failed to get streaming response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in message stream: $e');
      yield ChatMessage(
        content: 'Lo siento, ha ocurrido un error. Por favor, intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
        hasError: true,
      );
    }
  }

  void clearHistory() {
    _messages.clear();
    _conversationHistory.clear();
    _messagesController.add(_messages);
    _saveChatHistory();
  }

  @override
  void dispose() {
    _messagesController.close();
  }
}
