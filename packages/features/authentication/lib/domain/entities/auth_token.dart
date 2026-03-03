import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/auth_token.freezed.dart';

@freezed
abstract class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _AuthToken;
}

extension AuthTokenX on AuthToken {
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
