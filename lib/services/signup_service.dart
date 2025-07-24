import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

Future<bool> signup(String email, String password, String url) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['response'] == 'Signup Successful!') {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Signup successful. Now Please Log In'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Signup failed: Invalid response'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to signup: ${response.reasonPhrase}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (error) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Error in signup: $error'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}