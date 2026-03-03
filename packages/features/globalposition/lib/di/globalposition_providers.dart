import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:globalposition/data/repositories/global_position_repository_impl.dart';
import 'package:globalposition/domain/repositories/global_position_repository.dart';

/// Riverpod providers for the global position feature.
abstract final class GlobalPositionProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemoteGlobalPositionDataSource>((
    ref,
  ) {
    throw UnimplementedError('Must be overridden');
  });

  /// Repository for global position operations.
  static final repository = Provider<GlobalPositionRepository>((ref) {
    return GlobalPositionRepositoryImpl(
      remoteDataSource: ref.watch(GlobalPositionProviders.remoteDataSource),
    );
  });
}
