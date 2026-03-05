import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/remote_account_datasource.dart';

/// Concrete implementation of [AccountRepository].
class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl({required this.remoteDataSource});

  final RemoteAccountDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() =>
      safeApiCall(() async =>
          (await remoteDataSource.getAccounts()).map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, Account>> getAccountDetail(String id) =>
      safeApiCall(() async => (await remoteDataSource.getAccountDetail(id)).toEntity());

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  }) =>
      safeApiCall(() async =>
          (await remoteDataSource.getTransactions(
            accountId: accountId,
            from: from,
            to: to,
            page: page,
            pageSize: pageSize,
          )).map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, String>> getTransactionDetailUrl(
    String transactionId,
  ) =>
      safeApiCall(
        () => remoteDataSource.getTransactionDetailUrl(transactionId),
      );
}
