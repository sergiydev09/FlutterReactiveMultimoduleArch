import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/security_providers.dart';
import 'user_info.dart';
import 'user_storage_keys.dart';

/// Loads the persisted [UserInfo] from SecureStorage.
///
/// Call [refresh] after login to re-read the stored user data.
/// Call [clear] on logout.
class UserSessionNotifier extends AsyncNotifier<UserInfo?> {
  @override
  Future<UserInfo?> build() => _loadFromStorage();

  /// Re-reads user data from storage (call after login persists user).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadFromStorage());
  }

  /// Clears the cached user info (call on logout).
  void clear() {
    state = const AsyncData(null);
  }

  Future<UserInfo?> _loadFromStorage() async {
    final storage = ref.read(SecurityProviders.secureStorage);

    final firstName = await storage.read(UserStorageKeys.firstName);
    final lastName = await storage.read(UserStorageKeys.lastName);
    final email = await storage.read(UserStorageKeys.email);

    if (firstName == null || lastName == null || email == null) {
      return null;
    }

    final fullName = '$firstName $lastName';
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';

    return UserInfo(
      fullName: fullName,
      email: email,
      initials: '$first$last',
    );
  }
}
