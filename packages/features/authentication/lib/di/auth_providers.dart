import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security/security.dart';
import '../data/datasources/auth_api_client.dart';
import '../data/datasources/remote_auth_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/biometric_login_usecase.dart';

/// Riverpod providers for the authentication feature.
abstract final class AuthProviders {
  /// Retrofit API client.
  static final apiClient = Provider<AuthApiClient>((ref) {
    return AuthApiClient(ref.watch(CommonProviders.dio));
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
      biometricService: ref.watch(SecurityProviders.biometricService),
      sessionManager: ref.read(SecurityProviders.sessionManager.notifier),
      secureStorage: ref.watch(SecurityProviders.secureStorage),
    );
  });

  /// Use case for biometric login.
  static final biometricLoginUseCase = Provider<BiometricLoginUseCase>((ref) {
    return BiometricLoginUseCase(
      repository: ref.watch(AuthProviders.repository),
    );
  });
}
