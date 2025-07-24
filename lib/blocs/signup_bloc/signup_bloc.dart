import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'signup_event.dart';
import 'signup_state.dart';
import 'package:learnings1/services/login_service.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  static final String _signupUrl = dotenv.env['SIGNUP_API_URL']!;

  SignupBloc() : super(SignupInitial()) {
    on<SignupSubmitted>((event, emit) async {
      emit(SignupLoading());

      try {
        final uri = Uri.parse(_signupUrl);
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json",
          },
          body: {
            "email": event.email.trim(),
            "password": event.password.trim(),
          },
        );

        if (response.statusCode == 200) {
          // Signup succeeded, now attempt login
          final loginUrl = dotenv.env['LOGIN_API_URL']!;
          final loginResult = await login(event.email.trim(), event.password.trim(), loginUrl);
          if (loginResult) {
            // Retrieve token from storage (or pass it from login if you refactor login())
            // For now, just emit success without token detail
            emit(SignupAndLoginSuccess(token: '')); // Optionally fetch token from storage
          } else {
            emit(SignupFailure(error: 'Signup succeeded but login failed.'));
          }
        } else {
          emit(SignupFailure(error: response.reasonPhrase ?? 'Unknown error'));
        }
      } catch (e) {
        emit(SignupFailure(error: e.toString()));
      }
    });
  }
}
