import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/models/login_response_dto.dart';

/// Datasource that throws for environments not yet implemented (PRE/PRO).
///
/// When injected via DI, the repository's `on Exception catch` converts
/// the thrown exception into a `Left(ServerFailure(...))`.
class UnimplementedAuthDataSource implements RemoteAuthDataSource {
  @override
  Future<LoginResponseDto> login(String dni, String password) {
    throw Exception('Los servicios de PRE/PRO no están implementados');
  }

  @override
  Future<void> logout(String token) {
    throw Exception('Los servicios de PRE/PRO no están implementados');
  }
}
