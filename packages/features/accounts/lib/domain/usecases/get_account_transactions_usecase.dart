import 'package:accounts/domain/repositories/account_repository.dart';
import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for fetching account transactions.
class GetAccountTransactionsParams extends Equatable {
  const GetAccountTransactionsParams({
    required this.accountId,
    this.from,
    this.to,
    this.page = 0,
    this.pageSize = 20,
  });

  final String accountId;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [accountId, from, to, page, pageSize];
}

/// Fetches paginated transactions for a specific account.
class GetAccountTransactionsUseCase
    extends UseCase<List<Transaction>, GetAccountTransactionsParams> {
  GetAccountTransactionsUseCase({required this.repository});

  final AccountRepository repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(
    GetAccountTransactionsParams params,
  ) {
    return repository.getTransactions(
      accountId: params.accountId,
      from: params.from,
      to: params.to,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
