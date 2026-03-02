import 'package:accounts/data/models/account_model.dart';
import 'package:accounts/data/models/transaction_model.dart';

/// Remote data source contract for account operations.
abstract class RemoteAccountDataSource {
  /// Fetches account detail by [id].
  Future<AccountModel> getAccountDetail(String id);

  /// Fetches transactions for [accountId] with pagination.
  Future<List<TransactionModel>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  });
}
