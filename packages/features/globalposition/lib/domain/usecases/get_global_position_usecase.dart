import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:globalposition/domain/repositories/global_position_repository.dart';

/// The result data of the global position use case.
class GlobalPositionData extends Equatable {
  const GlobalPositionData({
    required this.accounts,
    required this.recentTransactions,
  });

  final List<Account> accounts;
  final List<Transaction> recentTransactions;

  @override
  List<Object?> get props => [accounts, recentTransactions];
}

/// Fetches the global position: all accounts and recent transactions.
class GetGlobalPositionUseCase extends UseCase<GlobalPositionData, NoParams> {
  GetGlobalPositionUseCase({required this.repository});

  final GlobalPositionRepository repository;

  @override
  Future<Either<Failure, GlobalPositionData>> call(NoParams params) async {
    final accountsResult = await repository.getAccounts();

    return accountsResult.match(
      Left.new,
      (accounts) async {
        final transactionsResult = await repository.getRecentTransactions();
        return transactionsResult.match(
          Left.new,
          (transactions) => Right(
            GlobalPositionData(
              accounts: accounts,
              recentTransactions: transactions,
            ),
          ),
        );
      },
    );
  }
}
