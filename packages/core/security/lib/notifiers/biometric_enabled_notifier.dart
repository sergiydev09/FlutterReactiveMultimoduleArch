import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/security_providers.dart';
import '../storage/secure_storage_service.dart';

/// Persists and exposes the user's biometric login preference.
class BiometricEnabledNotifier extends AsyncNotifier<bool> {
  static const _key = 'biometric_enabled';

  SecureStorageService get _storage => ref.read(SecurityProviders.secureStorage);

  @override
  Future<bool> build() async {
    final value = await _storage.read(_key);
    return value == 'true';
  }

  /// Toggles the biometric enabled preference and persists it.
  Future<void> toggle() async {
    final current = state.value ?? false;
    final next = !current;
    await _storage.write(_key, next.toString());
    state = AsyncData(next);
  }
}
