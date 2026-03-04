import 'dart:developer' as developer;
import 'package:local_auth/local_auth.dart';

/// Service for handling biometric authentication (Face ID, Touch ID,
/// fingerprint).
class BiometricService {
  BiometricService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  static const _tag = 'BiometricService';

  /// Returns `true` if the device supports biometric authentication
  /// and the user has enrolled at least one biometric.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on Exception catch (e) {
      developer.log('Biometric availability check failed: $e', name: _tag);
      return false;
    }
  }

  /// Returns the list of enrolled biometric types on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on Exception catch (e) {
      developer.log('Failed to get available biometrics: $e', name: _tag);
      return [];
    }
  }

  /// Prompts the user for biometric authentication.
  ///
  /// Returns `true` if authentication was successful.
  ///
  /// [reason] is displayed to the user explaining why authentication
  /// is required.
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      final isSupported = await isAvailable();
      if (!isSupported) {
        developer.log('Biometrics not available on this device', name: _tag);
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on Exception catch (e) {
      developer.log('Biometric authentication failed: $e', name: _tag);
      return false;
    }
  }
}
