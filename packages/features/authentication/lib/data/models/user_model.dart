import 'package:domain/entities/user.dart';

/// Data model for [User], with JSON serialization support.
class UserModel {
  const UserModel({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    this.phone,
    this.avatarUrl,
  });

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      dni: json['dni'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String dni;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  /// Converts this model to a domain entity.
  User toEntity() {
    return User(
      id: id,
      dni: dni,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
