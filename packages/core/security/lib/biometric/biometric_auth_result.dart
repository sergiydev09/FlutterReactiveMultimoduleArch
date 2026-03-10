/// Result of a successful biometric authentication with device credentials.
///
/// Contains everything the auth feature needs to send to the backend
/// for token exchange. The auth feature doesn't need to know about
/// cryptography — just forwards these values.
class BiometricAuthResult {
  const BiometricAuthResult({
    required this.signature,
    required this.deviceId,
    required this.publicKey,
  });

  /// Challenge signed with the device's private key (Secure Enclave / Keystore).
  final String signature;

  /// Unique identifier for this device.
  final String deviceId;

  /// Public key associated with this device (for backend verification).
  final String publicKey;
}
