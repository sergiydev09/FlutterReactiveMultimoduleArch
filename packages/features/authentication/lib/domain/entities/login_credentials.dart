import 'package:equatable/equatable.dart';

/// Credentials required for user login.
class LoginCredentials extends Equatable {
  const LoginCredentials({
    required this.dni,
    required this.password,
  });

  /// National identification number.
  final String dni;

  /// User password.
  final String password;

  @override
  List<Object?> get props => [dni, password];
}
