import 'package:learnings1/managers/chat_manager.dart';

String? userMessage;
String? token;
String? cookie;

Future<void> chat (String AuthToken, String Cookie) async{
  token = AuthToken;
  cookie = Cookie;
}

Future<String> chatHandler(String userText, String currentEndpoint) async {
  if (token == null) {
    throw Exception('Invalid Access. Login is required');
  }
  if (cookie == null) {
    throw Exception('Invalid Access. Login is required');
  }
  userMessage = userText;
  return ChatManager.chat(token!, cookie!, userText, currentEndpoint);
}

Future<String?> requestToken () async {
  return token;
}