import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/token_service.dart';

class ChatApiService {
  static const String _baseUrl = "https://suitable-jolly-falcon.ngrok-free.app"; 
  static Future<String> fetchChatResponse(String userText) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/chat"),
        body: jsonEncode({'user_input': userText,
          'response_length': 'medium','target_lang': 'en',}),
        headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "I couldn't understand.";
      } else {
        return "API error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect to chat API.";
    }
  }
}
