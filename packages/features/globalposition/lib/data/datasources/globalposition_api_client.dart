import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/gp_account_dto.dart';
import '../models/gp_transaction_dto.dart';

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
