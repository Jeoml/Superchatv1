import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_event.dart';
import 'login_state.dart';
import '/session/session_cubit.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static final String _loginUrl = dotenv.env['LOGIN_API_URL']!;
  final SessionCubit sessionCubit;

  LoginBloc({required this.sessionCubit}) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      try {
        final uri = Uri.parse(_loginUrl);
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: {
            "email": event.email.trim(),
            "password": event.password.trim(),
          },
        );

        if (response.statusCode == 200) {
          final responseJson = json.decode(response.body);
          final token = responseJson['access_token'];
          final cookie = response.headers['set-cookie'];

          sessionCubit.saveToken(token); // Save token
          emit(LoginSuccess(token: token)); // Return actual token

          // Optional: Call chat or other API here
          // await chat(token, cookie); // Uncomment if implemented
        } else {
          emit(LoginFailure(error: response.reasonPhrase ?? 'Login failed'));
        }
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}
