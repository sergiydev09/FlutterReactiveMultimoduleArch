import '../../domain/entities/shell_config.dart';

/// Contract for loading shell configuration data.
///
/// In dev, uses a static implementation. In production, can be replaced
/// with a remote config datasource.
abstract class ShellConfigDataSource {
  Future<ShellConfig> getShellConfig();
}
