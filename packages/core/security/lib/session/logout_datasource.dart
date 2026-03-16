import 'session_manager.dart';
import 'user_session_notifier.dart';

/// Contract for performing a full session logout.
///
/// Implementations must clear both the persisted session tokens and the
/// in-memory user identity so the router redirect guard picks up the change.
abstract class LogoutDataSource {
  Future<void> logout();
}

/// Default implementation — delegates to [SessionManager.clearSession] and
/// [UserSessionNotifier.clear].
///
/// Both dependencies are owned by `core/security`, so this implementation
/// lives here rather than in any feature layer.
class LogoutDataSourceImpl implements LogoutDataSource {
  const LogoutDataSourceImpl({
    required this.sessionManager,
    required this.userSessionNotifier,
  });

  final SessionManager sessionManager;
  final UserSessionNotifier userSessionNotifier;

  @override
  Future<void> logout() async {
    await sessionManager.clearSession();
    userSessionNotifier.clear();
  }
}
