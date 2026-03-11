part of 'login_bloc.dart';

enum LoginStatus { initial, loading, authenticated, unauthenticated, error }

extension LoginStatusX on LoginStatus {
  bool get isInitial => this == LoginStatus.initial;
  bool get isLoading => this == LoginStatus.loading;
  bool get isAuthenticated => this == LoginStatus.authenticated;
  bool get isUnauthenticated => this == LoginStatus.unauthenticated;
  bool get isError => this == LoginStatus.error;
}

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(LoginStatus.initial) LoginStatus status,
    User? user,
    @Default('') String errorMessage,
  }) = _LoginState;
}
