import 'package:common/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for session-related operations within the shell.
abstract class ShellSessionRepository {
  /// Clears the active session and user data (logout).
  Future<Either<Failure, void>> logout();
}
