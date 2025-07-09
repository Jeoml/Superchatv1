import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/user_details.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class ChatManager {
  static Future<String> chat(String token, String cookie, String text, String currentEndpoint) async {
    final client = http.Client();
    try {
      final urlChat = dotenv.env['CHAT_API_URL'];
      final urlPdf = dotenv.env['PDF_API_URL'];
      final urlCSV = dotenv.env['CSV_API_URL'];
      String url;
      
      print('Debug: Current endpoint - $currentEndpoint');
      
      switch (currentEndpoint) {
        case 'chat':
          url = urlChat!;
          break;
        case 'pdf':
          url = urlPdf!;
          break;
        case 'csv':
          url = urlCSV!;
          break;
        default:
          print('Debug: Invalid endpoint - $currentEndpoint');
          throw Exception('Invalid endpoint');
      }

      print('Debug: Making request to URL - $url');
      print('Debug: Request headers - Token: ${token.substring(0, 10)}... Cookie: ${cookie.substring(0, 10)}...');
      print('Debug: Request body - Text: $text');

      // FIXED: Use http.post directly instead of client.send
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
          // 'Cookie': cookie, // Uncomment if needed
        },
        body: {
          'message': text,
          'session_id': Uuid().v4(),
        },
      );

      print('Debug: Sending request...');
      print('Debug: Response status code - ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Debug: Raw response body - ${response.body}');
        try {
          final data = jsonDecode(response.body);
          print('Debug: Parsed response - ${data['response']}');
          return data['response'] ?? 'No response from bot';
        } catch (e) {
          print('Debug: JSON decoding failed - $e');
          return 'Error: Failed to decode response - ${response.body}';
        }
      }
      else if (response.statusCode == 400) {
        print('Debug: Bad Request error - ${response.body}');
        return 'Error: Bad Request - ${response.body}';
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
        print('Debug: Unexpected error - ${response.statusCode} - ${response.body}');
        return 'Error in chat: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Debug: Exception caught - $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}