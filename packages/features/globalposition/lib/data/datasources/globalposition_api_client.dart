import 'package:dio/dio.dart';
import 'package:globalposition/data/models/gp_account_dto.dart';
import 'package:globalposition/data/models/gp_transaction_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/globalposition_api_client.g.dart';

@RestApi()
abstract class GlobalPositionApiClient {
  factory GlobalPositionApiClient(Dio dio, {String? baseUrl}) =
      _GlobalPositionApiClient;

  @GET('/global-position/accounts')
  Future<List<GpAccountDto>> getAccounts();

  @GET('/global-position/transactions/recent')
  Future<List<GpTransactionDto>> getRecentTransactions();
}
