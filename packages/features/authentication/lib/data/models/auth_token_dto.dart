import 'package:authentication/domain/entities/auth_token.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/auth_token_dto.g.dart';

@JsonSerializable()
class AuthTokenDto {
  const AuthTokenDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenDtoFromJson(json);

  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'expires_at')
  final String expiresAt;

  Map<String, dynamic> toJson() => _$AuthTokenDtoToJson(this);

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAt),
    );
  }
}
