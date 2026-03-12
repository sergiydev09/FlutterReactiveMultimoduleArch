import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/accounts_api_client.dart';
import '../data/datasources/remote_account_datasource.dart';
import '../data/repositories/account_repository_impl.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/usecases/get_account_detail_usecase.dart';
import '../domain/usecases/get_account_transactions_usecase.dart';
import '../domain/usecases/get_accounts_usecase.dart';

/// Riverpod providers for the accounts feature.
abstract final class AccountProviders {
  /// Retrofit API client.
  static final apiClient = Provider<AccountsApiClient>((ref) {
    return AccountsApiClient(ref.watch(CommonProviders.dio));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource = Provider<RemoteAccountDataSource>((ref) {
    return RemoteAccountDataSource(
      apiClient: ref.watch(AccountProviders.apiClient),
    );
  });

  /// Repository for account operations.
  static final repository = Provider<AccountRepository>((ref) {
    return AccountRepositoryImpl(
      remoteDataSource: ref.watch(AccountProviders.remoteDataSource),
    );
  });

  /// Use case to retrieve the list of accounts.
  static final getAccountsUseCase = Provider<GetAccountsUseCase>((ref) {
    return GetAccountsUseCase(repository: ref.watch(AccountProviders.repository));
  });

  /// Use case to retrieve account detail.
  static final getAccountDetailUseCase = Provider<GetAccountDetailUseCase>((ref) {
    return GetAccountDetailUseCase(repository: ref.watch(AccountProviders.repository));
  });

  /// Use case to retrieve account transactions.
  static final getAccountTransactionsUseCase = Provider<GetAccountTransactionsUseCase>((ref) {
    return GetAccountTransactionsUseCase(repository: ref.watch(AccountProviders.repository));
  });
}
