import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/user_details.dart';
import 'package:learnings1/services/token_service.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

Future<bool> login(String email, String password, String url) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('access_token')) {
        String token = jsonResponse['access_token'];
        await storeDetails(email.trim(), token, password.trim());
        print('Debug: Token received - $token');
        await setChat(token, ''); // Ensure chatHandler uses the latest token
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Login Successful'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Login failed: Invalid response'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to login: ${response.reasonPhrase}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (error) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Error in login: $error'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}