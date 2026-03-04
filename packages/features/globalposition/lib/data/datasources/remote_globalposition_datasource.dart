import 'package:globalposition/data/models/gp_account_dto.dart';
import 'package:globalposition/data/models/gp_transaction_dto.dart';

/// Remote data source contract for global position data.
abstract class RemoteGlobalPositionDataSource {
  /// Fetches all accounts for the authenticated user.
  Future<List<GpAccountDto>> getAccounts();

  /// Fetches recent transactions across all accounts.
  Future<List<GpTransactionDto>> getRecentTransactions();
}
