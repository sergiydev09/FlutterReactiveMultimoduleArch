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
packages/core/common/         # Networking (Dio), config, errors, UseCase base, formatters
packages/core/ui/             # Design system: tokens, theme, atoms, molecules, organisms
packages/core/domain/         # Entidades compartidas (User, Account, Transaction, CardEntity)
packages/core/security/       # SecureStorage, biometrics, SessionManager
packages/core/mock/           # Mock datasources + JSON fixtures (SOLO DEV)
packages/libs/otp/            # OTP verification (interceptor Dio + flow widget)
packages/libs/webview/        # BankingWebView (InAppWebView wrapper)
packages/libs/promotions/     # PromoBanner, PromoCarousel
packages/features/<feature>/  # 8 features independientes
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
├── presentation/
│   ├── <screen_name>/              # Carpeta por pantalla
│   │   ├── <screen_name>_page.dart       # Page (StatefulWidget)
│   │   ├── <screen_name>_bloc.dart       # extends Bloc<Event, State>
│   │   ├── <screen_name>_event.dart      # sealed class + final class per event
│   │   ├── <screen_name>_state.dart      # sealed class + final class per state
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
- Events y States son **`@freezed sealed class`** (exhaustive pattern matching)
- Usan mixin `_$<Name>` generado por Freezed (NO Equatable)
- Usan `part` / `part of` (event y state en archivos separados)
- Archivos generados (`.freezed.dart`) van en subcarpeta `generated/` junto al fuente
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

### Model → Entity
- Models tienen `.toEntity()` y `factory .fromJson(Map<String, dynamic>)`
- La conversión ocurre en el repository, NUNCA en la UI

### DI (Riverpod)
- Providers definidos en `apps/mobile_app/lib/di/providers.dart`
- DataSources como `Provider` con `throw UnimplementedError('Must be overridden')`
- Override en `main_dev.dart` con mocks, en `main_staging/prod.dart` con implementaciones reales
- Acceso en router: `ProviderScope.containerOf(context)`

### Routing
- BlocProviders se instancian en `app_router.dart` PER ROUTE (NUNCA en páginas)
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
4. **NUNCA** crear BlocProvider dentro de una página — se hace en app_router.dart
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
| State | `<Feature><Estado>` | `AuthLoading`, `AuthAuthenticated` |
| UseCase | `<Acción>UseCase` | `GetAccountDetailUseCase` |
| Repository | `<Feature>Repository` | `AuthRepository` (abstracto), `AuthRepositoryImpl` (concreto) |
| DataSource | `Remote<Feature>DataSource` | `RemoteAuthDataSource` |
| Model | `<Entity>Model` | `AuthTokenModel` |
| Provider | `<tipo><feature>Provider` | `remoteAuthDataSourceProvider`, `authRepositoryProvider` |

## Al crear un nuevo feature

1. Crear paquete en `packages/features/<name>/` con la estructura Clean Architecture completa
2. Crear `pubspec.yaml` con `resolution: workspace` y dependencias de core
3. Registrar providers en `apps/mobile_app/lib/di/providers.dart`
4. Añadir rutas en `apps/mobile_app/lib/routing/app_router.dart`
5. Crear mock datasource en `packages/core/mock/lib/datasources/`
6. Override del mock en `main_dev.dart`
7. Ejecutar `melos bootstrap` para resolver dependencias
