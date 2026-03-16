import 'package:common/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for settings-related operations.
abstract class SettingsRepository {
  /// Returns whether biometric login is currently enabled.
  Future<Either<Failure, bool>> getBiometricsEnabled();

  /// Toggles the biometric login preference and returns the new value.
  Future<Either<Failure, bool>> toggleBiometrics();

  /// Clears the active session and user data (logout).
  Future<Either<Failure, void>> logout();
}
