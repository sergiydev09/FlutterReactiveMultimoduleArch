/// Lightweight user identity data loaded from persisted session storage.
///
/// This avoids coupling the security package to `core/domain`'s `User` entity.
/// Features that need full user details should load the `User` entity directly.
class UserInfo {
  const UserInfo({
    required this.fullName,
    required this.email,
    required this.initials,
  });

  final String fullName;
  final String email;
  final String initials;
}
