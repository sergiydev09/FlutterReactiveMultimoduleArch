import 'package:common/error/failures.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:fpdart/fpdart.dart';

/// Repository contract for account operations.
abstract class AccountRepository {
  /// Fetches all accounts for the current user.
  Future<Either<Failure, List<Account>>> getAccounts();

  /// Fetches the detail of an account by its [id].
  Future<Either<Failure, Account>> getAccountDetail(String id);

  /// Fetches transactions for a given [accountId] within a date range.
  ///
  /// Supports pagination via [page] and [pageSize].
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  });
}
