import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatManager {
  static Future<String> chat(String token, String cookie, String text, String currentEndpoint) async {
    // Replace with your API URL
    final urlChat =
        Uri.parse('https://oriented-infinitely-calf.ngrok-free.app/chat');
    final urlPdf = Uri.parse('https://oriented-infinitely-calf.ngrok-free.app/ask');

    final response = await http.post(
      currentEndpoint == 'chat' ? urlChat : urlPdf,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cookie': cookie,
      },
      body: jsonEncode({
        currentEndpoint == 'chat' ? 'user_input' : 'question': text
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No response from bot';
    } else {
      return 'Error: ${response.statusCode}';
    }
  }
}
