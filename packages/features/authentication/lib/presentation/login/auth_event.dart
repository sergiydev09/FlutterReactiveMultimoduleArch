part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String dni,
    required String password,
  }) = LoginRequested;

  const factory AuthEvent.logoutRequested() = LogoutRequested;

  const factory AuthEvent.biometricLoginRequested() = BiometricLoginRequested;

  const factory AuthEvent.checkAuthStatus() = CheckAuthStatus;
}
