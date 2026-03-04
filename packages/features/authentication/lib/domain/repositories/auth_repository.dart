import 'package:authentication/domain/entities/login_credentials.dart';
import 'package:authentication/domain/entities/login_result.dart';
import 'package:common/error/failures.dart';
import 'package:domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

/// Repository contract for authentication operations.
abstract class AuthRepository {
  /// Authenticates the user with the given [credentials].
  Future<Either<Failure, LoginResult>> login(LoginCredentials credentials);

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Authenticates the user via biometrics using the stored session.
  Future<Either<Failure, User>> biometricLogin();
}
