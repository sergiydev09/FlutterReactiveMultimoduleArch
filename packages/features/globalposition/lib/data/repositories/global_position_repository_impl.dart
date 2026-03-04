import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/global_position_repository.dart';
import '../datasources/remote_globalposition_datasource.dart';

/// Concrete implementation of [GlobalPositionRepository].
class GlobalPositionRepositoryImpl implements GlobalPositionRepository {
  const GlobalPositionRepositoryImpl({required this.remoteDataSource});

  final RemoteGlobalPositionDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() =>
      safeApiCall(() async =>
          (await remoteDataSource.getAccounts()).map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions() =>
      safeApiCall(() async =>
          (await remoteDataSource.getRecentTransactions()).map((m) => m.toEntity()).toList());
}
