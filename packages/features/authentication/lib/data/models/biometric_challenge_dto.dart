import 'package:json_annotation/json_annotation.dart';

part 'generated/biometric_challenge_dto.g.dart';

@JsonSerializable()
class BiometricChallengeDto {
  const BiometricChallengeDto({required this.challenge});

  factory BiometricChallengeDto.fromJson(Map<String, dynamic> json) =>
      _$BiometricChallengeDtoFromJson(json);

  final String challenge;

  Map<String, dynamic> toJson() => _$BiometricChallengeDtoToJson(this);
}
