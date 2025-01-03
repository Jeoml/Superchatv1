import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/token_service.dart';
import 'dart:convert';
import 'login_event.dart';
import 'login_state.dart';
import '/session/session_cubit.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static const String _loginUrl = 'https://suitable-jolly-falcon.ngrok-free.app/login';
  final SessionCubit sessionCubit; // Add a dependency on SessionCubit

  LoginBloc({required this.sessionCubit}) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      try {
        final uri = Uri.parse(_loginUrl);
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": event.email.trim(),
            "password": event.password.trim(),
          }),
        );

        if (response.statusCode == 200) {
          final responseJson = json.decode(response.body);
          final token = responseJson['token'];
          final Cookie = response.headers['set-cookie'];
          
          sessionCubit.saveToken(token); // Save the token to SessionCubit
          emit(LoginSuccess(token: token));
          chat(token, Cookie!);
        } else {
          emit(LoginFailure(error: response.reasonPhrase ?? 'Unknown error'));
        }
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}
