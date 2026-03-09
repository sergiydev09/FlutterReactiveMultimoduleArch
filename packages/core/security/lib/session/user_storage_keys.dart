/// Shared SecureStorage keys for persisted user data.
///
/// Used by both the authentication repository (write) and
/// `UserSessionNotifier` (read).
abstract final class UserStorageKeys {
  static const id = 'user_id';
  static const dni = 'user_dni';
  static const firstName = 'user_first_name';
  static const lastName = 'user_last_name';
  static const email = 'user_email';
  static const createdAt = 'user_created_at';
  static const phone = 'user_phone';
}
