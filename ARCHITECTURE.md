# Architecture Reference

> Full architecture document: [flutter_banking_architecture.md](flutter_banking_architecture.md)

---

## Either conventions

### Rule: use `.toRight()` / `.toLeft()` — never construct `Right()` / `Left()` directly

Repository implementations and use cases must use the extension methods from `core/common` instead of the fpdart constructors.

```dart
// ✅ Correct
return (value == 'true').toRight();
return Failure.server(message: e.toString()).toLeft();
return null.toRight();

// ❌ Forbidden
return Right(value == 'true');
return Left(Failure.server(message: e.toString()));
return const Right(null);
```

**Where the extensions live:**

```
packages/core/common/lib/extensions/either_extensions.dart
```

```dart
extension RightExtension<T> on T {
  Either<L, T> toRight<L>() => Right(this);
}

extension LeftExtension on Failure {
  Either<Failure, R> toLeft<R>() => Left(this);
}
```

Exported from the barrel: `package:common/common.dart`

**Why:** Calling `Right(value)` / `Left(value)` is syntactically asymmetric and mixes construction styles across the codebase. The extension form reads left-to-right and keeps the happy-path value the subject of the expression.

**Scope:** Repository implementations (`data/repositories/`) and use cases (`domain/usecases/`). Test assertions may still use `Right(...)` / `Left(...)` directly for clarity.

---

## Common layer conventions

### Rule: features must never import data sources from other features

Feature data sources are internal to their package. No feature may import another feature's data source, API client, DTO, or repository implementation. Cross-feature communication happens exclusively through the router (`context.go / context.push`) and shared domain entities from `core/domain`.

```
✅  accounts   → core/common  (imports safeApiCall, DioFactory, Failure)
✅  accounts   → core/security (imports SecureStorageService, SessionManager)
❌  payments   → accounts/data/datasources  (FORBIDDEN)
❌  globalposition → authentication/data/datasources  (FORBIDDEN)
```

### Criteria for moving a method to the common layer

A datasource method (or the logic it encapsulates) is a candidate for `core/common` or `core/security` when **all three** of the following are true:

1. **Duplicated** — the same implementation appears in two or more features.
2. **No feature-specific dependency** — it does not reference any feature's DTOs, entities, or domain types.
3. **Owned by infrastructure** — it operates on shared services (HTTP, secure storage, session, biometrics) rather than on business data.

If a method needs slight adaptation per feature, extract the common logic to the shared layer and leave feature-specific wrappers in each feature's own data source.

### Folder structure

```
packages/core/common/lib/
├── di/
│   └── common_providers.dart         # Riverpod providers: Dio, environment, locale
├── error/
│   └── failures.dart                 # Sealed Failure class (ServerFailure, AuthFailure, …)
├── network/
│   ├── safe_api_call.dart            # safeApiCall<T>() — wraps any call in Either<Failure, T>
│   ├── dio_factory.dart              # DioFactory.create() — configured Dio instance
│   ├── auth_interceptor.dart         # Token injection + 401 refresh
│   ├── dio_exception_mapper.dart     # DioException → Failure mapping
│   ├── logging_interceptor.dart      # Dev-only request/response logging
│   ├── cache_config.dart             # In-memory 5-minute cache
│   └── certificate_pinning.dart      # SSL certificate pinning
└── usecases/
    └── usecase.dart                  # UseCase<T, Params> base class + NoParams

packages/core/security/lib/
├── di/
│   └── security_providers.dart       # SecurityProviders (includes logoutDataSource)
├── session/
│   ├── logout_datasource.dart        # LogoutDataSource (abstract) + LogoutDataSourceImpl
│   ├── session_manager.dart          # SessionManager interface + SessionManagerNotifier
│   └── user_session_notifier.dart    # UserSessionNotifier
└── …
```

### Before / after example: moving `logout()` to the common layer

**Before** — duplicated in two feature repository implementations:

```dart
// packages/features/settings/lib/data/repositories/settings_repository_impl.dart
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.sessionManager,       // security dependency
    required this.userSessionNotifier,  // security dependency
    …
  });

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await sessionManager.clearSession();   // ← duplicated
      userSessionNotifier.clear();           // ← duplicated
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }
}

// packages/features/main_shell/lib/data/repositories/shell_session_repository_impl.dart
class ShellSessionRepositoryImpl implements ShellSessionRepository {
  ShellSessionRepositoryImpl({
    required this.sessionManager,       // same security dependency
    required this.userSessionNotifier,  // same security dependency
  });

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await sessionManager.clearSession();   // ← exact copy
      userSessionNotifier.clear();           // ← exact copy
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }
}
```

**After** — single implementation in `core/security`, injected by both features:

```dart
// packages/core/security/lib/session/logout_datasource.dart
abstract class LogoutDataSource {
  Future<void> logout();
}

class LogoutDataSourceImpl implements LogoutDataSource {
  const LogoutDataSourceImpl({
    required this.sessionManager,
    required this.userSessionNotifier,
  });

  final SessionManager sessionManager;
  final UserSessionNotifier userSessionNotifier;

  @override
  Future<void> logout() async {
    await sessionManager.clearSession();
    userSessionNotifier.clear();
  }
}

// packages/core/security/lib/di/security_providers.dart
static final logoutDataSource = Provider<LogoutDataSource>((ref) {
  return LogoutDataSourceImpl(
    sessionManager: ref.read(sessionManager.notifier),
    userSessionNotifier: ref.read(userSession.notifier),
  );
});
```

```dart
// packages/features/settings/lib/data/repositories/settings_repository_impl.dart
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.logoutDataSource,  // single injection point
    …
  });

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await logoutDataSource.logout();  // delegates to common layer
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }
}

// packages/features/main_shell/lib/data/repositories/shell_session_repository_impl.dart
class ShellSessionRepositoryImpl implements ShellSessionRepository {
  ShellSessionRepositoryImpl({required this.logoutDataSource});

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await logoutDataSource.logout();
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }
}
```

### Rationale

Shared infrastructure lives in `core/common` or `core/security`. Feature data sources handle only the concerns specific to their business domain (API endpoints, DTOs, feature-specific persistence keys). When the same infrastructure operation appears in more than one feature, it signals that the operation belongs to the core layer — not because of reuse alone, but because the concern (session teardown, secure storage, HTTP) is cross-cutting and owned by infrastructure, not by any single feature's domain.
