import 'package:common/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/shell_config.dart';

/// Contract for loading shell navigation configuration.
abstract class ShellConfigRepository {
  Future<Either<Failure, ShellConfig>> getShellConfig();
}
