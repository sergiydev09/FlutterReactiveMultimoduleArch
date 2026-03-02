import 'package:equatable/equatable.dart';

/// Represents an authenticated user of the banking application.
class User extends Equatable {
  const User({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    this.phone,
    this.avatarUrl,
  });

  /// Unique user identifier.
  final String id;

  /// National identification number (DNI / NIF).
  final String dni;

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// Email address.
  final String email;

  /// Phone number (optional).
  final String? phone;

  /// URL to the user's avatar image (optional).
  final String? avatarUrl;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Full name convenience getter.
  String get fullName => '$firstName $lastName';

  /// Initials for avatar fallback (e.g. "JS" for John Smith).
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Creates a copy with optionally overridden fields.
  User copyWith({
    String? id,
    String? dni,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      dni: dni ?? this.dni,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dni,
        firstName,
        lastName,
        email,
        phone,
        avatarUrl,
        createdAt,
      ];
}
