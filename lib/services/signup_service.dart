import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Create a global key for ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

Future<bool> signup(String email, String password, bool isLogin, String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Signup response status: ${response.statusCode}'),
        ),
      );

      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Signup response body: ${response.body}'),
        ),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['response']=='Signup Successful!') {
          snackbarKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Signup successful. Now Please Log In'),
              backgroundColor: Colors.green,
            ),
          );
          return false;
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