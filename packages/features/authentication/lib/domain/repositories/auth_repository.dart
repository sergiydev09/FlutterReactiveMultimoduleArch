import 'package:common/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/login_credentials.dart';
import '../entities/login_result.dart';

/// Repository contract for authentication operations.
abstract class AuthRepository {
  /// Authenticates the user with the given [credentials].
  Future<Either<Failure, LoginResult>> login(LoginCredentials credentials);

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Authenticates the user via biometrics using device-bound credentials.
  ///
  /// Flow: biometric verification → sign server challenge → exchange for tokens.
  Future<Either<Failure, LoginResult>> biometricLogin();

  /// Enrolls device credentials for biometric login.
  ///
  /// Call after a successful credential-based login when the user
  /// activates biometric login in settings.
  Future<Either<Failure, void>> enrollBiometric();

  /// Removes device credentials from both device and backend.
  Future<Either<Failure, void>> unenrollBiometric();
}
