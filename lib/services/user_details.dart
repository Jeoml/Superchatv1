import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/login_service.dart';
import 'package:learnings1/services/signup_service.dart';
String? email;
String? token;
String? password;

Future<void> storeDetails (String newEmail, String? newToken, String newPassword){
  email = newEmail;
  token = newToken;
  password = newPassword;
  return Future.value();
}

Future <bool> refresh_token () async {
  try {
    final response = await http.post(
      Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      String? cookies = response.headers['set-cookie'];
      String combinedCookies = cookies ?? '';
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('refresh Succesful'),
          backgroundColor: Colors.green,
        ),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('token')) {
        String token = jsonResponse['token']!.split(' ').last;
        token = token;
        await setChat(token, combinedCookies);
        return true;
      } else {
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
        content: Text('Error in login: $error'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}