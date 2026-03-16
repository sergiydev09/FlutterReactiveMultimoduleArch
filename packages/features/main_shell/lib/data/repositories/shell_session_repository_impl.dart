import 'package:common/common.dart';
import 'package:fpdart/fpdart.dart';
import 'package:security/security.dart';
import '../../domain/repositories/shell_session_repository.dart';

/// Concrete implementation of [ShellSessionRepository].
///
/// Delegates session teardown to the shared [LogoutDataSource] from
/// `core/security`, avoiding duplication of the
/// `clearSession + clear` sequence across features.
class ShellSessionRepositoryImpl implements ShellSessionRepository {
  const ShellSessionRepositoryImpl({
    required this.logoutDataSource,
  });

  final LogoutDataSource logoutDataSource;

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await logoutDataSource.logout();
      return null.toRight();
    } on Exception catch (e) {
      return Failure.server(message: e.toString()).toLeft();
    }
  }
}
