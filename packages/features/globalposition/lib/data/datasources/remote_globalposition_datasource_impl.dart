import 'package:globalposition/data/datasources/globalposition_api_client.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:globalposition/data/models/gp_account_dto.dart';
import 'package:globalposition/data/models/gp_transaction_dto.dart';

/// Retrofit-based implementation of [RemoteGlobalPositionDataSource].
class RemoteGlobalPositionDataSourceImpl
    implements RemoteGlobalPositionDataSource {
  const RemoteGlobalPositionDataSourceImpl({required this.apiClient});

  final GlobalPositionApiClient apiClient;

  @override
  Future<List<GpAccountDto>> getAccounts() => apiClient.getAccounts();

  @override
  Future<List<GpTransactionDto>> getRecentTransactions() =>
      apiClient.getRecentTransactions();
}
