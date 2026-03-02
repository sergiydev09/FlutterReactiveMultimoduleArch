part of 'auth_bloc.dart';

/// Events for the authentication BLoC.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Requested when the user submits login credentials.
final class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.dni,
    required this.password,
  });

  final String dni;
  final String password;

  @override
  List<Object?> get props => [dni, password];
}

/// Requested when the user taps logout.
final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Requested when the user taps biometric login.
final class BiometricLoginRequested extends AuthEvent {
  const BiometricLoginRequested();
}

/// Requested to check the current authentication status on app start.
final class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
