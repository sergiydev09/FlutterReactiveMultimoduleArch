import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/shell_config.dart';
import '../repositories/shell_config_repository.dart';

/// Loads the shell navigation configuration.
class GetShellConfigUseCase extends UseCase<ShellConfig, NoParams> {
  GetShellConfigUseCase({required this.repository});

  final ShellConfigRepository repository;

  @override
  Future<Either<Failure, ShellConfig>> call(NoParams params) =>
      repository.getShellConfig();
}
