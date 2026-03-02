import 'package:authentication/data/models/login_response_model.dart';

/// Remote data source contract for authentication operations.
abstract class RemoteAuthDataSource {
  /// Authenticates the user with the given [dni] and [password].
  ///
  /// Returns a [LoginResponseModel] on success.
  /// Throws an exception on failure.
  Future<LoginResponseModel> login(String dni, String password);

  /// Invalidates the session for the given [token].
  ///
  /// Throws an exception on failure.
  Future<void> logout(String token);
}
