import 'package:globalposition/data/datasources/globalposition_api_client.dart';
import 'package:globalposition/data/models/gp_account_dto.dart';
import 'package:globalposition/data/models/gp_transaction_dto.dart';

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
