import 'dart:developer' as developer;

import 'biometric_auth_result.dart';

/// Manages device-bound credentials for biometric authentication.
///
/// Wraps keypair generation (Secure Enclave / Android Keystore),
/// biometric verification, and challenge signing into a simple API
/// that the authentication feature can consume without knowing
/// anything about cryptography.
///
/// ## Usage from the auth feature:
///
/// **Enrollment** (user activates biometric login after a successful
/// credential-based login):
/// ```dart
/// final publicKey = await deviceCredentialService.enroll();
/// await remoteDataSource.registerDevice(publicKey: publicKey, deviceId: deviceId);
/// ```
///
/// **Biometric login** (user taps the biometric button):
/// ```dart
/// final challenge = await remoteDataSource.getBiometricChallenge();
/// final result = await deviceCredentialService.authenticate(challenge);
/// final tokens = await remoteDataSource.verifyBiometric(
///   signature: result.signature,
///   deviceId: result.deviceId,
/// );
/// ```
abstract class DeviceCredentialService {
  /// Whether device credentials have been enrolled on this device.
  Future<bool> isEnrolled();

  /// Generates a keypair in the platform's secure hardware and returns
  /// the **public key** to register with the backend.
  ///
  /// Call once after the user activates biometric login.
  Future<String> enroll();

  /// Prompts biometrics, signs the server [challenge] with the device's
  /// private key, and returns the result to send to the backend.
  Future<BiometricAuthResult> authenticate(String challenge);

  /// Returns the unique device identifier.
  Future<String> getDeviceId();

  /// Deletes the keypair. Call when the user disables biometric login
  /// or performs a permanent logout.
  Future<void> unenroll();
}

/// Placeholder implementation for development.
///
/// Returns deterministic fake values so the auth flow can be tested
/// end-to-end without real platform crypto. Replace with a real
/// implementation using platform channels (Secure Enclave / Android Keystore)
/// before going to production.
class NoOpDeviceCredentialService implements DeviceCredentialService {
  static const _tag = 'DeviceCredentialService';

  bool _enrolled = false;

  @override
  Future<bool> isEnrolled() async => _enrolled;

  @override
  Future<String> enroll() async {
    _enrolled = true;
    developer.log('Device credentials enrolled (no-op)', name: _tag);
    return 'mock-public-key';
  }

  @override
  Future<BiometricAuthResult> authenticate(String challenge) async {
    developer.log(
      'Signing challenge (no-op): $challenge',
      name: _tag,
    );
    return const BiometricAuthResult(
      signature: 'mock-signature',
      deviceId: 'mock-device-id',
      publicKey: 'mock-public-key',
    );
  }

  @override
  Future<String> getDeviceId() async => 'mock-device-id';

  @override
  Future<void> unenroll() async {
    _enrolled = false;
    developer.log('Device credentials removed (no-op)', name: _tag);
  }
}
