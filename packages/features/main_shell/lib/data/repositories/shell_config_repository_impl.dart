import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/shell_config.dart';
import '../../domain/repositories/shell_config_repository.dart';
import '../datasources/shell_config_datasource.dart';

/// Concrete [ShellConfigRepository] backed by a [ShellConfigDataSource].
class ShellConfigRepositoryImpl implements ShellConfigRepository {
  const ShellConfigRepositoryImpl({required this.dataSource});

  final ShellConfigDataSource dataSource;

  @override
  Future<Either<Failure, ShellConfig>> getShellConfig() =>
      safeApiCall(dataSource.getShellConfig);
}
