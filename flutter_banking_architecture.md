# Arquitectura Flutter para App Bancaria a Gran Escala

> **Flutter 3.41.2 (Stable) · Dart 3.x · iOS & Android**
> Documento de referencia para la definición arquitectónica del proyecto.
> Última actualización: Febrero 2026

---

## Tabla de Contenidos

1. [Arquitectura Principal: Monorepo Multi-Módulo](#1-arquitectura-principal-monorepo-multi-módulo)
2. [Estructura de Proyecto](#2-estructura-de-proyecto)
3. [Gestión del Monorepo: Melos + Pub Workspaces](#3-gestión-del-monorepo-melos--pub-workspaces)
4. [Patrón Arquitectónico: Clean Architecture + Feature-First](#4-patrón-arquitectónico-clean-architecture--feature-first)
5. [State Management](#5-state-management)
6. [Inyección de Dependencias](#6-inyección-de-dependencias)
7. [Navegación](#7-navegación)
8. [Networking y Capa de Datos](#8-networking-y-capa-de-datos)
9. [Internacionalización (i18n)](#9-internacionalización-i18n)
10. [WebViews Integradas](#10-webviews-integradas)
11. [Concurrencia e Isolates](#11-concurrencia-e-isolates)
12. [Seguridad](#12-seguridad)
13. [Testing](#13-testing)
14. [UI (Design System)](#14-ui-design-system)
15. [CI/CD y DevOps](#15-cicd-y-devops)
16. [Developer Experience](#16-developer-experience)
17. [Tabla Resumen de Dependencias](#17-tabla-resumen-de-dependencias)

---

## 1. Arquitectura Principal: Monorepo Multi-Módulo

### ¿Por qué monorepo multi-módulo?

Con muchos desarrolladores trabajando en paralelo sobre una app bancaria con muchas features, necesitamos:

- **Aislamiento de features**: cada equipo trabaja en su módulo sin conflictos
- **Compilación independiente**: cada módulo se compila y testea por separado
- **Contratos claros entre módulos**: interfaces bien definidas
- **Reutilización**: UI, networking, seguridad compartidos
- **Propiedad del código**: CODEOWNERS por módulo

### Enfoque: Feature-First Hybrid

Combinamos organización por **features de negocio** (autenticación, posición global, pagos) con **capas compartidas** (core, UI, domain). Cada feature es un paquete Dart completo con sus propias capas de Clean Architecture.

---

## 2. Estructura de Proyecto

```
banking_app/
├── pubspec.yaml                    # Workspace root (Pub Workspaces)
├── melos.yaml                      # Configuración Melos
├── analysis_options.yaml           # Reglas de lint globales
├── lefthook.yaml                   # Git hooks
│
├── apps/
│   └── mobile_app/                 # App principal (composition root)
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── main_dev.dart       # Entry point DEV (único que importa mock)
│       │   ├── main_staging.dart   # Entry point STAGING (sin mock, apunta a PRE)
│       │   ├── main_prod.dart      # Entry point PROD (sin mock, apunta a PRO)
│       │   ├── app.dart            # MaterialApp + Router + Providers
│       │   ├── di/                 # Composición de dependencias
│       │   └── routing/            # Definición de rutas (agrega rutas de features)
│       ├── android/
│       ├── ios/
│       └── test/
│
├── packages/
│   ├── core/                       # ── Módulos core (compartidos) ──
│   │   │
│   │   ├── common/                 # Utilidades compartidas, networking, config
│   │   │   ├── pubspec.yaml
│   │   │   └── lib/
│   │   │       ├── network/        # Dio setup, interceptors, certificate pinning
│   │   │       ├── config/         # Environment config, feature flags
│   │   │       ├── error/          # Failure types, exceptions
│   │   │       ├── usecases/       # Base UseCase abstract class
│   │   │       ├── extensions/     # Dart extensions comunes
│   │   │       └── utils/          # Formatters, validators
│   │   │
│   │   ├── ui/                     # Componentes UI, theming, tokens
│   │   │   ├── pubspec.yaml
│   │   │   └── lib/
│   │   │       ├── tokens/         # Colors, typography, spacing, radii
│   │   │       ├── theme/          # Light/dark ThemeData, ThemeExtensions
│   │   │       ├── atoms/          # Button, Text, Icon, Input
│   │   │       ├── molecules/      # SearchBar, FormField, ListTile
│   │   │       └── organisms/      # AppBar, NavigationDrawer, BottomSheet
│   │   │
│   │   ├── domain/                 # Entidades y contratos compartidos cross-feature
│   │   │   ├── pubspec.yaml
│   │   │   └── lib/
│   │   │       ├── entities/       # User, Account, Currency (compartidos)
│   │   │       ├── repositories/   # Contratos abstractos compartidos
│   │   │       └── value_objects/  # Money, IBAN, PhoneNumber
│   │   │
│   │   ├── security/              # Módulo de seguridad centralizado
│   │   │   ├── pubspec.yaml
│   │   │   └── lib/
│   │   │       ├── encryption/     # AES, RSA helpers
│   │   │       ├── storage/        # Secure storage wrapper
│   │   │       ├── biometric/      # Biometric auth wrapper
│   │   │       ├── anti_tamper/    # Root/jailbreak detection, integrity checks
│   │   │       └── session/        # Session management, token refresh
│   │   │
│   │   └── mock/                  # ⚠️ SOLO DEV — no compila en STAGING ni PROD
│   │       ├── pubspec.yaml       # Depende de features (importa sus interfaces)
│   │       ├── assets/fixtures/   # JSON fixtures (user, accounts, transactions...)
│   │       └── lib/
│   │           ├── config/        # MockConfig, MockDelay
│   │           ├── datasources/   # MockAuthDS, MockAccountDS...
│   │           └── di/            # mock_providers.dart (Riverpod overrides)
│   │
│   ├── libs/                       # ── Librerías compartidas de negocio ──
│   │   │                           # Features SÍ pueden depender de libs
│   │   │                           # Libs SÍ pueden depender de otras libs y de core
│   │   │
│   │   ├── otp/                    # Verificación OTP transversal (login, pagos, tarjetas...)
│   │   │   ├── pubspec.yaml        # Depende de core/common, core/ui, core/security
│   │   │   └── lib/
│   │   │       ├── otp_flow.dart          # Widget/flujo completo de verificación OTP
│   │   │       ├── otp_config.dart        # Config (longitud, tipo: SMS/email/push)
│   │   │       ├── otp_interceptor.dart   # Interceptor Dio: detecta cabecera OTP-required
│   │   │       └── otp_result.dart        # Resultado: verified, cancelled, expired
│   │   │
│   │   ├── webview/                # Infraestructura WebView bancaria
│   │   │   ├── pubspec.yaml        # Depende de core/common (Dio), core/security (tokens)
│   │   │   └── lib/
│   │   │       ├── banking_webview.dart      # Widget principal configurable
│   │   │       ├── webview_event.dart        # Contrato de eventos Web ↔ App
│   │   │       ├── webview_bridge.dart       # AppBridge: JS channels bidireccionales
│   │   │       ├── webview_session.dart      # Inyección de token, gestión de sesión
│   │   │       ├── webview_security.dart     # Whitelist de dominios, cookie cleanup
│   │   │       └── webview_config.dart       # Configuración (dominios permitidos, timeouts)
│   │   │
│   │   └── promotions/             # Banners, contenido promocional
│   │       ├── pubspec.yaml        # Depende de libs/webview (para promos en WebView)
│   │       └── lib/
│   │           ├── data/           # Data sources para contenido promocional
│   │           ├── domain/         # Entidades y contratos de promotions
│   │           └── presentation/   # Widgets reutilizables (PromoBanner, PromoCarousel)
│   │
│   └── features/                   # ── Features de negocio (pantallas independientes) ──
│       │
│       ├── authentication/         # Feature: Login (DNI + password), 2FA, biometrics
│       │   ├── pubspec.yaml
│       │   └── lib/
│       │       ├── presentation/
│       │       │   ├── bloc/       # AuthBloc, LoginCubit
│       │       │   ├── pages/      # LoginPage, ForgotPasswordPage
│       │       │   └── widgets/    # PinInput, BiometricButton
│       │       ├── domain/
│       │       │   ├── entities/   # AuthToken, LoginCredentials
│       │       │   ├── repositories/ # AuthRepository (abstracto)
│       │       │   └── usecases/   # LoginUseCase, LogoutUseCase, RefreshTokenUseCase
│       │       └── data/
│       │           ├── datasources/ # RemoteAuthDataSource, LocalAuthDataSource
│       │           ├── models/     # AuthTokenModel, UserModel (DTOs)
│       │           └── repositories/ # AuthRepositoryImpl
│       │
│       ├── globalposition/         # Feature: Posición global, resumen de cuentas y últimos movimientos
│       │   └── (misma estructura que authentication)
│       │
│       ├── accounts/               # Feature: Detalle de cuenta, movimientos
│       │   └── (misma estructura)
│       │
│       ├── payments/               # Feature: Transferencias, Bizum, pagos
│       │   └── (misma estructura)
│       │
│       ├── cards/                  # Feature: Gestión de tarjetas
│       │   └── (misma estructura)
│       │
│       ├── notifications/          # Feature: Push, in-app notifications
│       │   └── (misma estructura)
│       │
│       ├── settings/               # Feature: Perfil, preferencias, seguridad
│       │   └── (misma estructura)
│       │
│       └── onboarding/            # Feature: Onboarding post-login (primera vez)
│           └── (misma estructura)
│
└── tools/                          # Scripts auxiliares
    ├── ci/                         # Scripts de CI/CD
    └── code_gen/                   # Templates de código
```

### Reglas de Dependencia entre Módulos

```
mobile_app ──► packages/features/* ──► packages/libs/*  ──► packages/core/*
                     │                      │                      │
                     │                      ▼                      │
                     │              packages/core/domain           │
                     │              packages/core/common           │
                     │              packages/core/ui               │
                     │              packages/core/security         │
                     │                                             │
                     └──────────────────────────────────────────────┘
```

Nuevas reglas:
- **packages/features/** pueden depender de `packages/core/*` y de `packages/libs/*`
- **packages/features/** NUNCA dependen de otros features (comunicación vía routing o events)
- **packages/features/** NUNCA dependen de `packages/core/mock` (mock conoce a features, no al revés)
- **packages/libs/** pueden depender de `packages/core/*` y de otros `packages/libs/*`
- **packages/libs/** NUNCA dependen de features
- **packages/core/** solo dependen de otros módulos core (nunca de libs ni features)
- **packages/core/mock** es la excepción: depende de features (para importar interfaces) y es exclusiva de `main_dev.dart` — NUNCA se importa en `main_staging.dart` ni `main_prod.dart`. Dart tree-shaking garantiza que el código mock no compila en los builds de STAGING/PROD
- **packages/core/ui** solo depende de Flutter SDK
- **packages/libs/otp** depende de `core/common` (Dio interceptor), `core/ui` (widgets) y `core/security` (tokens). Cualquier feature la importa para gestionar verificación OTP — se activa por cabecera HTTP del backend
- **packages/libs/webview** depende de `core/common` (Dio) y `core/security` (tokens, sesión). Los features importan esta lib para mostrar WebViews con sesión, bridge y seguridad ya resuelta
- **packages/libs/promotions** depende de `libs/webview` y `core/common`
- **mobile_app** es el composition root que conecta todo

---

## 3. Gestión del Monorepo: Melos + Pub Workspaces

### Pub Workspaces (Flutter 3.27+ / Dart 3.6+)

Resolución nativa de dependencias a nivel de workspace. Reduce tiempos de resolución un 55-85%.

**Versionado centralizado**: todas las versiones de dependencias externas se declaran UNA SOLA VEZ en el `pubspec.yaml` raíz. Los módulos referencian las dependencias sin versión — el workspace resuelve todo de forma unificada. Esto elimina conflictos de versiones entre módulos y garantiza que todo el proyecto usa exactamente las mismas versiones.

```yaml
# pubspec.yaml (raíz del proyecto) — FUENTE ÚNICA DE VERSIONES
name: banking_app_workspace
resolution: workspace

workspace:
  - apps/**
  - packages/**

# Todas las versiones se declaran aquí, centralizadas
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  fpdart: ^1.1.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  flutter_bloc: ^8.1.0
  riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^14.0.0
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.2.0
  safe_device: ^1.2.0
  app_device_integrity: ^3.0.0
  easy_localization: ^3.0.0
  dio_cache_interceptor: ^3.5.0
  flutter_windowmanager: ^2.1.0

dev_dependencies:
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
  very_good_analysis: ^6.0.0
  easy_localization_generator: ^2.0.0
```

```yaml
# packages/features/accounts/pubspec.yaml — SIN versiones
name: accounts
description: Feature module for accounts

# Solo declara QUÉ necesita, no la versión
dependencies:
  flutter:
    sdk: flutter
  dio:                    # Versión resuelta por el workspace raíz
  fpdart:
  freezed_annotation:
  flutter_bloc:
  common:                 # Módulo local
    path: ../../core/common
  domain:
    path: ../../core/domain
  ui:
    path: ../../core/ui

dev_dependencies:
  freezed:
  json_serializable:
  build_runner:
  bloc_test:
  mocktail:
```

```yaml
# packages/core/domain/pubspec.yaml — Dart puro, mínimas dependencias
name: domain
description: Domain layer - entities, use cases, repository contracts

dependencies:
  fpdart:
  freezed_annotation:
  common:
    path: ../common

dev_dependencies:
  freezed:
  build_runner:
  mocktail:
```

**Regla**: si un desarrollador necesita una dependencia nueva o actualizar una versión, lo hace en el `pubspec.yaml` raíz. Nunca en el pubspec de un módulo individual.

### Melos

Herramienta estándar de la industria para orquestar monorepos Flutter.

```yaml
# melos.yaml
name: banking_app
repository: https://github.com/org/banking_app

packages:
  - apps/**
  - packages/**

command:
  bootstrap:
    usePubspecOverrides: true

scripts:
  analyze:
    description: Analyze all packages
    run: dart analyze .
    exec:
      concurrency: 4

  test:
    description: Run all tests
    run: flutter test --coverage
    exec:
      concurrency: 4
      failFast: true

  test:changed:
    description: Run tests only for changed packages
    run: melos exec --since=origin/main -- "flutter test --coverage"

  format:check:
    description: Check formatting
    run: dart format --set-exit-if-changed .
    exec:
      concurrency: 4

  build:runner:
    description: Run build_runner in all packages that need it
    run: dart run build_runner build --delete-conflicting-outputs
    exec:
      concurrency: 2
      orderDependents: true

  clean:
    description: Clean all packages
    run: flutter clean
    exec:
      concurrency: 4

  deps:upgrade:
    description: Upgrade all dependencies across the workspace
    run: dart pub upgrade
    exec:
      concurrency: 1
```

### Comandos diarios del equipo

```bash
melos bootstrap          # Instalar dependencias + link local packages
melos analyze            # Lint en todos los módulos
melos test               # Tests en todos los módulos
melos test:changed       # Tests solo en lo que ha cambiado (CI)
melos build:runner       # Regenerar código generado
melos deps:upgrade       # Actualizar dependencias en todo el workspace
```

---

## 4. Patrón Arquitectónico: Clean Architecture + Feature-First

### Capas y Responsabilidades

```
┌─────────────────────────────────────────────┐
│              PRESENTATION                    │
│  Pages · Widgets · BLoC/Cubit · ViewModels  │
│  ↓ depende de                               │
├─────────────────────────────────────────────┤
│                DOMAIN                        │
│  Entities · UseCases · Repository contracts  │
│  (Dart puro, sin dependencias externas)     │
│  ↑ depende de                               │
├─────────────────────────────────────────────┤
│                 DATA                         │
│  Repository impls · DataSources · DTOs      │
│  Mappers (DTO ↔ Entity)                     │
└─────────────────────────────────────────────┘
```

### Dependency Rule

Las dependencias **siempre apuntan hacia el dominio**. La capa de datos implementa los contratos definidos en domain. La capa de presentación consume use cases del dominio.

### UseCase Pattern

```dart
// packages/core/lib/usecases/usecase.dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

@freezed
abstract class NoParams with _$NoParams {
  const factory NoParams() = _NoParams;
}
```

```dart
// packages/features/accounts/lib/domain/usecases/get_account_transactions.dart
class GetAccountTransactionsUseCase extends UseCase<List<Transaction>, GetAccountTransactionsParams> {
  final AccountRepository repository;

  GetAccountTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(GetAccountTransactionsParams params) {
    return repository.getTransactions(
      accountId: params.accountId,
      dateRange: params.dateRange,
    );
  }
}
```

### Repository Pattern

```dart
// Domain (contrato abstracto)
abstract class AccountRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    required DateRange dateRange,
  });
  Future<Either<Failure, TransactionDetail>> getTransactionDetail(String id);
}

// Data (implementación concreta)
class AccountRepositoryImpl implements AccountRepository {
  final RemoteAccountDataSource remote;
  final LocalAccountDataSource local;

  AccountRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    required DateRange dateRange,
  }) async {
    try {
      final dtos = await remote.fetchTransactions(accountId, dateRange);
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      await local.cacheTransactions(entities);
      return Right(entities);
    } on ServerException catch (e) {
      // Fallback to cache
      try {
        final cached = await local.getCachedTransactions(accountId);
        return Right(cached);
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    }
  }
}
```

### Error Handling con Either (fpdart)

Usamos `Either<Failure, T>` de **fpdart** en lugar de excepciones para un flujo de errores explícito y type-safe.

```dart
// packages/core/lib/error/failures.dart
sealed class Failure {
  final String message;
  final int? code;
  const Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
```

---

## 5. State Management

### Recomendación: BLoC 9.x (features) + Riverpod 3.x (DI / estado global)

Para una app bancaria con auditoría y compliance, BLoC ofrece un trail de eventos claro. Riverpod complementa como DI container y para estado a nivel de app.

| Aspecto | BLoC 9.x | Riverpod 3.x |
|---------|----------|-------------|
| **Usar para** | Lógica de features (transacciones, pagos, auth) | DI, estado global (sesión, configuración, tema) |
| **Ventaja clave** | Trail de eventos auditable, testabilidad | DI integrado, compile-time safety |
| **Boilerplate** | Medio (Events + States) | Bajo (@riverpod macro) |
| **Curva de aprendizaje** | Media-alta | Media |

### BLoC Pattern para Features

```dart
// Events
sealed class AccountEvent {}

class FetchAccountTransactions extends AccountEvent {
  final String accountId;
  FetchAccountTransactions(this.accountId);
}

class RefreshAccountTransactions extends AccountEvent {}

// States (single class + status enum pattern)
enum AccountStatus { initial, loading, loaded, error }

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({
    @Default(AccountStatus.initial) AccountStatus status,
    @Default([]) List<Transaction> transactions,
    @Default('') String errorMessage,
  }) = _AccountState;
}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}

// BLoC
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountTransactionsUseCase _getTransactions;

  AccountBloc({required GetAccountTransactionsUseCase getTransactions})
      : _getTransactions = getTransactions,
        super(AccountInitial()) {
    on<FetchAccountTransactions>(_onFetch);
    on<RefreshAccountTransactions>(_onRefresh);
  }

  Future<void> _onFetch(FetchAccountTransactions event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    final result = await _getTransactions(
      GetAccountTransactionsParams(accountId: event.accountId, dateRange: DateRange.lastMonth()),
    );
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (transactions) => emit(AccountLoaded(transactions)),
    );
  }
}
```

### Riverpod para Estado Global y DI

```dart
// Estado de sesión (app-wide)
@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  AsyncValue<Session?> build() => const AsyncValue.data(null);

  Future<void> login(Credentials credentials) async { /* ... */ }
  Future<void> logout() async { /* ... */ }
}

// Tema de la app
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void setTheme(ThemeMode mode) => state = mode;
}

// Feature flags
@riverpod
Future<FeatureFlags> featureFlags(FeatureFlagsRef ref) async {
  final repository = ref.watch(featureFlagRepositoryProvider);
  return repository.getFlags();
}
```

---

## 6. Inyección de Dependencias

### Riverpod 3.x como DI único

Riverpod cubre todos los casos de DI: desde providers de features hasta singletons de infraestructura que necesitan inicialización temprana. No necesitamos get_it ni injectable — usar dos sistemas de DI añade complejidad innecesaria y dos modelos mentales para lo mismo.

### Providers por capa (feature modules)

```dart
// packages/features/accounts/lib/di/account_providers.dart
@riverpod
AccountRepository accountRepository(AccountRepositoryRef ref) {
  return AccountRepositoryImpl(
    remote: RemoteAccountDataSource(ref.watch(dioProvider)),
    local: LocalAccountDataSource(ref.watch(databaseProvider)),
  );
}

@riverpod
GetAccountTransactionsUseCase getAccountTransactionsUseCase(GetAccountTransactionsUseCaseRef ref) {
  return GetAccountTransactionsUseCase(ref.watch(accountRepositoryProvider));
}

@riverpod
AccountBloc accountBloc(AccountBlocRef ref) {
  return AccountBloc(
    getTransactions: ref.watch(getAccountTransactionsUseCaseProvider),
  );
}
```

### Singletons de infraestructura (inicialización temprana)

Para servicios que requieren `await` antes de que el widget tree exista (secure storage, analytics, crashlytics), usamos `ProviderContainer` en el `main()`:

```dart
// apps/mobile_app/lib/main_prod.dart
// ⚠️ NO importa packages/core/mock → mock no compila en este build
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crear container antes del widget tree — sin overrides de mock
  final container = ProviderContainer();

  // Inicializar servicios que requieren await
  await container.read(secureStorageProvider.future);
  await container.read(analyticsProvider.future);
  await container.read(crashReportingProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BankingApp(),
    ),
  );
}
```

```dart
// packages/core/common/lib/di/infrastructure_providers.dart
@Riverpod(keepAlive: true)
Future<SecureStorageService> secureStorage(SecureStorageRef ref) async {
  return SecureStorageService.init();
}

@Riverpod(keepAlive: true)
Future<AnalyticsService> analytics(AnalyticsRef ref) async {
  final service = AnalyticsService();
  await service.initialize();
  return service;
}

@Riverpod(keepAlive: true)
Future<CrashReportingService> crashReporting(CrashReportingRef ref) async {
  final service = CrashReportingService();
  await service.initialize();
  return service;
}
```

`keepAlive: true` garantiza que estos providers se comportan como singletons (nunca se destruyen). `ProviderContainer` + `UncontrolledProviderScope` permite inicializarlos antes del widget tree, exactamente igual que get_it pero sin una dependencia extra.

---

## 7. Navegación

### go_router (estándar de la industria)

go_router es mantenido por Google, soporta deep linking, declarative routing, y shell routes para navegación anidada.

### Multi-módulo: cada feature exporta sus rutas

```dart
// packages/features/authentication/lib/routes.dart
final authRoutes = [
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginPage(),
    routes: [
      GoRoute(path: 'forgot-password', builder: (_, __) => const ForgotPasswordPage()),
    ],
  ),
];

// packages/features/globalposition/lib/routes.dart
final globalPositionRoutes = [
  GoRoute(
    path: '/globalposition',
    builder: (context, state) => const GlobalPositionPage(),
  ),
];

// packages/features/accounts/lib/routes.dart
final accountRoutes = [
  GoRoute(
    path: '/accounts/:id',
    builder: (context, state) => AccountDetailPage(
      accountId: state.pathParameters['id']!,
    ),
    routes: [
      // Detalle de transacción → puede ser WebView o nativo
      GoRoute(
        path: 'transactions/:txId',
        builder: (context, state) => TransactionDetailWebViewPage(
          transactionId: state.pathParameters['txId']!,
        ),
      ),
    ],
  ),
];
```

### Composición en la app principal + Deep Links + Sesión

Todas las rutas son susceptibles de recibirse como deep link. El redirect guard centralizado gestiona el estado de la sesión: si el usuario está autenticado navega al destino, si la sesión expiró guarda el destino pendiente, redirige al login, y tras autenticarse completa la navegación al destino original.

```dart
// apps/mobile_app/lib/routing/pending_route_notifier.dart
// Guarda el destino pendiente cuando un deep link llega con sesión expirada
@Riverpod(keepAlive: true)
class PendingRouteNotifier extends _$PendingRouteNotifier {
  @override
  String? build() => null;

  void save(String location) => state = location;
  String? consume() {
    final route = state;
    state = null;
    return route;
  }
}
```

```dart
// apps/mobile_app/lib/routing/app_router.dart

// Rutas públicas — accesibles sin sesión
const _publicRoutes = {
  '/login',
  '/forgot-password',
  '/promo',
  '/faq',
  '/contact',
};

bool _isPublicRoute(String location) {
  return _publicRoutes.any((route) => location.startsWith(route));
}

GoRouter appRouter(Ref ref) {
  final sessionNotifier = ref.watch(sessionNotifierProvider);
  final pendingRoute = ref.watch(pendingRouteNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = sessionNotifier.isAuthenticated;
      final currentLocation = state.matchedLocation;
      final isPublic = _isPublicRoute(currentLocation);

      // Ruta pública → dejar pasar siempre, con o sin sesión
      if (isPublic) {
        // Si está autenticado y va a login → redirigir al destino pendiente o globalposition
        if (isAuthenticated && currentLocation.startsWith('/login')) {
          return pendingRoute.consume() ?? '/globalposition';
        }
        return null;
      }

      // Ruta protegida sin sesión → guardar destino y mandar a login
      if (!isAuthenticated) {
        pendingRoute.save(currentLocation);
        return '/login';
      }

      return null;
    },
    routes: [
      // ── Rutas públicas (sin sesión) ──
      ...authRoutes,           // /login, /forgot-password
      ...promoRoutes,          // /promo/:code
      ...supportRoutes,        // /faq, /contact

      // ── Rutas protegidas (requieren sesión) ──
      ...onboardingRoutes,     // /onboarding (post-login, primera vez)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          ...globalPositionRoutes,
          ...accountRoutes,
          ...cardsRoutes,
          ...settingsRoutes,
        ],
      ),
      ...paymentRoutes,        // /payments/* (modales/fullscreen)
      ...notificationRoutes,   // /notifications/*
    ],
  );
}
```

### Deep Link: flujo completo

```
Deep link llega: bankapp://accounts/acc-001/transactions/tx-12345
        │
        ▼
  go_router parsea la ruta: /accounts/acc-001/transactions/tx-12345
        │
        ▼
  ¿Es ruta pública?
        │
        ├── Sí ──────────────────► Navega directamente (sin comprobar sesión)
        │
        └── No (ruta protegida)
                │
                ▼
          ¿Sesión válida?
                │
                ├── Sí ──────────► Navega a TransactionDetailWebViewPage(tx-12345)
                │
                └── No
                        │
                        ├── Guarda destino pendiente: /accounts/acc-001/transactions/tx-12345
                        │
                        └── Redirige a /login
                                │
                                ▼
                          Usuario se autentica (PIN, biometrics, credenciales)
                                │
                                ▼
                          redirect guard detecta autenticación + destino pendiente
                                │
                                ▼
                          Consume destino pendiente → Navega a /accounts/acc-001/transactions/tx-12345
```

### Configuración de Deep Links (plataforma)

```yaml
# android/app/src/main/AndroidManifest.xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="bankapp.com" />
  <data android:scheme="bankapp" />
</intent-filter>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>bankapp</string>
    </array>
  </dict>
</array>
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### Navegación entre features (desacoplada)

Los features no se conocen entre sí. Para navegar cross-feature, usan paths de go_router:

```dart
// Dentro de un feature, navegar a otro feature:
context.push('/accounts/${account.id}/transactions/${transaction.id}');
context.go('/payments/new?accountId=${account.id}');
```

### Tabla de rutas con deep links

| Deep Link | Ruta go_router | Feature | Requiere auth |
|-----------|---------------|---------|---------------|
| `bankapp://login` | `/login` | authentication | No |
| `bankapp://onboarding` | `/onboarding` | onboarding | Sí (post-login) |
| `bankapp://faq` | `/faq` | support | No |
| `bankapp://contact` | `/contact` | support | No |
| `https://bankapp.com/promo/{code}` | `/promo/:code` | marketing | No |
| `bankapp://globalposition` | `/globalposition` | globalposition | Sí |
| `bankapp://accounts/{id}` | `/accounts/:id` | accounts | Sí |
| `bankapp://accounts/{id}/transactions/{txId}` | `/accounts/:id/transactions/:txId` | accounts | Sí |
| `bankapp://payments/new` | `/payments/new` | payments | Sí |
| `bankapp://cards` | `/cards` | cards | Sí |
| `bankapp://settings` | `/settings` | settings | Sí |
| `bankapp://notifications` | `/notifications` | notifications | Sí |

### Patrón BLoC + GoRoute (reglas estrictas)

El router instancia BLoCs únicamente como capa de wiring de dependencias. No contiene lógica de negocio.

#### Reglas

| Permitido en el router | Prohibido en el router |
|------------------------|------------------------|
| `BlocProvider(create: (_) => MyBloc(useCase: container.read(...)))` | Callbacks con lógica de negocio (`onLogout: () => sessionManager.clear()`) |
| `..add(const InitialEvent())` para disparar la carga inicial | Leer primitivos de Riverpod y pasarlos al BLoC (`initialValue: container.read(myProvider).value`) |
| Callbacks de navegación (`onTap: () => context.push(...)`) | Lógica condicional o cómputos dentro del builder |
| `ProviderScope.containerOf(context).read(MyProviders.useCase)` | Pasar `VoidCallback` que modifica estado externo |

#### Estructura canónica de un GoRoute con BLoC

```dart
// packages/features/<name>/lib/routing/<name>_routes.dart
GoRoute(
  name: routeName,
  path: '/$routeName',
  builder: (context, state) {
    final container = ProviderScope.containerOf(context);

    return BlocProvider(
      create: (_) => MyFeatureBloc(
        // Solo use cases o repositories — nunca primitivos ni callbacks con lógica
        getDataUseCase: container.read(MyFeatureProviders.getDataUseCase),
        saveDataUseCase: container.read(MyFeatureProviders.saveDataUseCase),
      )..add(const MyFeatureStarted()),  // evento inicial para cargar estado
      child: const MyFeaturePage(),      // la page no recibe callbacks de negocio
    );
  },
)
```

#### Qué va dónde

**Business logic → UseCase / Repository**

```dart
// ✅ Correcto: el BLoC llama al use case
Future<void> _onLogoutRequested(
  LogoutRequested event,
  Emitter<SettingsState> emit,
) async {
  emit(state.copyWith(status: SettingsStatus.loggingOut));
  final result = await _logoutUseCase(const NoParams());
  result.fold(
    (failure) => emit(state.copyWith(status: SettingsStatus.error)),
    (_) { /* GoRouter.redirect maneja la navegación al limpiar sesión */ },
  );
}

// ❌ Incorrecto: lógica de negocio en el router
MainShellBloc(
  onLogout: () async {
    await container.read(SecurityProviders.sessionManager.notifier).clearSession();
    container.read(SecurityProviders.userSession.notifier).clear();
  },
)
```

**Estado inicial → evento `<Feature>Started`**

```dart
// ✅ Correcto: BLoC carga su propio estado al iniciarse
BlocProvider(
  create: (_) => SettingsBloc(
    getBiometricsStatusUseCase: container.read(...),
  )..add(const SettingsStarted()),  // dispara la carga
  child: const SettingsPage(),
)

// ❌ Incorrecto: router lee el estado y lo pasa como primitivo
BlocProvider(
  create: (_) => SettingsBloc(
    initialBiometricEnabled: container.read(SecurityProviders.biometricEnabled).value ?? false,
    onBiometricToggle: () { container.read(...).toggle(); },
  ),
  child: SettingsPage(
    onLogout: () async { ... },
  ),
)
```

**Callbacks en páginas → solo navegación**

```dart
// ✅ Correcto: callback de navegación en la página
GlobalPositionPage(
  onAccountTap: (account) => context.pushNamed(AccountsRoutes.accountDetail, ...),
  onTransactionTap: (tx) => context.pushNamed(...),
)

// ❌ Incorrecto: callback con side-effects en la página
SettingsPage(
  onLogout: () async {
    await sessionManager.clearSession();   // lógica de negocio
    userSession.clear();                   // no pertenece aquí
  },
)
```

#### Estado del BLoC con status enum (patrón obligatorio)

Todo BLoC que realice operaciones asíncronas debe tener un `<Feature>Status` enum con al menos `initial`, `loading`, `loaded`, `error`. Las operaciones adicionales añaden sus propios valores (ej. `loggingOut`).

```dart
enum SettingsStatus { initial, loading, loaded, loggingOut, error }

extension SettingsStatusX on SettingsStatus {
  bool get isInitial    => this == SettingsStatus.initial;
  bool get isLoading    => this == SettingsStatus.loading;
  bool get isLoaded     => this == SettingsStatus.loaded;
  bool get isLoggingOut => this == SettingsStatus.loggingOut;
  bool get isError      => this == SettingsStatus.error;
}

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(SettingsStatus.initial) SettingsStatus status,
    // ... campos del dominio con @Default
    String? errorMessage,
  }) = _SettingsState;

  const SettingsState._();  // necesario para getters computados
}
```

La UI usa `state.status.isLoggingOut` (no `state.status == SettingsStatus.loggingOut`) gracias a la extension.

---

## 8. Convenciones de la capa común (Common layer)

### Regla: los features nunca importan datasources de otros features

Los datasources de cada feature son internos a su paquete. Ningún feature puede importar el datasource, API client, DTO ni repositorio de otro feature. La comunicación entre features ocurre exclusivamente a través del router (`context.go / context.push`) y de las entidades de dominio compartidas en `core/domain`.

```
✅  accounts   → core/common   (safeApiCall, DioFactory, Failure)
✅  accounts   → core/security (SecureStorageService, SessionManager)
❌  payments   → accounts/data/datasources  (PROHIBIDO)
❌  globalposition → authentication/data/datasources  (PROHIBIDO)
```

### Criterio para mover un método a la capa común

Un método de datasource es candidato a `core/common` o `core/security` cuando se cumplen **las tres** condiciones:

1. **Duplicado** — la misma implementación aparece en dos o más features.
2. **Sin dependencia específica de feature** — no referencia DTOs, entidades ni tipos de dominio propios de ningún feature.
3. **Infraestructura compartida** — opera sobre servicios transversales (HTTP, almacenamiento seguro, sesión, biometría).

Si un método necesita una ligera adaptación por feature, se extrae la lógica común a la capa compartida y se dejan wrappers feature-específicos en cada datasource de feature.

### Estructura de carpetas

```
packages/core/common/lib/
├── di/common_providers.dart          # Riverpod providers: Dio, environment, locale
├── error/failures.dart               # Sealed Failure (ServerFailure, AuthFailure, …)
├── network/
│   ├── safe_api_call.dart            # safeApiCall<T>() — Either<Failure, T>
│   ├── dio_factory.dart              # DioFactory.create()
│   ├── auth_interceptor.dart
│   ├── dio_exception_mapper.dart
│   ├── logging_interceptor.dart
│   ├── cache_config.dart
│   └── certificate_pinning.dart
└── usecases/usecase.dart             # UseCase<T, Params> + NoParams

packages/core/security/lib/
├── di/security_providers.dart        # SecurityProviders (incluye logoutDataSource)
├── session/
│   ├── logout_datasource.dart        # LogoutDataSource + LogoutDataSourceImpl
│   ├── session_manager.dart
│   └── user_session_notifier.dart
└── …
```

### Ejemplo antes/después: `logout()` movido a la capa común

**Antes** — duplicado en dos repository implementations de features distintos:

```dart
// settings/data/repositories/settings_repository_impl.dart
Future<Either<Failure, void>> logout() async {
  try {
    await sessionManager.clearSession();  // ← duplicado
    userSessionNotifier.clear();          // ← duplicado
    return const Right(null);
  } on Exception catch (e) { … }
}

// main_shell/data/repositories/shell_session_repository_impl.dart
Future<Either<Failure, void>> logout() async {
  try {
    await sessionManager.clearSession();  // ← copia exacta
    userSessionNotifier.clear();          // ← copia exacta
    return const Right(null);
  } on Exception catch (e) { … }
}
```

**Después** — implementación única en `core/security`, inyectada en ambos features:

```dart
// core/security/lib/session/logout_datasource.dart
abstract class LogoutDataSource { Future<void> logout(); }

class LogoutDataSourceImpl implements LogoutDataSource {
  const LogoutDataSourceImpl({
    required this.sessionManager,
    required this.userSessionNotifier,
  });
  @override
  Future<void> logout() async {
    await sessionManager.clearSession();
    userSessionNotifier.clear();
  }
}

// core/security/lib/di/security_providers.dart
static final logoutDataSource = Provider<LogoutDataSource>((ref) {
  return LogoutDataSourceImpl(
    sessionManager: ref.read(sessionManager.notifier),
    userSessionNotifier: ref.read(userSession.notifier),
  );
});
```

Cada feature recibe `LogoutDataSource` por inyección de constructor en su repository impl y delega a él — sin conocer `SessionManager` ni `UserSessionNotifier` directamente.

### Justificación

La infraestructura compartida vive en `core/common` o `core/security`. Los datasources de feature manejan solo las preocupaciones específicas de su dominio de negocio (endpoints API, DTOs, claves de persistencia). Cuando la misma operación de infraestructura aparece en más de un feature, es señal de que pertenece a la capa core, no por reutilización en sí, sino porque la preocupación (cierre de sesión, almacenamiento seguro, HTTP) es transversal y es responsabilidad de la infraestructura, no del dominio de ningún feature.

---

## 9. Networking y Capa de Datos

### HTTP Client: Dio

```dart
// packages/core/lib/network/dio_client.dart
class DioClient {
  static Dio create({
    required String baseUrl,
    required SecureStorageService secureStorage,
    required List<Interceptor> additionalInterceptors,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
      LoggingInterceptor(),
      RetryInterceptor(dio: dio, retries: 3),
      CertificatePinningInterceptor(),
      ...additionalInterceptors,
    ]);

    return dio;
  }
}
```

### Auth Interceptor (Token Refresh)

```dart
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService secureStorage;
  final Dio _refreshDio = Dio(); // Dio separado para refresh

  AuthInterceptor({required this.secureStorage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _refreshDio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (_) {
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }
}
```

### Caché y Persistencia

Regla: **todo lo que se persista en disco va cifrado, con una sola librería de persistencia**.

| Capa | Solución | Package | Detalle |
|------|----------|---------|---------|
| **Caché HTTP (en memoria)** | MemCacheStore | `dio_cache_interceptor` | Solo en RAM. Se pierde al cerrar la app. Datos financieros nunca se cachean en disco. |
| **Persistencia en disco (cifrada)** | Keychain / Keystore | `flutter_secure_storage` | Tokens, refresh tokens, PIN, preferencias, config sensible. Todo cifrado nativamente por el SO. |

```dart
// packages/core/common/lib/network/cache_config.dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

final cacheOptions = CacheOptions(
  store: MemCacheStore(),              // Solo en memoria, nunca disco
  policy: CachePolicy.request,         // Cachea según headers del servidor
  maxStale: const Duration(minutes: 5), // Máximo tiempo de caché en memoria
  hitCacheOnErrorExcept: [401, 403],   // Usa caché si el server falla (excepto auth errors)
);

// Se añade como interceptor en Dio:
// dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
```

```dart
// packages/core/security/lib/storage/secure_storage_service.dart
// Wrapper genérico — NO conoce conceptos de negocio (tokens, sesiones, etc.)
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService._(this._storage);

  static Future<SecureStorageService> init() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    );
    return SecureStorageService._(storage);
  }

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
}
```

```dart
// packages/features/authentication/lib/data/datasources/local_auth_datasource.dart
// El feature de auth consume SecureStorageService y le da significado a las claves
class LocalAuthDataSource {
  final SecureStorageService _secureStorage;

  LocalAuthDataSource(this._secureStorage);

  Future<void> saveAccessToken(String token) => _secureStorage.write('access_token', token);
  Future<String?> getAccessToken() => _secureStorage.read('access_token');
  Future<void> saveRefreshToken(String token) => _secureStorage.write('refresh_token', token);
  Future<String?> getRefreshToken() => _secureStorage.read('refresh_token');
  Future<void> clearSession() async {
    await _secureStorage.delete('access_token');
    await _secureStorage.delete('refresh_token');
  }
}
```

**No usamos** `shared_preferences`, `drift`, `Hive`, `Isar` ni ninguna otra librería de persistencia. Una sola librería, todo cifrado, sin excepciones.

### Code Generation: Freezed para Todo

Freezed es la única librería para data classes, events, states y value objects. Genera `==`, `hashCode`, `toString`, `copyWith` y pattern matching. No usamos Equatable — una sola librería, sin duplicar.

#### Nomenclatura

| Capa | Sufijo | Serialización | Ejemplo |
|------|--------|---------------|---------|
| **Domain** (modelos de negocio) | `Model` | No (`copyWith`, `==`, `hashCode`, `toString`) | `TransactionModel` |
| **Data** (DTOs/DAOs) | `Dto` | Sí (`fromJson`/`toJson`) | `TransactionDto` |

**Modelos de dominio** (freezed sin serialización — `copyWith`, `==`, `hashCode`, `toString`):

```dart
// packages/core/domain/lib/entities/transaction_model.dart
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required Money amount,
    required String description,
    required DateTime createdAt,
    required TransactionStatus status,
  }) = _TransactionModel;
}

// packages/core/domain/lib/value_objects/money.dart
@freezed
class Money with _$Money {
  const factory Money({
    required double amount,
    required Currency currency,
  }) = _Money;
}
```

**DTOs** (freezed con serialización JSON — `fromJson`/`toJson`):

```dart
// packages/features/accounts/lib/data/dto/transaction_dto.dart
@freezed
class TransactionDto with _$TransactionDto {
  const factory TransactionDto({
    required String id,
    required double amount,
    required String currency,
    required String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String status,
  }) = _TransactionDto;

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
}
```

**Mappers en clases separadas** (nunca métodos dentro del modelo ni del DTO):

```dart
// packages/features/accounts/lib/data/mappers/transaction_mapper.dart
class TransactionMapper {
  static TransactionModel toModel(TransactionDto dto) => TransactionModel(
    id: dto.id,
    amount: Money(amount: dto.amount, currency: Currency.fromCode(dto.currency)),
    description: dto.description,
    createdAt: dto.createdAt,
    status: TransactionStatus.fromString(dto.status),
  );

  static TransactionDto toDto(TransactionModel model) => TransactionDto(
    id: model.id,
    amount: model.amount.amount,
    currency: model.amount.currency.code,
    description: model.description,
    createdAt: model.createdAt,
    status: model.status.name,
  );
}
```

Resumen: **freezed en domain** (Model, sin serialización) + **freezed en data** (Dto, con `fromJson`/`toJson`) + **mappers aparte**.

---

## 10. Internacionalización (i18n)

### easy_localization + deltas remotos

La app soporta múltiples idiomas con valores por defecto bundled y la capacidad de descargar deltas del servidor al iniciar sesión. `easy_localization` lo resuelve con su sistema de custom asset loaders y fallback automático a las traducciones locales.

### Estructura de archivos de traducción

```
packages/core/common/
└── assets/
    └── translations/
        ├── es.json          # Español (idioma base)
        ├── en.json          # Inglés
        ├── pt.json          # Portugués
        └── ca.json          # Catalán (u otros idiomas necesarios)
```

```json
// assets/translations/es.json
{
  "common": {
    "accept": "Aceptar",
    "cancel": "Cancelar",
    "retry": "Reintentar",
    "error_generic": "Ha ocurrido un error. Inténtalo de nuevo."
  },
  "auth": {
    "login_title": "Iniciar sesión",
    "login_button": "Entrar",
    "biometric_reason": "Autentícate para acceder a tu cuenta"
  },
  "otp": {
    "title": "Código de verificación",
    "description": "Introduce el código enviado a {destination}",
    "resend": "Reenviar código",
    "expired": "El código ha expirado"
  },
  "globalposition": {
    "greeting": "Hola, {name}",
    "total_balance": "Saldo total",
    "recent_transactions": "Últimos movimientos"
  },
  "accounts": {
    "detail_title": "Detalle de cuenta",
    "transactions_title": "Movimientos",
    "transactions_empty": "No hay movimientos en este periodo",
    "filter_by_date": "Filtrar por fecha"
  }
}
```

### Configuración

```dart
// apps/mobile_app/lib/app.dart
@override
Widget build(BuildContext context) {
  return EasyLocalization(
    supportedLocales: const [
      Locale('es'),
      Locale('en'),
      Locale('pt'),
      Locale('ca'),
    ],
    path: 'packages/core/common/assets/translations',
    fallbackLocale: const Locale('es'),
    assetLoader: RemoteDeltaAssetLoader(),  // Custom loader con deltas
    child: const BankingApp(),
  );
}
```

### Custom Asset Loader: base local + deltas remotos

```dart
// packages/core/common/lib/l10n/remote_delta_asset_loader.dart
class RemoteDeltaAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    // 1. Cargar traducciones base del bundle (siempre disponibles)
    final baseTranslations = await _loadFromBundle(path, locale);

    // 2. Intentar cargar deltas del servidor (puede fallar sin consecuencias)
    final remoteDeltas = await _fetchRemoteDeltas(locale);

    // 3. Mergear: los deltas sobreescriben las keys que traigan, el resto mantiene el valor base
    if (remoteDeltas != null) {
      return _deepMerge(baseTranslations, remoteDeltas);
    }

    return baseTranslations;
  }

  Future<Map<String, dynamic>> _loadFromBundle(String path, Locale locale) async {
    final jsonString = await rootBundle.loadString('$path/${locale.languageCode}.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> _fetchRemoteDeltas(Locale locale) async {
    try {
      // Endpoint que devuelve solo las keys que han cambiado
      final response = await dio.get('/config/translations/${locale.languageCode}/deltas');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      // Si falla la red, la app funciona con los valores base — sin problema
      return null;
    }
  }

  Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> overrides,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final key in overrides.keys) {
      if (result[key] is Map<String, dynamic> && overrides[key] is Map<String, dynamic>) {
        result[key] = _deepMerge(
          result[key] as Map<String, dynamic>,
          overrides[key] as Map<String, dynamic>,
        );
      } else {
        result[key] = overrides[key];
      }
    }
    return result;
  }
}
```

### Keys type-safe: clase de constantes generada

Las keys son compartidas por todos los features, así que viven en `packages/core/common`. Se generan automáticamente a partir de los JSON con `easy_localization_generator`, integrado en `build_runner`.

```yaml
# packages/core/common/pubspec.yaml
dev_dependencies:
  easy_localization_generator: ^x.x.x
  build_runner: ^x.x.x
```

```dart
// packages/core/common/lib/l10n/locale_keys.dart (GENERADO — no editar a mano)
// Generado con: melos build:runner
abstract class LocaleKeys {
  // common
  static const commonAccept = 'common.accept';
  static const commonCancel = 'common.cancel';
  static const commonRetry = 'common.retry';
  static const commonErrorGeneric = 'common.error_generic';

  // auth
  static const authLoginTitle = 'auth.login_title';
  static const authLoginButton = 'auth.login_button';
  static const authBiometricReason = 'auth.biometric_reason';

  // otp (lib transversal — usada desde login, pagos, tarjetas, etc.)
  static const otpTitle = 'otp.title';
  static const otpDescription = 'otp.description';
  static const otpResend = 'otp.resend';
  static const otpExpired = 'otp.expired';

  // globalposition
  static const globalpositionGreeting = 'globalposition.greeting';
  static const globalpositionTotalBalance = 'globalposition.total_balance';
  static const globalpositionRecentTransactions = 'globalposition.recent_transactions';

  // accounts
  static const accountsDetailTitle = 'accounts.detail_title';
  static const accountsTransactionsTitle = 'accounts.transactions_title';
  static const accountsTransactionsEmpty = 'accounts.transactions_empty';
  static const accountsFilterByDate = 'accounts.filter_by_date';
}
```

### Uso en widgets

Todos los features importan `LocaleKeys` de `packages/core/common`. Autocompletado del IDE, errores en compilación si la key no existe, cero strings hardcodeados.

```dart
import 'package:common/l10n/locale_keys.dart';

// Texto simple
Text(LocaleKeys.authLoginTitle.tr())

// Con parámetros
Text(LocaleKeys.authOtpDescription.tr(namedArgs: {'destination': '+34 *** ** 89'}))
Text(LocaleKeys.globalpositionGreeting.tr(namedArgs: {'name': user.firstName}))

// Plurales
Text(LocaleKeys.notificationsCount.plural(notificationCount))
```

### Flujo de carga

1. La app arranca con las traducciones bundled (disponibles offline, instantáneo)
2. Al iniciar sesión (o en background), se descargan los deltas del servidor
3. Se mergean en memoria: las keys del delta sobreescriben las del bundle, el resto se mantiene
4. Si la descarga falla, la app funciona perfectamente con los valores base
5. Los deltas **no se persisten en disco** (coherente con la estrategia de caché solo en memoria)

---

## 11. WebViews Integradas

### ¿Por qué WebViews en una app bancaria?

Algunas secciones de las features serán WebViews — no como features independientes, sino como pantallas o sub-pantallas dentro de un feature existente. Ejemplo: en accounts, la home es nativa pero el detalle de una transacción puede abrir un WebView. También aplica a KYC, 3DS, contenido regulatorio, formularios legales, etc. Deben integrarse como una alternativa de implementación: navegación con go_router, comunicación bidireccional con la app, compartir sesión, y respetar el design system visual.

### Arquitectura: `packages/libs/webview/`

La infraestructura WebView es una **lib** (`packages/libs/webview/`) porque encapsula lógica de negocio compartida: gestión de sesión, inyección de token, bridge bidireccional, whitelist de dominios y cleanup de cookies. Internamente usa `flutter_inappwebview` (más control sobre seguridad que `webview_flutter`: certificate pinning, interceptación de requests, JS channels flexibles).

Los features importan esta lib y solo configuran **qué URL abrir** y **si requiere auth**. Todo lo demás (token, bridge, seguridad) lo resuelve la lib.

### WebView como detalle de implementación en features

Las pages WebView viven dentro del feature que les corresponde. La WebView es un detalle de implementación de la presentación — desde fuera se navega igual que a cualquier otra página nativa. El consumidor no sabe si el destino es Dart nativo o un WebView.

```dart
// packages/features/accounts/lib/presentation/pages/transaction_detail_webview_page.dart
import 'package:webview/banking_webview.dart';  // ← importa la lib, no core

class TransactionDetailWebViewPage extends StatelessWidget {
  final String transactionId;
  const TransactionDetailWebViewPage({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BankingAppBar(title: 'Detalle de movimiento'),
      body: BankingWebView(
        url: 'https://bankapp.com/transactions/$transactionId',
        isAuthenticated: true,  // La lib se encarga de inyectar token, bridge, whitelist
      ),
    );
  }
}

// packages/features/kyc/lib/presentation/pages/kyc_webview_page.dart
import 'package:webview/banking_webview.dart';  // ← misma lib

class KycWebViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BankingAppBar(title: 'Verificación de identidad'),
      body: BankingWebView(
        url: 'https://bankapp.com/kyc/start',
        isAuthenticated: true,   // La lib gestiona token, sesión expirada, etc.
        onEvent: (event) {
          // El feature maneja eventos custom del WebView
          if (event.type == WebViewEventType.custom) {
            // ej: KYC completado, documento firmado...
          }
        },
      ),
    );
  }
}
```

### Integración con go_router

Las WebViews se registran como rutas normales dentro de su feature. El redirect guard aplica igual — si requieren auth, pasan por el mismo flujo de sesión.

```dart
// packages/features/accounts/lib/routes.dart
final accountRoutes = [
  GoRoute(
    path: '/accounts/:id',
    builder: (context, state) => AccountDetailPage(
      accountId: state.pathParameters['id']!,
    ),
    routes: [
      // Detalle de transacción → puede ser WebView o nativo
      GoRoute(
        path: 'transactions/:txId',
        builder: (context, state) => TransactionDetailWebViewPage(
          transactionId: state.pathParameters['txId']!,
        ),
      ),
    ],
  ),
];

// packages/features/kyc/lib/routes.dart
final kycRoutes = [
  GoRoute(
    path: '/kyc',
    builder: (context, state) => const KycWebViewPage(),
  ),
];
```

### Comunicación bidireccional: App ↔ Web

```
┌─────────────────────┐                    ┌─────────────────────┐
│      Flutter App     │                    │       WebView       │
│                      │                    │                     │
│  BankingWebView      │  ── JS Channel ──► │  window.AppBridge   │
│                      │  (app → web)       │  .postMessage(...)  │
│  onMessageReceived   │ ◄── JS Handler ──  │                     │
│  (web → app)         │                    │  AppBridge.send()   │
└─────────────────────┘                    └─────────────────────┘
```

### BankingWebView: lib compartida (`packages/libs/webview/`)

Toda la infraestructura WebView vive en `packages/libs/webview/`, no en core. Es una **lib** porque contiene lógica de negocio (sesión, tokens, bridge de comunicación). Los features la importan como cualquier otra lib y solo se preocupan de qué URL abrir y si requiere auth — el resto lo resuelve la lib.

```dart
// packages/libs/webview/lib/banking_webview.dart
class BankingWebView extends StatefulWidget {
  final String url;
  final bool isAuthenticated;
  final void Function(WebViewEvent event)? onEvent;

  const BankingWebView({
    required this.url,
    this.isAuthenticated = false,
    this.onEvent,
  });

  @override
  State<BankingWebView> createState() => _BankingWebViewState();
}

class _BankingWebViewState extends State<BankingWebView> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,     // Interceptar navegación
        mediaPlaybackRequiresUserGesture: true,
        allowsBackForwardNavigationGestures: false,
      ),
      // ── Canal JavaScript: la web puede enviar eventos a la app ──
      onWebViewCreated: (controller) {
        _controller = controller;

        // Registrar handler que la web puede invocar
        controller.addJavaScriptHandler(
          handlerName: 'AppBridge',
          callback: (args) => _handleWebMessage(args),
        );
      },
      onLoadStart: (controller, url) async {
        // Inyectar token si es WebView autenticada
        if (widget.isAuthenticated) {
          await _injectAuthToken(controller);
        }
      },
      // ── Whitelist de URLs permitidas ──
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.host ?? '';
        if (_isAllowedDomain(url)) {
          return NavigationActionPolicy.ALLOW;
        }
        return NavigationActionPolicy.CANCEL;
      },
    );
  }

  // ── App → Web: inyectar datos ──
  Future<void> _injectAuthToken(InAppWebViewController controller) async {
    final token = await ref.read(secureStorageProvider).getAccessToken();
    if (token != null) {
      // Inyectar token via JavaScript (la web lo recoge de window.AppConfig)
      await controller.evaluateJavascript(source: '''
        window.AppConfig = {
          authToken: '$token',
          platform: 'flutter',
          locale: '${context.locale.languageCode}',
        };
      ''');
    }
  }

  // ── Web → App: recibir eventos ──
  dynamic _handleWebMessage(List<dynamic> args) {
    if (args.isEmpty) return;

    final message = args.first as Map<String, dynamic>;
    final event = WebViewEvent.fromJson(message);

    switch (event.type) {
      case WebViewEventType.close:
        Navigator.of(context).pop(event.data);
        break;
      case WebViewEventType.navigate:
        // La web pide navegar a una ruta nativa
        context.push(event.data['route'] as String);
        break;
      case WebViewEventType.sessionExpired:
        // La web detectó 401 → cerrar WebView y mandar a login
        context.go('/login');
        break;
      case WebViewEventType.custom:
        // Evento custom que el feature maneja
        widget.onEvent?.call(event);
        break;
    }
  }

  bool _isAllowedDomain(String host) {
    const allowedDomains = ['bankapp.com', 'cdn.bankapp.com', 'auth.bankapp.com'];
    return allowedDomains.any((domain) => host.endsWith(domain));
  }
}
```

### Contrato de eventos Web ↔ App

```dart
// packages/libs/webview/lib/webview_event.dart
enum WebViewEventType { close, navigate, sessionExpired, custom }

@freezed
class WebViewEvent with _$WebViewEvent {
  const factory WebViewEvent({
    required WebViewEventType type,
    Map<String, dynamic>? data,
  }) = _WebViewEvent;

  factory WebViewEvent.fromJson(Map<String, dynamic> json) =>
      _$WebViewEventFromJson(json);
}
```

```javascript
// Código JavaScript que la web usa para comunicarse con la app
// La web incluye este script o lo tiene integrado en su framework

// Leer datos que la app inyectó
const token = window.AppConfig?.authToken;
const locale = window.AppConfig?.locale;

// Enviar eventos a la app
function sendToApp(type, data) {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('AppBridge', { type, data });
  }
}

// Ejemplos de uso desde la web:
sendToApp('close', { result: 'kyc_completed' });           // Cerrar WebView y devolver resultado
sendToApp('navigate', { route: '/transactions/tx-123' });  // Pedir navegación nativa
sendToApp('sessionExpired', {});                            // Token expirado en la web
sendToApp('custom', { action: 'document_signed' });         // Evento custom del feature
```

### Seguridad en WebViews

| Control | Implementación |
|---------|---------------|
| **Whitelist de dominios** | `shouldOverrideUrlLoading` — solo permite navegación a dominios propios |
| **Token injection** | Se inyecta via `evaluateJavascript` en `onLoadStart`, nunca en la URL ni como parámetro |
| **Cookie cleanup** | `CookieManager.deleteAllCookies()` al cerrar sesión |
| **Certificate pinning** | Aplica dentro del WebView con `flutter_inappwebview` (no todos los packages lo soportan) |
| **Captura de pantalla** | `FLAG_SECURE` aplica a toda la activity, incluyendo WebViews |
| **Depuración WebView** | Deshabilitada en release (`InAppWebViewSettings.debuggingEnabled: false`) |

### Flujo de sesión en WebViews

```
WebView autenticada se abre
        │
        ▼
  onLoadStart → inyecta token en window.AppConfig
        │
        ▼
  La web usa el token para sus llamadas API
        │
        ├── Token válido → flujo normal
        │
        └── Token expirado (401)
                │
                ▼
          La web llama: sendToApp('sessionExpired', {})
                │
                ▼
          App cierra WebView → redirect a /login
                │
                ▼
          Tras re-login → pendingRoute redirige al destino original
```

---

## 12. Concurrencia e Isolates

### Modelo de hilos en Dart vs Kotlin/Swift

En Kotlin tienes `Dispatchers.Main`, `IO` y `Default`. En Dart el modelo es diferente pero el objetivo es el mismo: no bloquear el hilo de UI.

| Kotlin Dispatcher | Equivalente en Dart | Uso |
|-------------------|-------------------|-----|
| `Dispatchers.Main` | Main Isolate (event loop) | UI, setState, navegación, animaciones |
| `Dispatchers.IO` | `async/await` (no necesita isolate) | Networking, lectura/escritura disco — Dart I/O es non-blocking por naturaleza |
| `Dispatchers.Default` | `Isolate.run()` / `compute()` | CPU-intensive: parsing JSON grande, cifrado, procesamiento de imágenes |

**Regla clave**: en Dart, las operaciones de I/O (HTTP, disco, base de datos) ya son non-blocking con `async/await` — no necesitan un hilo aparte. Solo las operaciones CPU-intensive necesitan un Isolate.

### Cuándo usar Isolates en una app bancaria

| Operación | ¿Isolate? | Motivo |
|-----------|-----------|--------|
| Llamada HTTP (Dio) | No | `async/await` es suficiente, Dart I/O es non-blocking |
| Parseo de JSON pequeño (<100 items) | No | Lo hace el main isolate sin problema |
| Parseo de JSON grande (>500 items, historial de transacciones) | Sí | `jsonDecode` de un payload grande bloquea el UI thread |
| Cifrado/descifrado AES/RSA | Sí | Operación CPU-intensive |
| Procesamiento de imagen (recorte, compresión para KYC) | Sí | CPU-intensive |
| Validaciones complejas (IBAN, cálculos financieros batch) | Sí | Puede bloquear si son muchas operaciones |
| Lectura de flutter_secure_storage | No | I/O nativo async |
| Serialización de DTOs con freezed | No | Generalmente rápido |

### Isolate.run() — operaciones puntuales

`Isolate.run()` (Dart 2.19+, Flutter 3.7+) es la forma moderna y limpia de ejecutar una función pesada en un isolate. Crea el isolate, ejecuta, devuelve resultado y se destruye automáticamente.

```dart
// packages/core/common/lib/concurrency/isolate_runner.dart

/// Parseo de JSON grande en isolate
Future<List<TransactionDto>> parseTransactionsInBackground(String jsonString) async {
  return Isolate.run(() {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) => TransactionDto.fromJson(item as Map<String, dynamic>))
        .toList();
  });
}

/// Cifrado de datos sensibles en isolate
Future<String> encryptInBackground({
  required String plainText,
  required String key,
}) async {
  return Isolate.run(() {
    // Operación CPU-intensive que no bloquea el UI thread
    return AesEncryptor.encrypt(plainText, key);
  });
}
```

### Uso en el Repository

```dart
// packages/features/accounts/lib/data/repositories/account_repository_impl.dart
class AccountRepositoryImpl implements AccountRepository {
  final RemoteAccountDataSource _remote;

  @override
  Future<Either<Failure, List<TransactionModel>>> getTransactions({
    required String accountId,
    required DateRange dateRange,
  }) async {
    try {
      final response = await _remote.fetchTransactions(accountId, dateRange);

      // Si el payload es grande, parsear en background
      final List<TransactionModel> transactions;
      if (response.data.length > 500) {
        // Isolate: parseo pesado fuera del main thread
        final dtos = await parseTransactionsInBackground(response.rawJson);
        transactions = dtos.map(TransactionMapper.toModel).toList();
      } else {
        // Main isolate: parseo ligero, no merece el overhead de un isolate
        transactions = response.dtos.map(TransactionMapper.toModel).toList();
      }

      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

### Llamadas paralelas vs secuenciales

```dart
// ── PARALELO: operaciones independientes que pueden ejecutarse a la vez ──
Future<GlobalPositionData> loadGlobalPosition(String userId) async {
  // Future.wait ejecuta todas en paralelo y espera a que terminen todas
  final results = await Future.wait([
    accountRepository.getAccounts(userId),
    accountRepository.getRecentTransactions(userId),
    cardRepository.getCards(userId),
    notificationRepository.getUnreadCount(userId),
  ]);

  return GlobalPositionData(
    accounts: results[0] as List<AccountModel>,
    recentTransactions: results[1] as List<TransactionModel>,
    cards: results[2] as List<CardModel>,
    unreadNotifications: results[3] as int,
  );
}

// ── SECUENCIAL: operaciones que dependen del resultado anterior ──
Future<Either<Failure, PaymentResult>> executePayment(PaymentParams params) async {
  // 1. Validar cuenta origen
  final accountResult = await accountRepository.getAccount(params.fromAccountId);
  return accountResult.fold(
    (failure) => Left(failure),
    (account) async {
      // 2. Verificar saldo (depende del resultado anterior)
      if (account.balance < params.amount) {
        return Left(InsufficientFundsFailure());
      }

      // 3. Ejecutar transferencia (depende de la validación)
      final transferResult = await paymentRepository.transfer(params);
      return transferResult.fold(
        (failure) => Left(failure),
        (result) async {
          // 4. Notificar (depende de la transferencia exitosa)
          await notificationRepository.sendPaymentConfirmation(result);
          return Right(result);
        },
      );
    },
  );
}
```

### Patrón para BLoC: operaciones paralelas en la capa de presentación

```dart
class GlobalPositionBloc extends Bloc<GlobalPositionEvent, GlobalPositionState> {
  final GetAccountsUseCase _getAccounts;
  final GetRecentTransactionsUseCase _getTransactions;
  final GetCardsUseCase _getCards;

  Future<void> _onLoad(LoadGlobalPosition event, Emitter<GlobalPositionState> emit) async {
    emit(GlobalPositionLoading());

    // Lanzar todas las llamadas en paralelo
    final results = await Future.wait([
      _getAccounts(NoParams()),
      _getTransactions(GetTransactionsParams(limit: 10)),
      _getCards(NoParams()),
    ]);

    // Comprobar si alguna falló
    final accountsResult = results[0] as Either<Failure, List<AccountModel>>;
    final transactionsResult = results[1] as Either<Failure, List<TransactionModel>>;
    final cardsResult = results[2] as Either<Failure, List<CardModel>>;

    // Si todas ok, emitir estado loaded
    if (accountsResult.isRight() && transactionsResult.isRight() && cardsResult.isRight()) {
      emit(GlobalPositionLoaded(
        accounts: accountsResult.getOrElse((_) => []),
        transactions: transactionsResult.getOrElse((_) => []),
        cards: cardsResult.getOrElse((_) => []),
      ));
    } else {
      emit(GlobalPositionError('Error cargando la posición global'));
    }
  }
}
```

### Resumen de reglas

1. **I/O (HTTP, disco)**: `async/await` siempre. No necesita isolate.
2. **CPU-intensive**: `Isolate.run()` para operaciones puntuales pesadas.
3. **Llamadas independientes**: `Future.wait()` para paralelizar.
4. **Llamadas dependientes**: encadenar con `async/await` secuencial o `Either.fold()`.
5. **Umbral para Isolate**: si la operación tarda >16ms (un frame a 60fps), moverla a isolate.
6. **Nunca** crear isolates de larga vida para I/O — es un antipatrón en Dart.

---

## 13. Seguridad

### 12.1 Certificate Pinning (SSL Pinning)

Obligatorio para apps bancarias. Previene ataques MITM.

```dart
// Opción A: Dio + SecurityContext (pinning por certificado)
final certificate = await rootBundle.load('assets/certs/server.pem');
final securityContext = SecurityContext.defaultContext;
securityContext.setTrustedCertificatesBytes(certificate.buffer.asUint8List());

final httpClient = HttpClient(context: securityContext);
dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () => httpClient,
);
```

```dart
// Opción B: Pinning por hash de public key (más flexible para rotación)
// Package: http_certificate_pinning
```

### 12.2 Almacenamiento Seguro

```dart
// flutter_secure_storage (usa Keychain en iOS, EncryptedSharedPreferences en Android)
final secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
);

await secureStorage.write(key: 'access_token', value: token);
await secureStorage.write(key: 'refresh_token', value: refreshToken);
```

### 12.3 Autenticación Biométrica

```dart
// local_auth
final localAuth = LocalAuthentication();
final isAvailable = await localAuth.canCheckBiometrics;
final didAuthenticate = await localAuth.authenticate(
  localizedReason: 'Autentícate para acceder a tu cuenta',
  options: const AuthenticationOptions(
    stickyAuth: true,
    biometricOnly: true,
  ),
);
```

### 12.4 Detección de Amenazas en Runtime (Local, sin telemetría a terceros)

> **Decisión**: Se usa **`safe_device`** como librería de detección local,
> sin envío de datos ni telemetría a terceros.

`safe_device` cubre todas las verificaciones necesarias:
- Root/jailbreak (RootBeer en Android, IOSSecuritySuite en iOS)
- Detección de emulador, mock GPS, almacenamiento externo, modo desarrollador y depuración USB.

```dart
// packages/core/security/lib/threat_detection/device_threat_detector.dart
class DeviceThreatDetectorImpl implements DeviceThreatDetector {
  @override
  Future<ThreatReport> evaluate() async {
    // Ejecuta todos los checks en paralelo.
    final results = await Future.wait([
      _checkJailbroken(),   // FlutterJailbreakDetection
      _checkRealDevice(),   // SafeDevice.isRealDevice
      _checkMockLocation(), // SafeDevice.isMockLocation (Android)
      _checkExternalStorage(),
      _checkDeveloperMode(),
      _checkUsbDebugging(),
    ]);
    return ThreatReport(/* ... */);
  }
}

// Para dev/test: NoOpDeviceThreatDetector (siempre devuelve ThreatReport limpio).
```

Orquestación al arranque:
```dart
// En main_prod.dart
final initializer = SecurityInitializer(
  threatDetector: DeviceThreatDetectorImpl(),
  screenProtection: ScreenProtectionService(),
  policy: ThreatPolicy.block,  // Bloquea en producción si hay root/jailbreak
);
await initializer.initialize(onBlocked: () { /* pantalla de bloqueo */ });
```

### 12.5 Verificación de Integridad de la App (Play Integrity + App Attest)

Verifica que la app se ejecuta en un entorno legítimo y no ha sido modificada (repackaging, sideloading, etc.). Usa **`app_device_integrity`** que abstrae las APIs nativas de cada plataforma.

| Plataforma | API nativa | Qué verifica |
|------------|-----------|--------------|
| Android | **Play Integrity API** | App firmada por Google Play, dispositivo no rooteado, binario original |
| iOS | **App Attest / DeviceCheck** | App descargada desde App Store, dispositivo no comprometido |

```dart
// packages/core/security/lib/attestation/integrity_attestation_service.dart
abstract class IntegrityAttestationService {
  /// Genera un token de atestación firmado por Google/Apple.
  /// [challengeUuid]: nonce único del backend (previene replay attacks).
  /// El token se envía al backend en el header `X-Integrity-Token`
  /// para que lo valide contra los servidores de Google/Apple.
  Future<String?> getAttestationToken({required String challengeUuid});
}

class IntegrityAttestationServiceImpl implements IntegrityAttestationService {
  final String _gcpProjectId; // Solo requerido en Android

  @override
  Future<String?> getAttestationToken({required String challengeUuid}) async {
    final plugin = AppDeviceIntegrity();

    if (Platform.isAndroid) {
      return plugin.getAttestationServiceSupport(
        challengeString: challengeUuid,
        gcp: _gcpProjectId,
      );
    } else {
      return plugin.getAttestationServiceSupport(
        challengeString: challengeUuid,
      );
    }
  }
}

// Para dev/staging: MockIntegrityAttestationService (token falso).
```

**Flujo de verificación:**

1. App solicita un **challenge UUID** al backend (nonce de un solo uso).
2. App invoca `getAttestationToken(challengeUuid)` → API nativa genera token firmado.
3. App envía el token al backend en header `X-Integrity-Token`.
4. Backend valida el token contra servidores de Google/Apple.
5. Si la validación falla → el backend rechaza la petición.

**Configuración DI:**

```dart
// security_providers.dart — default: mock (dev)
// Override en main_staging/prod con:
SecurityProviders.integrityAttestation.overrideWithValue(
  IntegrityAttestationServiceImpl(gcpProjectId: 'YOUR_GCP_PROJECT_ID'),
)
```

> **Prerequisitos para producción:**
> - Android: configurar GCP Project ID vinculado a Play Console.
> - iOS: activar App Attest capability en Xcode + Apple Developer Portal.
> - Backend: endpoint de validación de tokens contra las APIs de Google/Apple.

### 12.6 Ofuscación de Código

```bash
# Build con ofuscación (obligatorio para producción)
flutter build apk \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --release

flutter build ipa \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --release
```

### 12.7 Prevención de Captura de Pantalla

```dart
// flutter_windowmanager (Android) + método nativo (iOS)
// Android: FLAG_SECURE
await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

// iOS: requiere implementación nativa con UITextField.isSecureTextEntry trick
```

### 12.8 Protección del Portapapeles

```dart
// Limpiar clipboard después de copiar datos sensibles
Future<void> secureCopy(String sensitiveData) async {
  await Clipboard.setData(ClipboardData(text: sensitiveData));
  // Limpiar después de 30 segundos
  Future.delayed(const Duration(seconds: 30), () {
    Clipboard.setData(const ClipboardData(text: ''));
  });
}
```

### 12.9 Gestión de Sesión

```dart
class SessionManager {
  static const _inactivityTimeout = Duration(minutes: 5);
  Timer? _inactivityTimer;

  void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, _onSessionExpired);
  }

  void _onSessionExpired() {
    // Limpiar tokens, navegar a login, limpiar estado sensible
  }

  // Llamar en cada interacción del usuario (GestureDetector en el root)
}
```

### 12.9 Checklist OWASP MASVS

| Control | Implementación |
|---------|---------------|
| Almacenamiento seguro | flutter_secure_storage (Keychain/Keystore) |
| Comunicación segura | Certificate pinning + TLS 1.2+ |
| Autenticación | Biometrics + PIN + 2FA |
| Integridad de código | Ofuscación + safe_device + firma de app |
| Anti-reversión | ProGuard/R8 (Android) + Bitcode (iOS) |
| Detección de entorno | Root/jailbreak detection + emulator detection |
| Logging seguro | No logs sensibles en release, crashlytics filtrado |
| Protección de datos | Encryption at rest, clipboard protection, screen capture prevention |

---

## 14. Testing

### Estrategia de Testing

```
                    ┌──────────────┐
                    │  E2E Tests   │  ← Patrol / integration_test
                    │  (pocos)     │
                ┌───┴──────────────┴───┐
                │   Widget Tests       │  ← flutter_test
                │   (bastantes)        │
            ┌───┴──────────────────────┴───┐
            │       Unit Tests             │  ← test + mocktail
            │       (muchos)               │
            └──────────────────────────────┘
```

### Coverage mínimo recomendado para banking

- **Domain layer**: 95%+ (lógica de negocio crítica)
- **Data layer**: 85%+ (repositorios, data sources)
- **BLoC/Cubits**: 90%+ (state management)
- **Widgets**: 70%+ (UI components)
- **Overall**: 80%+ mínimo

### Unit Testing

```dart
// mocktail (recomendado sobre mockito - no necesita code generation)
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late GetTransactionsUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  test('should return list of transactions from repository', () async {
    // Arrange
    when(() => mockRepository.getTransactions(
      accountId: any(named: 'accountId'),
      dateRange: any(named: 'dateRange'),
    )).thenAnswer((_) async => Right(testTransactions));

    // Act
    final result = await useCase(testParams);

    // Assert
    expect(result, Right(testTransactions));
    verify(() => mockRepository.getTransactions(
      accountId: testParams.accountId,
      dateRange: testParams.dateRange,
    )).called(1);
  });
}
```

### BLoC Testing

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('TransactionBloc', () {
    late MockGetTransactionsUseCase mockGetTransactions;

    setUp(() {
      mockGetTransactions = MockGetTransactionsUseCase();
    });

    blocTest<TransactionBloc, TransactionState>(
      'emits [Loading, Loaded] when FetchTransactions succeeds',
      build: () {
        when(() => mockGetTransactions(any()))
            .thenAnswer((_) async => Right(testTransactions));
        return TransactionBloc(getTransactions: mockGetTransactions);
      },
      act: (bloc) => bloc.add(FetchTransactions('account-123')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [Loading, Error] when FetchTransactions fails',
      build: () {
        when(() => mockGetTransactions(any()))
            .thenAnswer((_) async => Left(ServerFailure('Error del servidor')));
        return TransactionBloc(getTransactions: mockGetTransactions);
      },
      act: (bloc) => bloc.add(FetchTransactions('account-123')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionError>(),
      ],
    );
  });
}
```

### Widget Testing

```dart
void main() {
  testWidgets('LoginPage shows error on invalid credentials', (tester) async {
    final mockAuthBloc = MockAuthBloc();

    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
      ),
    );

    // Tap login without filling fields
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('El DNI es obligatorio'), findsOneWidget);
  });
}
```

### Golden Testing

```dart
void main() {
  testWidgets('TransactionListItem matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: TransactionListItem(transaction: testTransaction),
        ),
      ),
    );

    await expectLater(
      find.byType(TransactionListItem),
      matchesGoldenFile('goldens/transaction_list_item.png'),
    );
  });
}
```

### Integration Testing con Patrol

```dart
// integration_test/login_flow_test.dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('user can login and see globalposition', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    // Login flow
    await $(#dniField).enterText('12345678X');
    await $(#passwordField).enterText('securePassword123');
    await $(#loginButton).tap();

    // Verify globalposition
    await $.waitUntilVisible($(#globalPositionPage));
    expect($(#accountBalance), findsOneWidget);
  });
}
```

### Testing en Multi-Módulo

```bash
# Cada módulo tiene sus propios tests
melos test                              # Todos los módulos
melos exec --scope="authentication" -- flutter test  # Solo authentication
melos test:changed                      # Solo módulos modificados (CI)

# Coverage por módulo
melos exec -- flutter test --coverage
melos exec -- genhtml coverage/lcov.info -o coverage/html
```

---

## 15. UI (Design System)

### Estructura del paquete UI

El paquete UI (design system) es un paquete Dart/Flutter independiente que todos los features importan.

### Design Tokens

```dart
// packages/core/ui/lib/tokens/colors.dart
abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryVariant = Color(0xFF1557B0);
  static const Color secondary = Color(0xFF03DAC6);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Neutral
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color outline = Color(0xFF79747E);
}

// packages/core/ui/lib/tokens/spacing.dart
abstract class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Semantic spacing
  static const double pagePadding = 16.0;
  static const double cardPadding = 12.0;
  static const double sectionGap = 24.0;
}

// packages/core/ui/lib/tokens/typography.dart
abstract class AppTypography {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ... más estilos siguiendo Material 3 type scale
}

// packages/core/ui/lib/tokens/radii.dart
abstract class AppRadii {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 999.0;
}
```

### Theming (Material 3)

```dart
// packages/core/ui/lib/theme/app_theme.dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: _buildTextTheme(),
    elevatedButtonTheme: _elevatedButtonTheme(),
    inputDecorationTheme: _inputDecorationTheme(),
    cardTheme: _cardTheme(),
    extensions: const [
      BankingColorExtension.light(),
    ],
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: _buildTextTheme(),
    extensions: const [
      BankingColorExtension.dark(),
    ],
  );
}

// ThemeExtension para colores semánticos de banca
class BankingColorExtension extends ThemeExtension<BankingColorExtension> {
  final Color positiveAmount;
  final Color negativeAmount;
  final Color pendingAmount;
  final Color frozenCard;

  const BankingColorExtension({
    required this.positiveAmount,
    required this.negativeAmount,
    required this.pendingAmount,
    required this.frozenCard,
  });

  const BankingColorExtension.light()
      : positiveAmount = const Color(0xFF2E7D32),
        negativeAmount = const Color(0xFFC62828),
        pendingAmount = const Color(0xFFEF6C00),
        frozenCard = const Color(0xFF90A4AE);

  const BankingColorExtension.dark()
      : positiveAmount = const Color(0xFF66BB6A),
        negativeAmount = const Color(0xFFEF5350),
        pendingAmount = const Color(0xFFFFA726),
        frozenCard = const Color(0xFF78909C);

  @override
  ThemeExtension<BankingColorExtension> copyWith({ /* ... */ }) { /* ... */ }

  @override
  ThemeExtension<BankingColorExtension> lerp(covariant ThemeExtension<BankingColorExtension>? other, double t) { /* ... */ }
}
```

### Atomic Design: Componentes

```dart
// ATOM: packages/core/ui/lib/atoms/app_button.dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      ),
    );
  }
}

// MOLECULE: packages/core/ui/lib/molecules/amount_display.dart
class AmountDisplay extends StatelessWidget {
  final Money amount;
  final AmountDisplaySize size;

  const AmountDisplay({required this.amount, this.size = AmountDisplaySize.medium});

  @override
  Widget build(BuildContext context) {
    final bankingColors = Theme.of(context).extension<BankingColorExtension>()!;
    final color = amount.isPositive ? bankingColors.positiveAmount : bankingColors.negativeAmount;

    return Text(
      amount.formatted,
      style: _textStyle(context).copyWith(color: color),
    );
  }
}
```

### Widgetbook (Storybook para Flutter)

```yaml
# packages/core/ui/pubspec.yaml
dev_dependencies:
  widgetbook: ^3.x.x
```

Widgetbook permite visualizar y testear todos los componentes del design system de forma aislada, con knobs interactivos para probar diferentes estados, temas (light/dark) y tamaños de pantalla.

### Accesibilidad (a11y)

- Mínimo 48x48px para targets táctiles
- Contraste mínimo 4.5:1 para texto normal, 3:1 para texto grande
- Usar `Semantics` widgets para screen readers
- Testar con TalkBack (Android) y VoiceOver (iOS)
- Material 3 ColorScheme.fromSeed genera colores accesibles automáticamente

---

## 16. CI/CD y DevOps

### Plataforma recomendada: GitHub Actions + Codemagic

- **GitHub Actions**: análisis, tests, checks en PRs
- **Codemagic**: builds nativos (iOS/Android), signing, distribución

### Pipeline de PR (GitHub Actions)

```yaml
name: PR Checks
on: [pull_request]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.2'
          channel: 'stable'
          cache: true

      - name: Install Melos
        run: dart pub global activate melos

      - name: Bootstrap
        run: melos bootstrap

      - name: Format check
        run: melos format:check

      - name: Analyze
        run: melos analyze

      - name: Run tests (changed packages only)
        run: melos test:changed

      - name: Check coverage threshold
        run: |
          # Verificar que coverage > 80%
          melos exec -- flutter test --coverage
          # Script para verificar threshold
```

### Flavors / Environments

```bash
# Desarrollo (importa mock, selector de entorno MOCK/PRE/PRO en caliente, logging verbose)
flutter run --flavor dev -t lib/main_dev.dart

# Staging (NO importa mock → mock no compila, apunta fijo a PRE, analytics habilitados)
flutter run --flavor staging -t lib/main_staging.dart

# Producción (NO importa mock → mock no compila, apunta fijo a PRO, ofuscación, sin logs)
flutter build apk --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/debug-info
```

> **Nota sobre compilación de mock**: como `main_staging.dart` y `main_prod.dart` nunca importan el paquete `mock`, el tree-shaking de Dart elimina todo el código mock del binario final. Esto significa cero overhead en tamaño de APK/IPA y cero riesgo de que datos de test lleguen a producción.

```dart
// lib/config/env_config.dart
enum Environment { dev, staging, prod }

class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableAnalytics;

  const EnvConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableAnalytics,
  });

  static const dev = EnvConfig._(
    environment: Environment.dev,
    apiBaseUrl: 'https://api-dev.bank.com/v1',
    enableLogging: true,
    enableAnalytics: false,
  );

  static const staging = EnvConfig._(
    environment: Environment.staging,
    apiBaseUrl: 'https://api-staging.bank.com/v1',
    enableLogging: true,
    enableAnalytics: true,
  );

  static const prod = EnvConfig._(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.bank.com/v1',
    enableLogging: false,
    enableAnalytics: true,
  );
}
```

### Distribución

| Etapa | iOS | Android |
|-------|-----|---------|
| Internal testing | TestFlight (interno) | Firebase App Distribution |
| Beta testing | TestFlight (externo) | Play Console (internal testing track) |
| Producción | App Store | Play Store |

### Análisis Estático

| Herramienta | Uso |
|------------|-----|
| `dart analyze` | Análisis estándar del SDK |
| `very_good_analysis` | Reglas de lint curadas y estrictas |
| DCM (Dart Code Metrics) | Métricas avanzadas de calidad, complejidad ciclomática |
| `custom_lint` | Reglas personalizadas del equipo |

---

## 17. Developer Experience

### Git Hooks con Lefthook

```yaml
# lefthook.yaml
pre-commit:
  parallel: true
  commands:
    format:
      glob: "*.dart"
      run: dart format {staged_files}
    analyze:
      glob: "*.dart"
      run: dart analyze
    custom-lint:
      glob: "*.dart"
      run: dart run custom_lint

commit-msg:
  commands:
    conventional-commit:
      run: |
        if ! grep -qE "^(feat|fix|refactor|test|docs|ci|chore|style|perf)(\(.+\))?: " "$1"; then
          echo "Error: commit message must follow Conventional Commits format"
          echo "Example: feat(auth): add biometric login"
          exit 1
        fi

pre-push:
  commands:
    tests:
      run: melos test:changed
```

### Code Generation

```bash
# build_runner para generar código
melos build:runner

# Packages que requieren code generation:
# - freezed / freezed_annotation (data classes inmutables)
# - json_serializable / json_annotation (serialización JSON)
# - injectable / injectable_generator (DI con get_it, si se usa)
# - riverpod_generator (providers de Riverpod 3.x)
# - go_router_builder (type-safe routing, opcional)
```

### Conventional Commits

```
feat(payments): add international wire transfer flow
fix(auth): resolve token refresh race condition
refactor(core): extract network error handling to shared interceptor
test(accounts): add golden tests for transaction list item
docs(readme): update setup instructions for new devs
ci(github): add coverage threshold check to PR pipeline
chore(deps): bump dio to 5.x, freezed to 3.x
```

### CODEOWNERS

```
# .github/CODEOWNERS
packages/core/                @core-team
packages/core/ui/             @design-system-team
packages/core/security/       @security-team
packages/libs/                @libraries-team
packages/libs/otp/            @auth-team
packages/libs/webview/        @platform-team
packages/libs/promotions/     @marketing-team
packages/features/auth*/      @auth-team
packages/features/globalposition/ @globalposition-team
packages/features/accounts/   @accounts-team
packages/features/payment*/   @payments-team
packages/features/cards/      @cards-team
packages/features/notification*/ @notifications-team
apps/mobile_app/              @platform-team
```

---

## 18. Tabla Resumen de Dependencias

### Core

| Categoría | Package | Uso |
|-----------|---------|-----|
| HTTP Client | `dio` | Networking con interceptors |
| Functional Programming | `fpdart` | Either, Option para error handling |
| Data Classes | `freezed` + `freezed_annotation` | ==, hashCode, copyWith, toString, pattern matching (entidades + DTOs) |
| JSON | `json_serializable` + `json_annotation` | Serialización/deserialización JSON (solo DTOs en capa data) |
| Code Gen | `build_runner` | Orquestador de code generation |

### State Management & DI

| Categoría | Package | Uso |
|-----------|---------|-----|
| State (features) | `flutter_bloc` | BLoC/Cubit pattern |
| DI + State (global) | `riverpod` + `riverpod_annotation` + `riverpod_generator` | DI container único + estado app-wide |
| BLoC Testing | `bloc_test` | Testing de BLoC/Cubit |

### Navegación

| Categoría | Package | Uso |
|-----------|---------|-----|
| Router | `go_router` | Declarative routing, deep linking |

### WebViews (`packages/libs/webview/`)

| Categoría | Package | Uso |
|-----------|---------|-----|
| WebView engine | `flutter_inappwebview` | WebViews con JS channels, certificate pinning, cookie management |
| Lib interna | `webview` (lib propia) | BankingWebView, AppBridge, gestión de sesión, whitelist, eventos |

### Seguridad

| Categoría | Package | Uso |
|-----------|---------|-----|
| Secure Storage | `flutter_secure_storage` | Keychain (iOS) / Keystore (Android) |
| Biometrics | `local_auth` | Fingerprint, Face ID |
| Threat Detection | `safe_device` | Root/jailbreak, emulador, mock GPS, modo desarrollador |
| App Integrity | `app_device_integrity` | Play Integrity (Android), App Attest (iOS) |
| Screen Protection | `flutter_windowmanager` | Prevenir capturas de pantalla (Android) |

### Caché y Persistencia

| Categoría | Package | Uso |
|-----------|---------|-----|
| Caché HTTP (memoria) | `dio_cache_interceptor` | MemCacheStore, solo en RAM |
| Persistencia cifrada (disco) | `flutter_secure_storage` | Todo key-value cifrado: tokens, config, preferencias |

### Internacionalización

| Categoría | Package | Uso |
|-----------|---------|-----|
| i18n + deltas remotos | `easy_localization` | Multi-idioma con traducciones base bundled + custom asset loader para deltas del servidor |

### Testing

| Categoría | Package | Uso |
|-----------|---------|-----|
| Mocking | `mocktail` | Mocks sin code generation |
| BLoC Test | `bloc_test` | Testing de BLoC/Cubit |
| Integration | `patrol` | E2E testing nativo |
| Golden | `alchemist` | Golden testing mejorado |

### DevOps & DX

| Categoría | Package/Tool | Uso |
|-----------|-------------|-----|
| Monorepo | `melos` | Orquestación de monorepo |
| Linting | `very_good_analysis` | Reglas de lint estrictas |
| Metrics | DCM | Métricas avanzadas de código |
| Custom Rules | `custom_lint` | Reglas personalizadas |
| Git Hooks | `lefthook` | Pre-commit, pre-push hooks |
| Design System | `widgetbook` | Storybook para Flutter |

### UI & Design

| Categoría | Package | Uso |
|-----------|---------|-----|
| Theming | Material 3 (built-in) | ColorScheme, Typography, ThemeExtensions |
| Icons | `flutter_svg` | SVG icons del design system |
| Animations | `flutter_animate` | Animaciones declarativas |
| Shimmer | `shimmer` | Loading placeholders |

---

> **Siguiente paso**: Iterar sobre este documento, profundizar en las secciones que necesites y definir las decisiones finales del equipo antes de empezar a scaffoldear el proyecto.
