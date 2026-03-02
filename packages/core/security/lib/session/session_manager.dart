import 'dart:developer' as developer;

import 'package:security/storage/secure_storage_service.dart';

/// Manages the user session: token persistence, validity checks,
/// and session lifecycle.
class SessionManager {
  SessionManager({
    required SecureStorageService secureStorage,
    this.sessionTimeout = const Duration(minutes: 5),
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  /// Duration after which the session is considered expired due to inactivity.
  final Duration sessionTimeout;

  static const _tag = 'SessionManager';

  // Storage keys.
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _lastActivityKey = 'last_activity';

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  /// Persists the access token.
  Future<void> saveToken(String accessToken) async {
    await _secureStorage.write(_accessTokenKey, accessToken);
    await _recordActivity();
    developer.log('Access token saved', name: _tag);
  }

  /// Retrieves the access token, or `null` if not stored.
  Future<String?> getToken() async {
    return _secureStorage.read(_accessTokenKey);
  }

  /// Persists the refresh token.
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(_refreshTokenKey, refreshToken);
  }

  /// Retrieves the refresh token, or `null` if not stored.
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(_refreshTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------

  /// Clears all session data (tokens and activity timestamps).
  Future<void> clearSession() async {
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
    await _secureStorage.delete(_lastActivityKey);
    developer.log('Session cleared', name: _tag);
  }

  /// Returns `true` if the session is valid (token exists and not expired
  /// due to inactivity).
  Future<bool> isSessionValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final lastActivityStr = await _secureStorage.read(_lastActivityKey);
    if (lastActivityStr == null) return false;

    final lastActivity =
        DateTime.tryParse(lastActivityStr) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final elapsed = DateTime.now().difference(lastActivity);

    return elapsed < sessionTimeout;
  }

  /// Records the current time as the last user activity.
  /// Call this on meaningful user interactions to keep the session alive.
  Future<void> recordActivity() async {
    await _recordActivity();
  }

  /// Placeholder for token refresh logic.
  ///
  /// In a real implementation this would call the auth API to exchange
  /// the refresh token for a new access token.
  Future<String?> refreshToken() async {
    final currentRefreshToken = await getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      developer.log('No refresh token available', name: _tag);
      return null;
    }

    // TODO(auth): Implement actual token refresh API call.
    developer.log(
      'Token refresh requested (placeholder)',
      name: _tag,
    );
    return null;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _recordActivity() async {
    await _secureStorage.write(
      _lastActivityKey,
      DateTime.now().toIso8601String(),
    );
  }
}
