import '../models/login_response_dto.dart';
import './auth_api_client.dart';

/// Remote data source for authentication operations.
class RemoteAuthDataSource {
  const RemoteAuthDataSource({required AuthApiClient apiClient})
      : _apiClient = apiClient;

  final AuthApiClient _apiClient;

  Future<LoginResponseDto> login(String dni, String password) =>
      _apiClient.login({'dni': dni, 'password': password});

  Future<void> logout(String token) => _apiClient.logout(token);

  // ---------------------------------------------------------------------------
  // Biometric device credentials
  // ---------------------------------------------------------------------------

  /// Registers the device's public key with the backend after the user
  /// activates biometric login.
  Future<void> registerDevice({
    required String publicKey,
    required String deviceId,
  }) =>
      _apiClient.registerDevice({
        'publicKey': publicKey,
        'deviceId': deviceId,
      });

  /// Requests a one-time challenge for biometric login.
  Future<String> getBiometricChallenge(String deviceId) async {
    final response = await _apiClient.getBiometricChallenge(deviceId);
    return response.challenge;
  }

  /// Sends the signed challenge to the backend for verification.
  /// Returns the same response as a normal login (tokens + user).
  Future<LoginResponseDto> verifyBiometric({
    required String signature,
    required String deviceId,
  }) =>
      _apiClient.verifyBiometric({
        'signature': signature,
        'deviceId': deviceId,
      });

  /// Unregisters the device from biometric login.
  Future<void> unregisterDevice(String deviceId) =>
      _apiClient.unregisterDevice(deviceId);
}
