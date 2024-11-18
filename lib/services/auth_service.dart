// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:learnings1/services/login_service.dart';
import 'package:learnings1/services/signup_service.dart';


class AuthService {
  String? receivedToken;
  Future<bool> authenticate(String email, String password, bool isLogin) async {
    final url = isLogin ? 'https://oriented-infinitely-calf.ngrok-free.app/login' : 'https://oriented-infinitely-calf.ngrok-free.app/signup';
    try {
      if(isLogin) return login(email, password, isLogin, url);
      return signup(email, password, isLogin, url);
    } catch (e) {
      print('Error in authenticate: $e');
      rethrow;
    }
  }
}