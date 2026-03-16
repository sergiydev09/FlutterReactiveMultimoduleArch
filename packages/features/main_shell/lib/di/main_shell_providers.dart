import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/shell_config_datasource.dart';
import '../data/repositories/shell_config_repository_impl.dart';
import '../domain/repositories/shell_config_repository.dart';
import '../domain/usecases/get_shell_config_usecase.dart';

/// Riverpod providers for the main_shell feature.
abstract final class MainShellProviders {
  /// Shell config datasource. Override per entry point.
  static final dataSource = Provider<ShellConfigDataSource>((ref) {
    throw UnimplementedError('Must be overridden per entry point');
  });

  /// Shell config repository.
  static final repository = Provider<ShellConfigRepository>((ref) {
    return ShellConfigRepositoryImpl(
      dataSource: ref.watch(MainShellProviders.dataSource),
    );
  });

  /// Use case to retrieve shell configuration.
  static final getShellConfigUseCase = Provider<GetShellConfigUseCase>((ref) {
    return GetShellConfigUseCase(
      repository: ref.watch(MainShellProviders.repository),
    );
  });
}
