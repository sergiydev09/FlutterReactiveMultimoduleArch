part of 'login_bloc.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = LoginInitial;

  const factory LoginState.loading() = LoginLoading;

  const factory LoginState.authenticated({required User user}) =
      LoginAuthenticated;

  const factory LoginState.unauthenticated() = LoginUnauthenticated;

  const factory LoginState.error({required String message}) = LoginError;
}
