import 'package:domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import './auth_token.dart';

part 'generated/login_result.freezed.dart';

@freezed
abstract class LoginResult with _$LoginResult {
  const factory LoginResult({
    required AuthToken token,
    required User user,
  }) = _LoginResult;
}
