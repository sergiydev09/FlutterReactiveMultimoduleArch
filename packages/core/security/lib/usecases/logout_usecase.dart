import 'package:common/common.dart';
import 'package:fpdart/fpdart.dart';

import '../session/logout_datasource.dart';

/// Clears the active session and user state.
///
/// This shared use case is consumed by any feature that needs to log out the
/// current user (e.g. settings, main shell). It delegates to
/// [LogoutDataSource] which clears session tokens and the in-memory user
/// identity without touching any feature-specific data.
///
/// Belongs to `core/security` because:
/// - It is used by more than one feature.
/// - It operates exclusively on shared infrastructure (session, token, storage).
/// - It has no dependency on any feature-specific model or logic.
class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase({required this.logoutDataSource});

  final LogoutDataSource logoutDataSource;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await logoutDataSource.logout();
      return null.toRight();
    } on Exception catch (e) {
      return Failure.server(message: e.toString()).toLeft();
    }
  }
}
