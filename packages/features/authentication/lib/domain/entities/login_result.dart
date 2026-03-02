import 'package:authentication/domain/entities/auth_token.dart';
import 'package:domain/entities/user.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing the result of a successful login.
class LoginResult extends Equatable {
  const LoginResult({
    required this.token,
    required this.user,
  });

  /// Authentication tokens.
  final AuthToken token;

  /// Authenticated user.
  final User user;

  @override
  List<Object?> get props => [token, user];
}
