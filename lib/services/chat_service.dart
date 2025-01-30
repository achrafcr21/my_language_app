import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';

class ChatService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;
  final List<Map<String, String>> _conversationHistory = [];

  ChatService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in .env file');
    }
  }

  Future<ChatMessage> sendMessage(String userMessage, String targetLanguage) async {
    try {
      // Configuramos el contexto del profesor con el idioma objetivo
      if (_conversationHistory.isEmpty) {
        _conversationHistory.add({
          'role': 'system',
          'content': '''Eres un profesor de ${_getLanguageName(targetLanguage)} experto y amigable. Tu objetivo es:
1. Ayudar al estudiante a practicar ${_getLanguageName(targetLanguage)}
2. Corregir errores gramaticales de manera constructiva
3. Proporcionar explicaciones claras y ejemplos
4. Mantener una conversación natural y motivadora
5. Usar emojis ocasionalmente para hacer la conversación más amena

Reglas:
- SIEMPRE responde en ${_getLanguageName(targetLanguage)}
- Si el estudiante comete errores, corrígelos amablemente
- Proporciona explicaciones breves en español
- Mantén las respuestas concisas y enfocadas

Formato de respuesta:
- Respuesta en ${_getLanguageName(targetLanguage)}
- [Correcciones] (si hay errores)
- 💡 Explicación en español (breve)'''
        });
      }

      // Añadimos el mensaje del usuario al historial
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': _conversationHistory,
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);
        final content = data['choices'][0]['message']['content'];
        
        // Añadimos la respuesta al historial
        _conversationHistory.add({
          'role': 'assistant',
          'content': content,
        });

        return ChatMessage(
          content: content,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in ChatService: $e');
      rethrow;
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'inglés';
      case 'es': return 'español';
      case 'fr': return 'francés';
      case 'de': return 'alemán';
      default: return code;
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
  }
}
