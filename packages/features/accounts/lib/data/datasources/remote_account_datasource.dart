import '../models/account_dto.dart';
import '../models/transaction_dto.dart';
import './accounts_api_client.dart';

/// Remote data source for account operations.
class RemoteAccountDataSource {
  const RemoteAccountDataSource({required AccountsApiClient apiClient})
      : _apiClient = apiClient;

  final AccountsApiClient _apiClient;

  Future<List<AccountDto>> getAccounts() => _apiClient.getAccounts();

  Future<AccountDto> getAccountDetail(String id) =>
      _apiClient.getAccountDetail(id);

  Future<List<TransactionDto>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  }) =>
      _apiClient.getTransactions(
        accountId,
        from: from?.toIso8601String(),
        to: to?.toIso8601String(),
        page: page,
        pageSize: pageSize,
      );
}
