import 'package:accounts/data/datasources/remote_account_datasource.dart';
import 'package:accounts/data/repositories/account_repository_impl.dart';
import 'package:accounts/domain/repositories/account_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod providers for the accounts feature.
abstract final class AccountProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemoteAccountDataSource>((ref) {
    throw UnimplementedError('Must be overridden');
  });

  /// Repository for account operations.
  static final repository = Provider<AccountRepository>((ref) {
    return AccountRepositoryImpl(
      remoteDataSource: ref.watch(AccountProviders.remoteDataSource),
    );
  });
}
