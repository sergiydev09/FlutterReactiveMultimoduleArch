import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/account_dto.dart';
import '../models/transaction_dto.dart';

part 'generated/accounts_api_client.g.dart';

@RestApi()
abstract class AccountsApiClient {
  factory AccountsApiClient(Dio dio, {String? baseUrl}) = _AccountsApiClient;

  @GET('/accounts')
  Future<List<AccountDto>> getAccounts();

  @GET('/accounts/{id}')
  Future<AccountDto> getAccountDetail(@Path('id') String id);

  @GET('/accounts/{id}/transactions')
  Future<List<TransactionDto>> getTransactions(
    @Path('id') String accountId, {
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('page') int page = 0,
    @Query('page_size') int pageSize = 20,
  });
}
