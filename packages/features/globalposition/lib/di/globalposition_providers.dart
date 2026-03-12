import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/globalposition_api_client.dart';
import '../data/datasources/remote_globalposition_datasource.dart';
import '../data/repositories/global_position_repository_impl.dart';
import '../domain/repositories/global_position_repository.dart';
import '../domain/usecases/get_global_position_usecase.dart';

/// Riverpod providers for the global position feature.
abstract final class GlobalPositionProviders {
  /// Retrofit API client.
  static final apiClient = Provider<GlobalPositionApiClient>((ref) {
    return GlobalPositionApiClient(ref.watch(CommonProviders.dio));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource =
      Provider<RemoteGlobalPositionDataSource>((ref) {
    return RemoteGlobalPositionDataSource(
      apiClient: ref.watch(GlobalPositionProviders.apiClient),
    );
  });

  /// Repository for global position operations.
  static final repository = Provider<GlobalPositionRepository>((ref) {
    return GlobalPositionRepositoryImpl(
      remoteDataSource: ref.watch(GlobalPositionProviders.remoteDataSource),
    );
  });

  /// Use case to retrieve global position data.
  static final getGlobalPositionUseCase = Provider<GetGlobalPositionUseCase>((ref) {
    return GetGlobalPositionUseCase(
      repository: ref.watch(GlobalPositionProviders.repository),
    );
  });
}
