import 'package:accounts/data/datasources/accounts_api_client.dart';
import 'package:accounts/data/datasources/remote_account_datasource.dart';
import 'package:accounts/data/repositories/account_repository_impl.dart';
import 'package:accounts/domain/repositories/account_repository.dart';
import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}
