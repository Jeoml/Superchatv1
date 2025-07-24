import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/login_service.dart';
import 'package:learnings1/services/token_service.dart' show setChat;

String? email;
String? token;
String? password;

Future<void> storeDetails(String newEmail, String? newToken, String newPassword) async {
  email = newEmail;
  token = newToken;
  password = newPassword;
}

Future<bool> refresh_token() async {
  try {
    final response = await http.post(
      Uri.parse(dotenv.env['LOGIN_API_URL']!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('access_token')) {
        token = jsonResponse['access_token'];
        await setChat(token!, ''); // No cookie needed for refresh
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Refresh Successful'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Refresh failed: Invalid response'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: ${response.reasonPhrase}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (error) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Error in refresh: $error'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}