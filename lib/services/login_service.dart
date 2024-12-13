import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/signup_service.dart';
import 'package:learnings1/services/token_service.dart';
import 'package:learnings1/services/user_details.dart';

Future<bool> login(String email, String password, bool isLogin, String url,
    {int retryCount = 0}) async {
  const maxRetries = 3;

  if (retryCount >= maxRetries) {
    snackbarKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Maximum retry attempts reached'),
        backgroundColor: Colors.red,
      ),
    );
    // debug false
    return false;
  }

  String? receivedToken;
  try {
    final response = await http.post(
      Uri.parse(url+'/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      if(response.body.trim().isEmpty) {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Empty Response received from server'),
            backgroundColor: Colors.red,
          ),
        );
        return true;
      }
      
      String? cookies = response.headers['set-cookie'];
      String combinedCookies = cookies ?? '';
      
      var jsonResponse = jsonDecode(response.body.trim());
      if (jsonResponse.containsKey('token')) {
        String token = jsonResponse['token']!.split(' ').last;
        receivedToken = token;
        storeDetails(email.trim(), receivedToken, password.trim());
        await setChat(receivedToken, combinedCookies);
        
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('LogIn Succesful'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        return true;
        // debug false
      }
    } else if (response.body.isNotEmpty && jsonDecode(response.body) == "Error 403") {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
              'Received 403, attempting retry ${retryCount + 1} of $maxRetries'),
          backgroundColor: Colors.orange,
        ),
      );
      return login(email, password, isLogin, url, retryCount: retryCount + 1);
    } else {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to login: ${response.reasonPhrase} ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
      return true;
      // debug false
    }
  } catch (error) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('$error'),
        backgroundColor: Colors.red,
      ),
    );
    return true;
    // debug false
  }
  return false;
}

Future<void> setChat(String token, String cookie) async {
  await chat(token, cookie);
}