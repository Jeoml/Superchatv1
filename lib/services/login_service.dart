import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/signup_service.dart';
import 'package:learnings1/services/token_service.dart';

// Use the same global key defined above
// final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

Future<bool> login(
    String email, String password, bool isLogin, String url, {int retryCount = 0}) async {
  final maxRetries = 3;
  
  if (retryCount >= maxRetries) {
    snackbarKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Maximum retry attempts reached'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }

  String? receivedToken;
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );


    // snackbarKey.currentState?.showSnackBar(
    //   SnackBar(
    //     content: Text('Login response status: ${response.statusCode}'),
    //   ),
    // );

    // snackbarKey.currentState?.showSnackBar(
    //   SnackBar(
    //     content: Text('Login response body: ${response.body}'),
    //   ),
    // );

    if (response.statusCode == 200) {
      String? cookies = response.headers['set-cookie'];
      String combinedCookies = cookies ?? '';
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('LogIn Succesful'),
          backgroundColor: Colors.green,
        ),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('token')) {
        String token = jsonResponse['token']!.split(' ').last;
        receivedToken = token;
        await setChat(receivedToken, combinedCookies);
        return true;
      } else {
        return false;
      }
    } else if (response.statusCode == 403) {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Received 403, attempting retry ${retryCount + 1} of $maxRetries'),
          backgroundColor: Colors.orange,
        ),
      );
      return login(email, password, isLogin, url, retryCount: retryCount + 1);
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

Future<void> setChat(String token, String cookie) async {
  await chat(token, cookie);
}