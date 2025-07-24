import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/token_service.dart';

class ChatApiService {
  static final String _baseUrl = dotenv.env['BASE_URL']!; 
  static Future<String> fetchChatResponse(String sessionId, String userText, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/chat"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          'authorization': 'Bearer $token',
        },
        body: 'session_id=${Uri.encodeComponent(sessionId)}&message=${Uri.encodeComponent(userText)}',
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

  static Future<String> fetchChatPdfResponse(String question, String filePath, String token) async {
    var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/chat_pdf"));
    request.headers['authorization'] = 'Bearer $token';
    request.fields['question'] = question;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? "I couldn't understand.";
    } else {
      return "API error: \\${response.statusCode}";
    }
  }
}
