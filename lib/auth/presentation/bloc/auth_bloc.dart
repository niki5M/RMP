import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/user_login.dart';
import '../../domain/usecases/user_sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;

  AuthBloc({required UserLogin userLogin, required UserSignUp userSignUp})
      : _userSignUp = userSignUp,
        _userLogin = userLogin,
        super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUp(UserSignUpParams(
        email: event.email, password: event.password, name: event.name));

    res.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogin(
        UserLoginParams(email: event.email, password: event.password));

    res.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (user) => emit(AuthSuccess(user)), // Изменено на AuthSuccess
    );
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}