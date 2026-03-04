import 'package:accounts/data/datasources/accounts_api_client.dart';
import 'package:accounts/data/datasources/remote_account_datasource.dart';
import 'package:accounts/data/models/account_dto.dart';
import 'package:accounts/data/models/transaction_dto.dart';

/// Retrofit-based implementation of [RemoteAccountDataSource].
class RemoteAccountDataSourceImpl implements RemoteAccountDataSource {
  const RemoteAccountDataSourceImpl({required this.apiClient});

  final AccountsApiClient apiClient;

  @override
  Future<List<AccountDto>> getAccounts() => apiClient.getAccounts();

  @override
  Future<AccountDto> getAccountDetail(String id) =>
      apiClient.getAccountDetail(id);

  @override
  Future<List<TransactionDto>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  }) =>
      apiClient.getTransactions(
        accountId,
        from: from?.toIso8601String(),
        to: to?.toIso8601String(),
        page: page,
        pageSize: pageSize,
      );
}
