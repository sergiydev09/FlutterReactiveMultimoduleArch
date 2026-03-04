import 'package:domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/user_dto.g.dart';

@JsonSerializable()
class UserDto {
  const UserDto({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    this.phone,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String id;
  final String dni;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String? phone;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  User toEntity() {
    return User(
      id: id,
      dni: dni,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
