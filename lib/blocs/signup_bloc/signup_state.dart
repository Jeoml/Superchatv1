abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {}

class SignupFailure extends SignupState {
  final String error;

  SignupFailure({required this.error});
}

class SignupAndLoginSuccess extends SignupState {
  final String token;
  SignupAndLoginSuccess({required this.token});
}