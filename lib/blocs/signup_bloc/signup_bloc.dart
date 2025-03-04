import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  static final String _signupUrl = dotenv.env['SIGNUP_API_URL']!;

  SignupBloc() : super(SignupInitial()) {
    on<SignupSubmitted>((event, emit) async {
      emit(SignupLoading());

      try {
        final uri = Uri.parse(_signupUrl);
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": event.email.trim(),
            "password": event.password.trim(),
          }),
        );

        if (response.statusCode == 200) {
          emit(SignupSuccess());
        } else {
          emit(SignupFailure(error: response.reasonPhrase ?? 'Unknown error'));
        }
      } catch (e) {
        emit(SignupFailure(error: e.toString()));
      }
    });
  }
}