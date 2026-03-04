import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../repositories/account_repository.dart';

part 'generated/get_account_transactions_usecase.freezed.dart';

@freezed
abstract class GetAccountTransactionsParams
    with _$GetAccountTransactionsParams {
  const factory GetAccountTransactionsParams({
    required String accountId,
    DateTime? from,
    DateTime? to,
    @Default(0) int page,
    @Default(20) int pageSize,
  }) = _GetAccountTransactionsParams;
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
