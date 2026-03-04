import 'package:authentication/data/datasources/auth_api_client.dart';
import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/models/login_response_dto.dart';

/// Retrofit-based implementation of [RemoteAuthDataSource].
class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  const RemoteAuthDataSourceImpl({required this.apiClient});

  final AuthApiClient apiClient;

  @override
  Future<LoginResponseDto> login(String dni, String password) =>
      apiClient.login({'dni': dni, 'password': password});

  @override
  Future<void> logout(String token) => apiClient.logout(token);
}
