import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../biometric/biometric_service.dart';
import '../notifiers/biometric_enabled_notifier.dart';
import '../notifiers/current_user_name_notifier.dart';
import '../notifiers/has_seen_onboarding_notifier.dart';
import '../notifiers/is_logged_in_notifier.dart';
import '../session/session_manager.dart';
import '../storage/secure_storage_service.dart';

/// Riverpod providers for the security module.
abstract final class SecurityProviders {
  /// Secure key-value storage.
  static final secureStorage = Provider<SecureStorageService>((ref) {
    return SecureStorageService();
  });

  /// Session manager backed by [secureStorage].
  static final sessionManager = Provider<SessionManager>((ref) {
    return SessionManager(
      secureStorage: ref.watch(SecurityProviders.secureStorage),
    );
  });

  /// Biometric authentication service.
  static final biometricService = Provider<BiometricService>((ref) {
    return BiometricService();
  });

  /// User biometric login preference, persisted in [secureStorage].
  static final biometricEnabled =
      AsyncNotifierProvider<BiometricEnabledNotifier, bool>(
    BiometricEnabledNotifier.new,
  );

  /// Whether the user is currently logged in.
  static final isLoggedIn = NotifierProvider<IsLoggedInNotifier, bool>(
    IsLoggedInNotifier.new,
  );

  /// Display name of the currently logged-in user.
  static final currentUserName =
      NotifierProvider<CurrentUserNameNotifier, String>(
    CurrentUserNameNotifier.new,
  );

  /// Whether the user has completed the onboarding flow.
  static final hasSeenOnboarding =
      NotifierProvider<HasSeenOnboardingNotifier, bool>(
    HasSeenOnboardingNotifier.new,
  );
}
