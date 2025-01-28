import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String? _apiKey; // Necesitaremos la API key de OpenAI

  ChatService(this._apiKey) {
    if (_apiKey == null) {
      throw Exception('OpenAI API key is required');
    }
  }

  Future<ChatMessage> sendMessage(String message, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a language teacher for $targetLanguage. '
                  'Respond to the student\'s messages in their target language, '
                  'provide corrections when necessary, and include explanations in their native language.'
            },
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return ChatMessage(
          content: content,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in ChatService: $e');
      rethrow;
    }
  }
}
