import 'package:common/config/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security/session/session_manager.dart';
import 'package:security/storage/secure_storage_service.dart';

// Re-export feature providers so main_dev.dart keeps compiling.
export 'package:accounts/di/accounts_providers.dart';
export 'package:authentication/di/auth_providers.dart';
export 'package:cards/di/cards_providers.dart';
export 'package:globalposition/di/globalposition_providers.dart';
export 'package:notifications_feature/di/notifications_providers.dart';
export 'package:payments/di/payments_providers.dart';
export 'package:promotions/di/promotions_providers.dart';

// Environment
class EnvironmentNotifier extends Notifier<Environment> {
  @override
  Environment build() => Environment.mock;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set(Environment value) => state = value;
}

final environmentProvider = NotifierProvider<EnvironmentNotifier, Environment>(
  EnvironmentNotifier.new,
);

// Security
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(secureStorage: ref.watch(secureStorageProvider));
});

// Auth state
class IsLoggedInNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set({required bool value}) => state = value;
}

class CurrentUserNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set(String value) => state = value;
}

class HasSeenOnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set({required bool value}) => state = value;
}

final isLoggedInProvider = NotifierProvider<IsLoggedInNotifier, bool>(
  IsLoggedInNotifier.new,
);
final currentUserNameProvider =
    NotifierProvider<CurrentUserNameNotifier, String>(
      CurrentUserNameNotifier.new,
    );
final hasSeenOnboardingProvider =
    NotifierProvider<HasSeenOnboardingNotifier, bool>(
      HasSeenOnboardingNotifier.new,
    );
