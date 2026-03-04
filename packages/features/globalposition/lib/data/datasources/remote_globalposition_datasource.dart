import '../models/gp_account_dto.dart';
import '../models/gp_transaction_dto.dart';
import './globalposition_api_client.dart';

/// Remote data source for global position data.
class RemoteGlobalPositionDataSource {
  const RemoteGlobalPositionDataSource(
      {required GlobalPositionApiClient apiClient})
      : _apiClient = apiClient;

  final GlobalPositionApiClient _apiClient;

  Future<List<GpAccountDto>> getAccounts() => _apiClient.getAccounts();

  Future<List<GpTransactionDto>> getRecentTransactions() =>
      _apiClient.getRecentTransactions();
}
