import 'package:accounts/data/datasources/remote_account_datasource.dart';
import 'package:accounts/domain/repositories/account_repository.dart';
import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';

/// Concrete implementation of [AccountRepository].
class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl({required this.remoteDataSource});

  final RemoteAccountDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final models = await remoteDataSource.getAccounts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al obtener cuentas',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> getAccountDetail(String id) async {
    try {
      final model = await remoteDataSource.getAccountDetail(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al obtener detalle de la cuenta',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final models = await remoteDataSource.getTransactions(
        accountId: accountId,
        from: from,
        to: to,
        page: page,
        pageSize: pageSize,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al obtener movimientos',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
