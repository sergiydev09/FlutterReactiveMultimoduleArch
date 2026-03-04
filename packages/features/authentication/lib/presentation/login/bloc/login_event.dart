part of 'login_bloc.dart';

@freezed
sealed class LoginEvent with _$LoginEvent {
  const factory LoginEvent.loginRequested({
    required String dni,
    required String password,
  }) = LoginRequested;

  const factory LoginEvent.logoutRequested() = LogoutRequested;

  const factory LoginEvent.biometricLoginRequested() = BiometricLoginRequested;

  const factory LoginEvent.checkAuthStatus() = CheckAuthStatus;
}
