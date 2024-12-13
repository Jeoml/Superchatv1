import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/user_details.dart';
import 'package:path/path.dart';

class ChatManager {
  static Future<String> chat(String token, String cookie, String text, String currentEndpoint) async {
    // Replace with your API URL
    final urlChat = Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/chat');
    final urlPdf = Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/ask_pdf');
    final urlCSV = Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/ask_csv');
    Uri url;
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
        throw Exception('Invalid endpoint');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cookie': cookie,
      },
      body: jsonEncode({
        (currentEndpoint == 'chat' || currentEndpoint == 'pdf' || currentEndpoint == 'csv') ? 'user_input' : 'question': text
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No response from bot';
    } else if (response.statusCode == 400){
      return 'Error: Bad Request';
    } else if (response.statusCode == 403){
      bool refreshed = await refresh_token();
      if(refreshed){
        return 'token refreshed, continue chatting';
      }
      else {
        return 'refresh failed';
      }
    }
    else {
      return 'Error: ${response.statusCode}';
    }
  }
}
