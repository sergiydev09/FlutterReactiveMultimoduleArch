import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user.freezed.dart';

/// Represents an authenticated user of the banking application.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String dni,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime createdAt,
    String? phone,
    String? avatarUrl,
  }) = _User;

  const User._();

  /// Full name convenience getter.
  String get fullName => '$firstName $lastName';

  /// Initials for avatar fallback (e.g. "JS" for John Smith).
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }
}
