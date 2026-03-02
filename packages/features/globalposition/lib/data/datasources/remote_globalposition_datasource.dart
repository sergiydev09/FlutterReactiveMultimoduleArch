import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';

/// Remote data source contract for global position data.
abstract class RemoteGlobalPositionDataSource {
  /// Fetches all accounts for the authenticated user.
  Future<List<Account>> getAccounts();

  /// Fetches recent transactions across all accounts.
  Future<List<Transaction>> getRecentTransactions();
}
