import 'package:authentication/data/models/auth_token_dto.dart';
import 'package:authentication/data/models/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/login_response_dto.g.dart';

@JsonSerializable()
class LoginResponseDto {
  const LoginResponseDto({
    required this.token,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  final AuthTokenDto token;
  final UserDto user;

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}
