import 'package:flutter_bloc/flutter_bloc.dart';

class SessionCubit extends Cubit<String?> {
  SessionCubit() : super(null);

  void saveToken(String token) => emit(token);

  void clearToken() => emit(null);
}
