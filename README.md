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
| Monorepo | Pub Workspaces + Melos 7.x |
| Linting | very_good_analysis |

## Monorepo structure

```
apps/mobile_app/              # Composition root (3 entry points: dev/staging/prod)
packages/
├── core/
│   ├── common/               # Networking (Dio), config, errors, UseCase base, formatters
│   ├── ui/                   # Design system: tokens, theme, atoms, molecules, organisms
│   ├── domain/               # Shared entities (User, Account, Transaction, etc.)
│   ├── security/             # SecureStorage, biometrics, SessionManager
│   └── mock/                 # Mock datasources + JSON fixtures (DEV only)
├── libs/
│   ├── otp/                  # OTP verification (Dio interceptor + flow widget)
│   ├── webview/              # BankingWebView (InAppWebView wrapper)
│   └── promotions/           # PromoBanner, PromoCarousel
└── features/
    ├── authentication/       # Login, logout, forgot password
    ├── onboarding/           # Onboarding flow
    ├── globalposition/       # Global position (accounts overview)
    ├── accounts/             # Account detail and transactions
    ├── payments/             # New payment, confirmation, result
    ├── cards/                # Card list and detail
    ├── notifications/        # Notification center
    ├── settings/             # App settings
    └── main_shell/           # Bottom navigation shell
```

## Requirements

- **Flutter SDK** 3.41.2+
- **Dart SDK** 3.11+
- **Melos** 7.x (`dart pub global activate melos`)
- **Xcode** 16+ (solo iOS)
- **CocoaPods** (`gem install cocoapods`) (solo iOS)
- **Android Studio** / Android SDK 34+ (solo Android)
- **Java 17** (requerido por Gradle / AGP)

## Setup inicial

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd FlutterReactiveMultimoduleArch

# 2. Verificar la versión de Flutter
flutter --version
# Debe ser 3.41.2 o superior

# 3. Instalar Melos globalmente (si no está instalado)
dart pub global activate melos

# 4. Resolver dependencias del workspace completo
dart pub get

# 5. Generar código (Freezed, json_serializable, Retrofit, l10n)
melos run generate

# 6. (Solo iOS) Instalar pods
cd apps/mobile_app/ios && pod install && cd ../../..
```

## Ejecutar la app

La app tiene **3 entornos** configurados mediante entry points + flavors (Android) / schemes (iOS).

### Entorno DEV (con mocks — sin servidor)

```bash
# Android
cd apps/mobile_app
flutter run --flavor dev -t lib/main_dev.dart

# iOS
cd apps/mobile_app
flutter run --flavor dev -t lib/main_dev.dart
```

### Entorno Staging (apunta a API de PRE)

```bash
# Android
cd apps/mobile_app
flutter run --flavor staging -t lib/main_staging.dart

# iOS
cd apps/mobile_app
flutter run --flavor staging -t lib/main_staging.dart
```

### Entorno Produccion

```bash
# Android
cd apps/mobile_app
flutter run --flavor prod -t lib/main_prod.dart

# iOS
cd apps/mobile_app
flutter run --flavor prod -t lib/main_prod.dart
```

### Resumen de entry points

| Entry point | Flavor / Scheme | Entorno | Datos | Application ID (Android) |
|-------------|-----------------|---------|-------|--------------------------|
| `lib/main_dev.dart` | `dev` | MOCK | Mock datasources con fixtures JSON | `com.company.mobile_app.dev` |
| `lib/main_staging.dart` | `staging` | PRE | API de staging | `com.company.mobile_app.staging` |
| `lib/main_prod.dart` | `prod` | PRO | API de produccion | `com.company.mobile_app` |

> Los tres flavors pueden coexistir instalados en el mismo dispositivo gracias a los `applicationIdSuffix` distintos.

## Credenciales mock (solo DEV)

| DNI | Password | OTP |
|-----|----------|-----|
| `12345678A` | `Test1234!` | `123456` (con OTP) |
| `87654321B` | `Demo1234!` | — (sin OTP) |

## Comandos Melos

```bash
# Generacion de codigo
melos run generate            # l10n + build_runner (Freezed, json_serializable, Retrofit)
melos run build:runner        # Solo build_runner
melos run l10n:generate       # Solo LocaleKeys a partir de JSONs de traduccion

# Tests
melos run test                # Tests con coverage en todos los paquetes
melos run test:changed        # Tests solo de paquetes modificados (vs origin/main)

# Analisis y formato
melos exec -- dart analyze .  # Lint de todos los paquetes
melos exec -- dart format --set-exit-if-changed .  # Verificar formato

# Build de release
melos run build:apk           # APK de produccion con ofuscacion
melos run build:ios           # iOS de produccion con ofuscacion

# Mantenimiento
melos run clean               # flutter clean en todos los paquetes
dart pub get                  # Resolver dependencias del workspace
```

## Build de release

### Android (APK)

```bash
# Mediante melos (usa flavor prod + ofuscacion)
melos run build:apk

# Manualmente
cd apps/mobile_app
flutter build apk --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols/
```

### iOS

```bash
# Mediante melos (usa flavor prod + ofuscacion)
melos run build:ios

# Manualmente
cd apps/mobile_app
flutter build ios --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols/
```

## Feature architecture

Each feature follows Clean Architecture with the following structure:

```
packages/features/<name>/lib/
├── di/
│   └── <name>_providers.dart       # Riverpod providers (datasource + repository)
├── routing/
│   └── <name>_routes.dart          # FeatureRoutes (shellRoutes + fullScreenRoutes)
├── presentation/
│   ├── <screen_name>/
│   │   ├── bloc/
│   │   │   ├── <screen_name>_bloc.dart
│   │   │   ├── <screen_name>_event.dart
│   │   │   └── <screen_name>_state.dart
│   │   ├── page/
│   │   │   └── <screen_name>_page.dart
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
features -> libs -> core          (allowed)
features x features               (forbidden)
libs x features                   (forbidden)
core x libs, core x features      (forbidden, except core/mock in main_dev.dart)
```

## Troubleshooting

### `MissingPluginException` o errores de plugins nativos
```bash
cd apps/mobile_app
flutter clean
flutter pub get
# iOS:
cd ios && pod install --repo-update && cd ..
```

### Archivos `.freezed.dart` o `.g.dart` desactualizados
```bash
melos run build:runner
```

### Error "Pub workspace must be resolved" despues de cambiar dependencias
```bash
# Ejecutar desde la raiz del monorepo
dart pub get
```

### iOS build falla con "No Provisioning Profile"
Abrir `apps/mobile_app/ios/Runner.xcworkspace` en Xcode, seleccionar el scheme correcto (`dev`, `staging` o `prod`) y configurar el Signing & Capabilities.

## Documentation

- [Full architecture spec](flutter_banking_architecture.md) — detailed reference document
- [Claude Code instructions](CLAUDE.md) — development rules and patterns
