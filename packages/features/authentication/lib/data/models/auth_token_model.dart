import 'package:authentication/domain/entities/auth_token.dart';

/// Data model for [AuthToken], with JSON serialization support.
class AuthTokenModel {
  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Creates an [AuthTokenModel] from a JSON map.
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// JWT access token.
  final String accessToken;

  /// Refresh token.
  final String refreshToken;

  /// Expiry timestamp.
  final DateTime expiresAt;

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Converts this model to a domain entity.
  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }
}
