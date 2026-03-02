import 'package:equatable/equatable.dart';

/// Represents authentication tokens returned after a successful login.
class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// JWT access token used for API requests.
  final String accessToken;

  /// Refresh token used to obtain new access tokens.
  final String refreshToken;

  /// Timestamp when the access token expires.
  final DateTime expiresAt;

  /// Whether the access token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
