import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/data/datasources/globalposition_api_client.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource_impl.dart';
import 'package:globalposition/data/repositories/global_position_repository_impl.dart';
import 'package:globalposition/domain/repositories/global_position_repository.dart';

/// Riverpod providers for the global position feature.
abstract final class GlobalPositionProviders {
  /// Retrofit API client.
  static final apiClient = Provider<GlobalPositionApiClient>((ref) {
    return GlobalPositionApiClient(ref.watch(dioProvider));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource =
      Provider<RemoteGlobalPositionDataSource>((ref) {
    return RemoteGlobalPositionDataSourceImpl(
      apiClient: ref.watch(GlobalPositionProviders.apiClient),
    );
  });

  /// Repository for global position operations.
  static final repository = Provider<GlobalPositionRepository>((ref) {
    return GlobalPositionRepositoryImpl(
      remoteDataSource: ref.watch(GlobalPositionProviders.remoteDataSource),
    );
  });
}
