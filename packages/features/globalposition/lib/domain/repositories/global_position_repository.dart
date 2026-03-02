import 'package:common/error/failures.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';

/// Repository contract for the global position (home screen) feature.
abstract class GlobalPositionRepository {
  /// Fetches all accounts for the current user.
  Future<Either<Failure, List<Account>>> getAccounts();

  /// Fetches recent transactions across all accounts.
  Future<Either<Failure, List<Transaction>>> getRecentTransactions();
}
