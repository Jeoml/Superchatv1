import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:learnings1/managers/chat_manager.dart';

String? userMessage;
String? token;
String? cookie;

Future<void> setChat(String AuthToken, String Cookie) async{
  token = AuthToken;
  cookie = Cookie;
  
  try {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final storageDir = Directory('${directory.path}/storage');
    
    // Create storage directory if it doesn't exist
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    
    // Write token to file
    final file = File('${storageDir.path}/token.txt');
    await file.writeAsString(AuthToken);
    print('Debug: Token stored at ${file.path}');
  } catch (e) {
    print('Error storing token: $e');
  }
}

Future<String> chatHandler(String userText, String currentEndpoint) async {
  // If token is null in memory, try to read from file
  if (token == null) {
    token = await _readTokenFromFile();
  }
  
  if (token == null) {
    throw Exception('Invalid Access. Login is required');
  }
  userMessage = userText;
  return ChatManager.chat(token!, cookie!, userText, currentEndpoint);
}

Future<String?> _readTokenFromFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/storage/token.txt');
    
    if (await file.exists()) {
      return await file.readAsString();
    }
  } catch (e) {
    print('Error reading token from file: $e');
  }
  return null;
}

Future<String?> requestToken () async {
  // If token is null in memory, try to read from file
  if (token == null) {
    token = await _readTokenFromFile();
  }
  return token;
}