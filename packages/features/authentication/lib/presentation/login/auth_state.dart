part of 'auth_bloc.dart';

/// States for the authentication BLoC.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication check.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication operation in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  /// The authenticated user.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred during authentication.
final class AuthError extends AuthState {
  const AuthError({required this.message});

  /// Human-readable error message.
  final String message;

  @override
  List<Object?> get props => [message];
}
