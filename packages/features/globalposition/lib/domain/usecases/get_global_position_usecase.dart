import 'package:common/error/failures.dart';
import 'package:common/extensions/either_extensions.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:globalposition/domain/repositories/global_position_repository.dart';

part 'generated/get_global_position_usecase.freezed.dart';

@freezed
abstract class GlobalPositionData with _$GlobalPositionData {
  const factory GlobalPositionData({
    required List<Account> accounts,
    required List<Transaction> recentTransactions,
  }) = _GlobalPositionData;
}

/// Fetches the global position: all accounts and recent transactions.
class GetGlobalPositionUseCase extends UseCase<GlobalPositionData, NoParams> {
  GetGlobalPositionUseCase({required this.repository});

  final GlobalPositionRepository repository;

  @override
  Future<Either<Failure, GlobalPositionData>> call(NoParams params) async {
    final accountsResult = await repository.getAccounts();

    return accountsResult.match(
      (f) => f.toLeft(),
      (accounts) async {
        final transactionsResult = await repository.getRecentTransactions();
        return transactionsResult.match(
          (f) => f.toLeft(),
          (transactions) => GlobalPositionData(
            accounts: accounts,
            recentTransactions: transactions,
          ).toRight(),
        );
      },
    );
  }
}
