# BankApp — Flutter Banking Application

Banking app built with **Flutter 3.41.2** / Dart 3.11, following Clean Architecture in a multi-module monorepo.

## Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.41.2 (Android + iOS) |
| State (features) | BLoC 9.x |
| DI + Global State | Riverpod 3.x |
| Navigation | go_router (ShellRoute, redirect guards, deep links) |
| Error handling | `Either<Failure, T>` (fpdart) |
| Serialization | Freezed + json_serializable |
| Monorepo | Pub Workspaces + Melos |
| Linting | very_good_analysis |

## Monorepo structure

```
apps/mobile_app/              # Composition root (3 entry points: dev/staging/prod)
packages/
├── core/
│   ├── common/               # Networking (Dio), config, errors, UseCase base, formatters
│   ├── ui/                   # Design system: tokens, theme, atoms, molecules, organisms
│   ├── domain/               # Shared entities (User, Account, Transaction, etc.)
│   └── mock/                 # Mock datasources + JSON fixtures (DEV only)
├── libs/
│   ├── otp/                  # OTP verification (Dio interceptor + flow widget)
│   ├── webview/              # BankingWebView (InAppWebView wrapper)
│   ├── promotions/           # PromoBanner, PromoCarousel
│   └── security/             # SecureStorage, biometrics, SessionManager
└── features/
    ├── authentication/       # Login, logout, forgot password
    ├── onboarding/           # Onboarding flow
    ├── globalposition/       # Global position (accounts overview)
    ├── accounts/             # Account detail and transactions
    ├── payments/             # New payment, confirmation, result
    ├── cards/                # Card list and detail
    ├── notifications/        # Notification center
    └── settings/             # App settings
```

## Requirements

- Flutter SDK 3.41.2+
- Dart SDK 3.11+
- Xcode 16+ (for iOS)
- Android Studio / Android SDK 34+ (for Android)

## Setup

```bash
# Clone and install dependencies
git clone <repo-url>
cd FlutterReactiveMultimoduleArch
dart pub get

# Run in development mode (with mocks)
cd apps/mobile_app
flutter run -t lib/main_dev.dart
```

## Entry points

| File | Environment | Data |
|------|------------|------|
| `lib/main_dev.dart` | MOCK | Mock datasources with JSON fixtures |
| `lib/main_staging.dart` | PRE | Points to staging API |
| `lib/main_prod.dart` | PRO | Points to production API |

## Mock credentials (DEV only)

| DNI | Password | OTP |
|-----|----------|-----|
| `12345678A` | `Test1234!` | `123456` (with OTP) |
| `87654321B` | `Demo1234!` | — (no OTP) |

## Melos commands

```bash
melos analyze          # Lint all packages
melos test             # Run tests with coverage
melos test:changed     # Run tests only for changed packages
melos format:check     # Check Dart formatting
melos build:runner     # Code generation (freezed, json_serializable)
melos clean            # flutter clean across all packages
melos deps:upgrade     # Upgrade all dependencies
```

## Feature architecture

Each feature follows Clean Architecture with the following structure:

```
packages/features/<name>/lib/
├── presentation/
│   ├── <screen_name>/
│   │   ├── <screen_name>_page.dart     # Page (StatefulWidget)
│   │   ├── <screen_name>_bloc.dart     # BLoC
│   │   ├── <screen_name>_event.dart    # sealed class + events
│   │   ├── <screen_name>_state.dart    # sealed class + states
│   │   └── widgets/                    # Screen-specific widgets
│   └── widgets/                        # Widgets shared across the feature
├── domain/
│   ├── entities/                       # Pure domain models
│   ├── repositories/                   # Abstract contracts
│   └── usecases/                       # UseCase<Type, Params>
└── data/
    ├── datasources/                    # Abstract contracts
    ├── models/                         # DTOs with .toEntity() and .fromJson()
    └── repositories/                   # Concrete implementations (Either<Failure, T>)
```

## Dependency rules

```
features → libs → core          (allowed)
features ✗ features             (forbidden)
libs ✗ features                 (forbidden)
core ✗ libs, core ✗ features    (forbidden, except core/mock in main_dev.dart)
```

## Documentation

- [Full architecture spec](flutter_banking_architecture.md) — detailed reference document
- [Claude Code instructions](CLAUDE.md) — development rules and patterns
