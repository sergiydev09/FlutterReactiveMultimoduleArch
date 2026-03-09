import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../attestation/integrity_attestation_service.dart';
import '../biometric/biometric_service.dart';
import '../clipboard/clipboard_protection_service.dart';
import '../notifiers/biometric_enabled_notifier.dart';
import '../screen/screen_protection_service.dart';
import '../session/session_manager.dart';
import '../session/user_info.dart';
import '../session/user_session_notifier.dart';
import '../storage/secure_storage_service.dart';
import '../threat_detection/device_threat_detector.dart';

/// Riverpod providers for the security module.
abstract final class SecurityProviders {
  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Secure key-value storage.
  static final secureStorage = Provider<SecureStorageService>((ref) {
    return SecureStorageService();
  });

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  /// Reactive session manager. State (`bool`) = session is active.
  ///
  /// Use `.notifier` to access the [SessionManagerNotifier] which implements
  /// [SessionManager] for token/session operations.
  static final sessionManager =
      AsyncNotifierProvider<SessionManagerNotifier, bool>(
    SessionManagerNotifier.new,
  );

  /// Synchronous convenience — `true` when the session is active.
  /// Defaults to `false` while loading (safe: user sees login).
  static final isSessionActive = Provider<bool>((ref) {
    return ref.watch(sessionManager).value ?? false;
  });

  /// Persisted user identity (name, email, initials).
  ///
  /// Call `.notifier.refresh()` after login, `.notifier.clear()` on logout.
  static final userSession =
      AsyncNotifierProvider<UserSessionNotifier, UserInfo?>(
    UserSessionNotifier.new,
  );

  // ---------------------------------------------------------------------------
  // Biometrics
  // ---------------------------------------------------------------------------

  /// Biometric authentication service.
  static final biometricService = Provider<BiometricService>((ref) {
    return BiometricService();
  });

  /// User biometric login preference, persisted in [secureStorage].
  static final biometricEnabled =
      AsyncNotifierProvider<BiometricEnabledNotifier, bool>(
    BiometricEnabledNotifier.new,
  );

  // ---------------------------------------------------------------------------
  // Threat detection (local, no telemetry)
  // ---------------------------------------------------------------------------

  /// Device threat detector. Override with a no-op in dev to avoid
  /// blocking on emulators.
  static final threatDetector = Provider<DeviceThreatDetector>((ref) {
    return DeviceThreatDetectorImpl();
  });

  // ---------------------------------------------------------------------------
  // Screen protection (FLAG_SECURE)
  // ---------------------------------------------------------------------------

  /// Screen capture/recording protection service.
  static final screenProtection = Provider<ScreenProtectionService>((ref) {
    return ScreenProtectionService();
  });

  // ---------------------------------------------------------------------------
  // Clipboard protection
  // ---------------------------------------------------------------------------

  /// Clipboard protection with auto-clear for sensitive data.
  static final clipboardProtection = Provider<ClipboardProtectionService>(
    (ref) {
      return ClipboardProtectionService();
    },
  );

  // ---------------------------------------------------------------------------
  // Integrity attestation (Play Integrity / App Attest)
  // ---------------------------------------------------------------------------

  /// Attestation service. Defaults to mock — override in main_staging/prod
  /// with [IntegrityAttestationServiceImpl] providing the GCP project ID.
  static final integrityAttestation =
      Provider<IntegrityAttestationService>((ref) {
    return MockIntegrityAttestationService();
  });
}
