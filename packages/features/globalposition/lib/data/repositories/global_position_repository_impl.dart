import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:globalposition/domain/repositories/global_position_repository.dart';

/// Concrete implementation of [GlobalPositionRepository].
class GlobalPositionRepositoryImpl implements GlobalPositionRepository {
  const GlobalPositionRepositoryImpl({required this.remoteDataSource});

  final RemoteGlobalPositionDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final accounts = await remoteDataSource.getAccounts();
      return Right(accounts);
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
  Future<Either<Failure, List<Transaction>>> getRecentTransactions() async {
    try {
      final transactions = await remoteDataSource.getRecentTransactions();
      return Right(transactions);
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
