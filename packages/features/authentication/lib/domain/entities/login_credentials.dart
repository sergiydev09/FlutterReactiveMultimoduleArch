import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/login_credentials.freezed.dart';

@freezed
abstract class LoginCredentials with _$LoginCredentials {
  const factory LoginCredentials({
    required String dni,
    required String password,
  }) = _LoginCredentials;
}
