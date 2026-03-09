import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security/security.dart';

/// Whether the user has completed onboarding, persisted in [SecureStorageService].
class HasSeenOnboardingNotifier extends AsyncNotifier<bool> {
  static const _key = 'has_seen_onboarding';

  @override
  Future<bool> build() async {
    final storage = ref.read(SecurityProviders.secureStorage);
    final value = await storage.read(_key);
    return value == 'true';
  }

  /// Marks onboarding as completed and persists the flag.
  Future<void> markSeen() async {
    final storage = ref.read(SecurityProviders.secureStorage);
    await storage.write(_key, 'true');
    state = const AsyncData(true);
  }
}

/// Riverpod providers for the onboarding feature.
abstract final class OnboardingProviders {
  /// Whether the user has completed onboarding (persisted).
  static final hasSeenOnboarding =
      AsyncNotifierProvider<HasSeenOnboardingNotifier, bool>(
    HasSeenOnboardingNotifier.new,
  );
}
