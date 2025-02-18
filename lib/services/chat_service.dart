import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        _messages = decoded.map((item) => ChatMessage.fromJson(item)).toList();
        _messagesController.add(_messages);
      }
      
      // Cargar historial de conversación para ChatGPT
      final history = prefs.getStringList('chat_history');
      if (history != null) {
        _conversationHistory.clear();
        for (var item in history) {
          final map = json.decode(item) as Map<String, dynamic>;
          _conversationHistory.add({
            'role': map['role'] as String,
            'content': map['content'] as String,
          });
        }
      }
      
      _isInitialized = true;
      _addSystemMessage(); // Asegurarnos de que tenemos el mensaje del sistema
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar nivel y lenguaje
      await prefs.setString('current_level', _currentLevel);
      await prefs.setString('current_language', _currentLanguage);
      
      // Guardar mensajes
      final messagesJson = json.encode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString('messages', messagesJson);
      
      // Guardar historial de conversación
      final history = _conversationHistory.map((item) => json.encode(item)).toList();
      await prefs.setStringList('chat_history', history);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _messagesController.add(_messages);
    _saveChatHistory();
    
    // Actualizar historial de conversación para ChatGPT
    _conversationHistory.add({
      'role': message.isUser ? 'user' : 'assistant',
      'content': message.content,
    });
  }

  List<ChatMessage> getMessages() => _messages;

  void clearHistory() {
    _messages.clear();
    _conversationHistory.clear();
    _messagesController.add(_messages);
    _saveChatHistory();
    _addSystemMessage();
  }

  void updateLevel(String level) {
    _currentLevel = level;
    _addSystemMessage();
    _saveChatHistory();
  }

  void updateLanguage(String language) {
    _currentLanguage = language;
    _addSystemMessage();
    _saveChatHistory();
  }

  void _addSystemMessage() {
    if (_conversationHistory.isNotEmpty) {
      if (_conversationHistory[0]['role'] == 'system') {
        _conversationHistory.removeAt(0);
      }
    }

    final languageNames = {
      'en': 'inglés',
      'fr': 'francés',
      'de': 'alemán',
      'it': 'italiano',
      'pt': 'portugués',
      'es': 'español',
    };

    final levelDescriptions = {
      'A1': 'principiante',
      'A2': 'básico',
      'B1': 'intermedio',
      'B2': 'intermedio alto',
      'C1': 'avanzado',
      'C2': 'maestría',
    };

    final targetLanguage = languageNames[_currentLanguage] ?? _currentLanguage;
    final levelDesc = levelDescriptions[_currentLevel] ?? _currentLevel;

    _conversationHistory.insert(0, {
      'role': 'system',
      'content': '''Eres un profesor de $targetLanguage experto y amigable. 
Nivel del estudiante: $_currentLevel ($levelDesc)

Instrucciones específicas:
1. SIEMPRE responde en $targetLanguage
2. Adapta tu lenguaje al nivel $_currentLevel:
   - A1-A2: Usa vocabulario básico y oraciones simples
   - B1-B2: Incorpora vocabulario intermedio y algunas estructuras complejas
   - C1-C2: Usa lenguaje avanzado y expresiones idiomáticas

3. Si el estudiante comete errores:
   - Corrige los errores importantes
   - Explica brevemente la corrección en español
   - Da ejemplos de uso correcto

4. Formato de respuesta:
   - Respuesta en $targetLanguage
   - [Correcciones] (si hay errores)
   - 💡 Explicación en español (breve)

5. Mantén un tono amigable y motivador
6. Usa emojis ocasionalmente para hacer la conversación más amena
7. Si el estudiante intenta cambiar de idioma, recuérdale amablemente que debe practicar en $targetLanguage'''
    });
  }

  Stream<ChatMessage> sendMessageStream(String userMessage, String targetLanguage) async* {
    if (!_isInitialized || _apiKey == null) {
      yield ChatMessage(
        content: 'Error: El servicio de chat no está configurado correctamente.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      return;
    }

    if (_currentLanguage != targetLanguage) {
      _currentLanguage = targetLanguage;
      _addSystemMessage();
    }

    addMessage(ChatMessage(
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    try {
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });
      request.body = jsonEncode({
        'model': 'gpt-4',
        'messages': _conversationHistory,
        'temperature': 0.7,
        'stream': true,
      });

      final response = await client.send(request);

      if (response.statusCode != 200) {
        final error = await response.stream.bytesToString();
        yield ChatMessage(
          content: 'Error: No se pudo obtener una respuesta del servidor. ${response.statusCode}: $error',
          isUser: false,
          timestamp: DateTime.now(),
        );
        return;
      }

      String accumulatedResponse = '';
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') break;
            
            try {
              final Map<String, dynamic> jsonData = jsonDecode(data);
              if (jsonData['choices'] != null &&
                  jsonData['choices'][0]['delta'] != null &&
                  jsonData['choices'][0]['delta']['content'] != null) {
                final content = jsonData['choices'][0]['delta']['content'] as String;
                accumulatedResponse += content;
                
                yield ChatMessage(
                  content: accumulatedResponse,
                  isUser: false,
                  timestamp: DateTime.now(),
                );
              }
            } catch (e) {
              print('Error parsing chunk: $e');
            }
          }
        }
      }

      addMessage(ChatMessage(
        content: accumulatedResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      client.close();

    } catch (e) {
      yield ChatMessage(
        content: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(userMessage);

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un tutor de idiomas amigable y paciente. Tu objetivo es ayudar a los estudiantes a mejorar su español a través de conversaciones naturales. Corrige los errores de manera constructiva y proporciona explicaciones claras. Mantén las respuestas concisas pero informativas.',
            },
            {
              'role': 'user',
              'content': content,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        
        final botMessage = ChatMessage(
          content: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
          quickReplies: _generateQuickReplies(botResponse),
        );
        
        addMessage(botMessage);
      } else {
        throw Exception('Error en la respuesta de OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar mensaje: $e');
      final errorMessage = ChatMessage(
        content: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      addMessage(errorMessage);
    }
  }

  List<String> _generateQuickReplies(String botResponse) {
    return [
      '¿Puedes explicar más?',
      'Entiendo',
      'Gracias',
      '¿Cómo se dice...?',
    ];
  }

  void dispose() {
    _saveChatHistory();
  }
}
