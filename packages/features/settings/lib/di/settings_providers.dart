import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security/security.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/get_biometrics_status_usecase.dart';
import '../domain/usecases/toggle_biometrics_usecase.dart';

/// Riverpod providers for the settings feature.
abstract final class SettingsProviders {
  static final repository = Provider<SettingsRepository>((ref) {
    return SettingsRepositoryImpl(
      secureStorage: ref.read(SecurityProviders.secureStorage),
      biometricEnabledNotifier:
          ref.read(SecurityProviders.biometricEnabled.notifier),
    );
  });

  static final getBiometricsStatusUseCase =
      Provider<GetBiometricsStatusUseCase>((ref) {
    return GetBiometricsStatusUseCase(
      repository: ref.read(repository),
    );
  });

  static final toggleBiometricsUseCase =
      Provider<ToggleBiometricsUseCase>((ref) {
    return ToggleBiometricsUseCase(
      repository: ref.read(repository),
    );
  });
}
