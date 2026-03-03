import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security/session/session_manager.dart';
import 'package:security/storage/secure_storage_service.dart';

// -- Infrastructure --

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(secureStorage: ref.watch(secureStorageProvider));
});

// -- Session state --

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
