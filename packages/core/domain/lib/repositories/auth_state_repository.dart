import '../entities/user.dart';

/// Abstract contract for accessing and observing the authentication state.
///
/// Implementations may use secure storage, shared preferences, or any
/// persistence mechanism.
abstract class AuthStateRepository {
  /// Whether the user is currently logged in.
  Future<bool> get isLoggedIn;

  /// Stream that emits `true`/`false` whenever the login state changes.
  Stream<bool> get authStateChanges;

  /// Returns the current authenticated user, or `null` if not logged in.
  Future<User?> get currentUser;

  /// Returns the current access token, or `null` if not available.
  Future<String?> get token;

  /// Returns the current refresh token, or `null` if not available.
  Future<String?> get refreshToken;

  /// Persists the user session after a successful login.
  Future<void> saveSession({
    required User user,
    required String accessToken,
    required String refreshToken,
  });

  /// Updates the stored access token (e.g. after a token refresh).
  Future<void> updateAccessToken(String accessToken);

  /// Clears all persisted auth state (logout).
  Future<void> clearSession();
}
