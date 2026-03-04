import 'package:authentication/data/models/login_response_dto.dart';

/// Remote data source contract for authentication operations.
abstract class RemoteAuthDataSource {
  /// Authenticates the user with the given [dni] and [password].
  ///
  /// Returns a [LoginResponseDto] on success.
  /// Throws an exception on failure.
  Future<LoginResponseDto> login(String dni, String password);

  /// Invalidates the session for the given [token].
  ///
  /// Throws an exception on failure.
  Future<void> logout(String token);
}
