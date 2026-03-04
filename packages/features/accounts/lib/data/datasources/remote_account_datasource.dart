import 'package:accounts/data/models/account_dto.dart';
import 'package:accounts/data/models/transaction_dto.dart';

/// Remote data source contract for account operations.
abstract class RemoteAccountDataSource {
  /// Fetches all accounts for the current user.
  Future<List<AccountDto>> getAccounts();

  /// Fetches account detail by [id].
  Future<AccountDto> getAccountDetail(String id);

  /// Fetches transactions for [accountId] with pagination.
  Future<List<TransactionDto>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  });
}
