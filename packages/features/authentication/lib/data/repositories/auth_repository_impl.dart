import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/domain/entities/login_credentials.dart';
import 'package:authentication/domain/entities/login_result.dart';
import 'package:authentication/domain/repositories/auth_repository.dart';
import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remoteDataSource});

  final RemoteAuthDataSource remoteDataSource;

  @override
  Future<Either<Failure, LoginResult>> login(
    LoginCredentials credentials,
  ) async {
    try {
      final response = await remoteDataSource.login(
        credentials.dni,
        credentials.password,
      );
      return Right(
        LoginResult(
          token: response.token.toEntity(),
          user: response.user.toEntity(),
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al iniciar sesión',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout('');
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al cerrar sesión',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
