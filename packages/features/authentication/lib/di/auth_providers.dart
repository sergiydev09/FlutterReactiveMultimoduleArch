import 'package:authentication/data/datasources/auth_api_client.dart';
import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/repositories/auth_repository_impl.dart';
import 'package:authentication/domain/repositories/auth_repository.dart';
import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod providers for the authentication feature.
abstract final class AuthProviders {
  /// Retrofit API client.
  static final apiClient = Provider<AuthApiClient>((ref) {
    return AuthApiClient(ref.watch(dioProvider));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource = Provider<RemoteAuthDataSource>((ref) {
    return RemoteAuthDataSource(
      apiClient: ref.watch(AuthProviders.apiClient),
    );
  });

  /// Repository for authentication operations.
  static final repository = Provider<AuthRepository>((ref) {
    return AuthRepositoryImpl(
      remoteDataSource: ref.watch(AuthProviders.remoteDataSource),
    );
  });
}
