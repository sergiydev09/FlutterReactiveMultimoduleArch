import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/domain/entities/login_credentials.dart';
import 'package:authentication/domain/entities/login_result.dart';
import 'package:authentication/domain/repositories/auth_repository.dart';
import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:fpdart/fpdart.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remoteDataSource});

  final RemoteAuthDataSource remoteDataSource;

  @override
  Future<Either<Failure, LoginResult>> login(
    LoginCredentials credentials,
  ) =>
      safeApiCall(() async {
        final response = await remoteDataSource.login(
          credentials.dni,
          credentials.password,
        );
        return LoginResult(
          token: response.token.toEntity(),
          user: response.user.toEntity(),
        );
      });

  @override
  Future<Either<Failure, void>> logout() =>
      safeApiCall(() => remoteDataSource.logout(''));
}
