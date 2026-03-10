# Flutter Banking App — Claude Code Instructions

> Documento de referencia completo: [flutter_banking_architecture.md](flutter_banking_architecture.md)

## Stack

- **Flutter 3.41.2** / Dart 3.11 — Android + iOS
- **Monorepo**: Pub Workspaces + Melos
- **State**: BLoC 9.x (features) + Riverpod 3.x (DI + global state)
- **Routing**: go_router con ShellRoute, redirect guards, deep links
- **Errors**: `Either<Failure, T>` de fpdart
- **Serialización**: Freezed + json_serializable
- **Linting**: very_good_analysis
- **Idioma de la UI**: Español

## Estructura del monorepo

```
apps/mobile_app/              # Composition root (3 entry points: dev/staging/prod)
packages/core/common/         # Networking (Dio), config, errors, UseCase base, formatters, FeatureRoutes
packages/core/ui/             # Design system: tokens, theme, atoms, molecules, organisms
packages/core/domain/         # Entidades compartidas (User, Account, Transaction, CardEntity)
packages/core/security/       # SecureStorage, biometrics, SessionManager
packages/core/mock/           # Mock datasources + JSON fixtures (SOLO DEV)
packages/libs/otp/            # OTP verification (interceptor Dio + flow widget)
packages/libs/webview/        # BankingWebView (InAppWebView wrapper)
packages/libs/promotions/     # PromoBanner, PromoCarousel + di/promotions_providers.dart
packages/features/<feature>/  # 8 features independientes (cada uno con di/ y routing/)
```

## Reglas de dependencia (ESTRICTAS)

```
features → libs → core          (dirección permitida)
features ✗ features             (NUNCA importar un feature desde otro)
libs ✗ features                 (NUNCA)
core ✗ libs, core ✗ features    (NUNCA, excepto core/mock)
core/mock → features            (excepción: solo en main_dev.dart)
```

## Arquitectura por feature (Clean Architecture)

Cada feature sigue EXACTAMENTE esta estructura:

```
packages/features/<name>/lib/
├── di/
│   └── <name>_providers.dart       # Providers Riverpod (datasource + repository)
├── routing/
│   └── <name>_routes.dart          # Retorna FeatureRoutes (shellRoutes + fullScreenRoutes)
├── presentation/
│   ├── <screen_name>/              # Carpeta por pantalla
│   │   ├── bloc/                         # BLoC + Freezed files
│   │   │   ├── <screen_name>_bloc.dart       # extends Bloc<Event, State>
│   │   │   ├── <screen_name>_event.dart      # sealed class + final class per event
│   │   │   ├── <screen_name>_state.dart      # sealed class + final class per state
│   │   │   └── generated/                    # Archivos generados por Freezed
│   │   ├── page/                         # Widget de presentación
│   │   │   └── <screen_name>_page.dart       # Page (StatefulWidget)
│   │   └── widgets/                      # (opcional) Widgets propios de esta pantalla
│   ├── <another_screen>/           # Otra pantalla del feature
│   │   └── ...
│   └── widgets/                    # Widgets compartidos entre varias pages del feature
├── domain/
│   ├── entities/                   # Modelos puros de dominio (sin dependencias)
│   ├── repositories/               # Contratos abstractos (abstract class)
│   └── usecases/                   # extends UseCase<Type, Params>
└── data/
    ├── datasources/                # Contratos abstractos (abstract class)
    ├── models/                     # DTOs con .toEntity() y .fromJson()
    └── repositories/               # Implementaciones concretas (Either<Failure, T>)
```

## Patrones obligatorios

### BLoC
- Events son **`@freezed sealed class`** (exhaustive pattern matching)
- States son **`@freezed abstract class`** con **single class + status enum** (patrón oficial BLoC)
  - Un `enum <Feature>Status { initial, loading, loaded, error }` por estado
  - Una sola clase `@freezed abstract class <Feature>State` con todos los campos y `@Default` values
  - Campos nullable para datos que no existen en todos los status (ej. `Account? account`)
  - Usar `state.copyWith(status: ..., field: ...)` para emitir cambios
  - En widgets: `switch (state.status) { ... }` para discriminar el estado
  - Getters computados con constructor privado: `const <Feature>State._();` después del factory
- Usan mixin `_$<Name>` generado por Freezed (NO Equatable)
- Usan `part` / `part of` (event y state en archivos separados)
- Archivos generados (`.freezed.dart`) van en subcarpeta `bloc/generated/` junto al fuente
- Handlers se nombran `_on<EventName>`
- Siempre emitir al menos un estado
- Inyección por constructor (NUNCA service locator)

### UseCase
- Extiende `UseCase<Type, Params>` de `packages/core/common/lib/usecases/usecase.dart`
- Retorna `Future<Either<Failure, Type>>`
- Usa `NoParams` cuando no hay parámetros

### Repository
- Interfaz abstracta en `domain/repositories/`
- Implementación en `data/repositories/`
- SIEMPRE retorna `Either<Failure, T>` — NUNCA lanza excepciones
- Catch de `DioException` → `ServerFailure`, catch genérico → `ServerFailure`

### DTO → Entity
- DTOs (data layer) tienen `.toEntity()` y `factory .fromJson(Map<String, dynamic>)`
- DTOs son serializables (`@JsonSerializable`), entities de dominio NO
- La conversión ocurre en el repository, NUNCA en la UI

### DI (Riverpod)
- Providers de cada feature en su propio módulo: `<feature>/lib/di/<feature>_providers.dart`
- `providers.dart` del app re-exporta todos los feature providers para compatibilidad
- DataSources como `Provider` con `throw UnimplementedError('Must be overridden')`
- Override en `main_dev.dart` con mocks, en `main_staging/prod.dart` con implementaciones reales
- Acceso en router: `ProviderScope.containerOf(context)`

### Routing
- Cada feature expone `FeatureRoutes` desde `<feature>/lib/routing/<feature>_routes.dart`
- `FeatureRoutes` tiene `shellRoutes` (dentro del ShellRoute) y `fullScreenRoutes`
- `app_router.dart` compone las rutas de todos los features
- BlocProviders se instancian en la función de routing del feature PER ROUTE (NUNCA en páginas)
- Auth guard en `GoRouter.redirect` (NO en páginas individuales)
- Comunicación entre features: `context.go()` / `context.push()` + `extra`

## Failure types (sealed class)

```dart
@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({...})  = ServerFailure;   // Error de servidor
  const factory Failure.cache({...})   = CacheFailure;    // Error de caché local
  const factory Failure.auth({...})    = AuthFailure;     // Error de autenticación
  const factory Failure.network({...}) = NetworkFailure;  // Sin conexión
}
```

## Comandos Melos

```bash
melos analyze          # Lint de todos los paquetes
melos test             # Tests con coverage
melos test:changed     # Tests solo de paquetes modificados
melos format:check     # Verificar formato Dart
melos build:runner     # Code generation (freezed, json_serializable)
melos clean            # flutter clean en todos
melos deps:upgrade     # Actualizar dependencias
```

## Credenciales mock (SOLO DEV)

- DNI: `12345678A` / Password: `Test1234!` (con OTP)
- DNI: `87654321B` / Password: `Demo1234!` (sin OTP)
- OTP: `123456`

## Anti-patrones (PROHIBIDOS)

1. **NUNCA** importar un feature desde otro feature
2. **NUNCA** lanzar excepciones en repositories/usecases — usar Either
3. **NUNCA** usar StateProvider — usar Notifier
4. **NUNCA** crear BlocProvider dentro de una página — se hace en la función de routing del feature
5. **NUNCA** hacer lógica de negocio en widgets — pertenece al BLoC o UseCase
6. **NUNCA** importar `core/mock` fuera de `main_dev.dart`
7. **NUNCA** editar archivos generados (`*.g.dart`, `*.freezed.dart`) — usar build_runner
8. **NUNCA** hardcodear tokens, API keys o secretos — usar SecureStorage o env config
9. **NUNCA** usar `dynamic` — tipar siempre
10. **NUNCA** hacer force push a main

## Convenciones de nombrado

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Paquete feature | snake_case | `pagos_programados` |
| Archivo Dart | snake_case | `auth_bloc.dart` |
| Clase | PascalCase | `AuthBloc`, `LoginUseCase` |
| BLoC | `<Feature>Bloc` | `PaymentBloc` |
| Event | `<Acción>Requested/Loaded` | `LoginRequested`, `AccountsLoaded` |
| State | `<Feature>State` | `LoginState`, `AccountDetailState` |
| Status enum | `<Feature>Status` | `LoginStatus`, `AccountDetailStatus` |
| UseCase | `<Acción>UseCase` | `GetAccountDetailUseCase` |
| Repository | `<Feature>Repository` | `AuthRepository` (abstracto), `AuthRepositoryImpl` (concreto) |
| DataSource | `Remote<Feature>DataSource` | `RemoteAuthDataSource` |
| DTO (data layer) | `<Entity>Dto` | `AuthTokenDto`, `AccountDto` |
| Provider | `<tipo><feature>Provider` | `remoteAuthDataSourceProvider`, `authRepositoryProvider` |

## Al crear un nuevo feature

1. Crear paquete en `packages/features/<name>/` con la estructura Clean Architecture completa
2. Crear `pubspec.yaml` con `resolution: workspace` y dependencias de core + `flutter_riverpod` + `go_router`
3. Crear `di/<name>_providers.dart` con datasource y repository providers
4. Crear `routing/<name>_routes.dart` que retorne `FeatureRoutes`
5. Exportar `di/` y `routing/` en el barrel file del feature
6. Añadir re-export en `apps/mobile_app/lib/di/providers.dart`
7. Componer rutas en `apps/mobile_app/lib/routing/app_router.dart`
8. Crear mock datasource en `packages/core/mock/lib/datasources/`
9. Override del mock en `main_dev.dart`
10. Ejecutar `melos bootstrap` para resolver dependencias
