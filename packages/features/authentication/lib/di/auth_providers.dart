import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/repositories/auth_repository_impl.dart';
import 'package:authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod providers for the authentication feature.
abstract final class AuthProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemoteAuthDataSource>((ref) {
    throw UnimplementedError('Must be overridden');
  });

  /// Repository for authentication operations.
  static final repository = Provider<AuthRepository>((ref) {
    return AuthRepositoryImpl(
      remoteDataSource: ref.watch(AuthProviders.remoteDataSource),
    );
  });
}
