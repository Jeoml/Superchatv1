import '/screens/login_blocscreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(
            Duration(seconds: 5),
                () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen())));
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logo.png', // Replace with your logo file path
              height: 79.72, // Adjust size as needed
              width: 90,
            ),
            SizedBox(height: 20),
            // Text below the logo
            Text(
              'Superchat LLC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}