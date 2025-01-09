import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  const LottieAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
              'assets/lottie/thinking.json',
              width: 200,
              height: 200,
              ),
              Lottie.asset(
              'assets/lottie/listening.json',
              width: 200,
              height: 200,
              ),
              Lottie.asset(
              'assets/lottie/chatsuper.json',
              width: 200,
              height: 200,
              ),
            ],
            ),
        ),
      ),
    );
  }
}