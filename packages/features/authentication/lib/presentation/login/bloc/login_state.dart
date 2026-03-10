part of 'login_bloc.dart';

enum LoginStatus { initial, loading, authenticated, unauthenticated, error }

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(LoginStatus.initial) LoginStatus status,
    User? user,
    @Default('') String errorMessage,
  }) = _LoginState;
}
