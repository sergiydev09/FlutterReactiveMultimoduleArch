import 'package:authentication/data/models/auth_token_model.dart';
import 'package:authentication/data/models/user_model.dart';

/// Data model representing the complete login response from the API.
class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.user,
  });

  /// Creates a [LoginResponseModel] from a JSON map.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: AuthTokenModel.fromJson(json['token'] as Map<String, dynamic>),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Authentication tokens.
  final AuthTokenModel token;

  /// Authenticated user data.
  final UserModel user;
}
