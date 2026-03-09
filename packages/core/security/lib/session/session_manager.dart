import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/security_providers.dart';
import '../storage/secure_storage_service.dart';

/// Contract for session lifecycle management.
///
/// The session is considered active when a valid access token exists and
/// the inactivity timeout has not been exceeded.
abstract class SessionManager {
  Future<void> saveToken(String accessToken);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> clearSession();
  Future<bool> isSessionValid();
  Future<void> recordActivity();
  Future<String?> refreshToken();
}

/// Reactive implementation of [SessionManager] as an [AsyncNotifier].
///
/// The notifier state (`bool`) represents whether the session is active.
/// [saveToken] sets it to `true`, [clearSession] sets it to `false`.
/// The router watches this state to trigger redirects.
class SessionManagerNotifier extends AsyncNotifier<bool>
    implements SessionManager {
  SecureStorageService get _secureStorage =>
      ref.read(SecurityProviders.secureStorage);

  Duration get sessionTimeout => const Duration(minutes: 5);

  static const _tag = 'SessionManager';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _lastActivityKey = 'last_activity';

  @override
  Future<bool> build() => isSessionValid();

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveToken(String accessToken) async {
    await _secureStorage.write(_accessTokenKey, accessToken);
    await _recordActivity();
    state = const AsyncData(true);
    developer.log('Access token saved', name: _tag);
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.read(_accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(_refreshTokenKey, refreshToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(_refreshTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
    await _secureStorage.delete(_lastActivityKey);
    state = const AsyncData(false);
    developer.log('Session cleared', name: _tag);
  }

  @override
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

  @override
  Future<void> recordActivity() async {
    await _recordActivity();
  }

  /// Placeholder for token refresh logic.
  ///
  /// In a real implementation this would call the auth API to exchange
  /// the refresh token for a new access token.
  @override
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
