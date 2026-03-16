import 'package:common/common.dart';
import 'package:fpdart/fpdart.dart';
import 'package:security/security.dart';
import '../../domain/repositories/settings_repository.dart';

/// Concrete implementation of [SettingsRepository].
///
/// Biometric preference is read directly from [SecureStorageService] and
/// toggled via [BiometricEnabledNotifier.toggle], which keeps both the
/// persisted value and the reactive Riverpod state in sync.
///
/// Session teardown delegates to the shared [LogoutDataSource] from
/// `core/security`, avoiding duplication of the
/// `clearSession + clear` sequence across features.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required this.secureStorage,
    required this.biometricEnabledNotifier,
    required this.logoutDataSource,
  });

  final SecureStorageService secureStorage;
  final BiometricEnabledNotifier biometricEnabledNotifier;
  final LogoutDataSource logoutDataSource;

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

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await logoutDataSource.logout();
      return null.toRight();
    } on Exception catch (e) {
      return Failure.server(message: e.toString()).toLeft();
    }
  }
}
