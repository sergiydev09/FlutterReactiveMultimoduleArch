import 'package:common/common.dart';
import 'package:fpdart/fpdart.dart';
import 'package:security/security.dart';
import '../../domain/repositories/settings_repository.dart';

/// Concrete implementation of [SettingsRepository].
///
/// Biometric preference is read directly from [SecureStorageService] and
/// toggled via [BiometricEnabledNotifier.toggle], which keeps both the
/// persisted value and the reactive Riverpod state in sync.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required this.secureStorage,
    required this.biometricEnabledNotifier,
  });

  final SecureStorageService secureStorage;
  final BiometricEnabledNotifier biometricEnabledNotifier;

  // Must match the private key used by BiometricEnabledNotifier.
  static const _biometricKey = 'biometric_enabled';

  @override
  Future<Either<Failure, bool>> getBiometricsEnabled() async {
    try {
      final value = await secureStorage.read(_biometricKey);
      return (value == 'true').toRight();
    } on Exception catch (e) {
      return Failure.server(message: e.toString()).toLeft();
    }
  }

  @override
  Future<Either<Failure, bool>> toggleBiometrics() async {
    try {
      await biometricEnabledNotifier.toggle();
      final value = await secureStorage.read(_biometricKey);
      return (value == 'true').toRight();
    } on Exception catch (e) {
      return Failure.server(message: e.toString()).toLeft();
    }
  }
}
