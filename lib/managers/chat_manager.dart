import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/user_details.dart';
import 'package:path/path.dart';

class ChatManager {
  static Future<String> chat(String token, String cookie, String text, String currentEndpoint) async {
    final client = http.Client();
    try {
      const urlChat = 'https://suitable-jolly-falcon.ngrok-free.app/chat';
      const urlPdf = 'https://suitable-jolly-falcon.ngrok-free.app/ask_pdf';
      const urlCSV = 'https://suitable-jolly-falcon.ngrok-free.app/ask_csv';
      String url;
      
      print('Debug: Current endpoint - $currentEndpoint');
      
      switch (currentEndpoint) {
        case 'chat':
          url = urlChat;
          break;
        case 'pdf':
          url = urlPdf;
          break;
        case 'csv':
          url = urlCSV;
          break;
        default:
          print('Debug: Invalid endpoint - $currentEndpoint');
          throw Exception('Invalid endpoint');
      }

      print('Debug: Making request to URL - $url');
      print('Debug: Request headers - Token: ${token.substring(0, 10)}... Cookie: ${cookie.substring(0, 10)}...');
      print('Debug: Request body - Text: $text');

      final request = http.Request('POST', Uri.parse(url))
        ..followRedirects = true
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // 'Cookie': cookie,
        })
        ..body = jsonEncode({
          'user_input': text,
          'response_length': 'medium',
            if (currentEndpoint == 'chat') 'target_lang': 'en',
        });

      print('Debug: Sending request...');
      final response = await client.send(request).then((response) => http.Response.fromStream(response));
      print('Debug: Response status code - ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Debug: Successful response - ${data['response']?.substring(0, 50)}...');
        return data['response'] ?? 'No response from bot';
      } else if (response.statusCode == 400) {
        print('Debug: Bad Request error');
        return 'Error: Bad Request';
      } else if (response.statusCode == 403) {
        print('Debug: Authentication failed, attempting token refresh');
        bool refreshed = await refresh_token();
        print('Debug: Token refresh result - $refreshed');
        if(refreshed) {
          return 'token refreshed, continue chatting';
        } else {
          return 'refresh failed';
        }
      } else {
        print('Debug: Unexpected error - ${response.statusCode}');
        return 'Error in chat: ${response.statusCode}';
      }
    } catch (e) {
      print('Debug: Exception caught - $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
