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
}
