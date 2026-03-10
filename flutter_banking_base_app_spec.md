# Especificación: App Base Bancaria Flutter

> **Package**: `com.company.app`
> **Flutter 3.41.2 (Stable) · Dart 3.x · iOS & Android**
> App de referencia que implementa toda la arquitectura definida en `flutter_banking_architecture.md`.
> Sirve como punto de partida para el desarrollo real.

---

## Tabla de Contenidos

1. [Objetivo](#1-objetivo)
2. [Inventario de Módulos](#2-inventario-de-módulos)
   - [App](#21-app-composition-root) · [Core](#22-core) · [Libs](#23-libs) · [Features](#24-features) · [Dependencias](#25-reglas-de-dependencia) · [Tabla de Pantallas](#26-tabla-de-pantallas-completa)
3. [Mock Layer: Estándar de Emulación](#3-mock-layer-estándar-de-emulación)
4. [Selector de Entorno en Caliente](#4-selector-de-entorno-en-caliente)
5. [Pantallas y Flujos](#5-pantallas-y-flujos)
6. [Datos de Ejemplo](#6-datos-de-ejemplo)
7. [Checklist de Arquitectura Cubierta](#7-checklist-de-arquitectura-cubierta)

---

## 1. Objetivo

Crear una app Flutter funcional que:

- Implemente **todos los puntos de la arquitectura** definida (monorepo multi-módulo, Clean Architecture, BLoC + Riverpod, go_router con deep links, seguridad, i18n, WebViews, concurrencia, ui, CI/CD, testing)
- Sirva como **punto de partida real** para los equipos de desarrollo
- Estandarice el **mock layer** como patrón para cuando el backend no esté disponible
- Permita **cambiar de entorno en caliente** (MOCK / PRE / PRO) desde el login en la versión de desarrollo
- Demuestre todos los patrones con **pantallas reales y funcionales** (no stubs vacíos)

---

## 2. Inventario de Módulos

Listado completo de todos los paquetes del monorepo, organizados por capa, con su responsabilidad y dependencias.

### 2.1 App (Composition Root)

| Paquete | Path | Responsabilidad | Entry Points |
|---------|------|-----------------|--------------|
| **mobile_app** | `apps/mobile_app/` | Composición de dependencias, routing, MaterialApp | `main_dev.dart` (importa mock), `main_staging.dart` (PRE, sin mock), `main_prod.dart` (PRO, sin mock) |

### 2.2 Core (Infraestructura compartida — sin lógica de negocio)

| Paquete | Path | Responsabilidad | Depende de |
|---------|------|-----------------|------------|
| **common** | `packages/core/common/` | Networking (Dio, interceptors, certificate pinning), config de entorno, error handling (`Failure` sealed), base `UseCase`, extensions, formatters, validators, i18n (`easy_localization` config, `RemoteDeltaAssetLoader`, `LocaleKeys` generadas) | Flutter SDK |
| **ui** | `packages/core/ui/` | Design system: tokens (colors, typography, spacing, radii), temas (light/dark con `ThemeExtension`), componentes atómicos (atoms: `AppButton`, `AppInput`; molecules: `AmountDisplay`, `SearchBar`; organisms: `BankingAppBar`, `BottomSheet`) | Flutter SDK |
| **domain** | `packages/core/domain/` | Entidades compartidas cross-feature (`UserModel`, `AccountModel`, `Currency`), value objects (`Money`, `IBAN`, `PhoneNumber`), contratos abstractos de repositorios compartidos | `common` |
| **security** | `packages/core/security/` | `SecureStorageService` (wrapper genérico de `flutter_secure_storage`, no conoce conceptos de negocio), biometric auth (`local_auth`), **detección local de amenazas** (root/jailbreak via `safe_device`/`flutter_jailbreak_detection`, hooks, debugger, emulator, mock GPS, tampering — sin telemetría a terceros), **attestation de integridad** ([Play Integrity API](https://developer.android.com/google/play/integrity/overview) en Android + [App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity) en iOS via [`app_device_integrity`](https://pub.dev/packages/app_device_integrity) — genera tokens firmados por Google/Apple que el backend del banco valida para verificar que la petición proviene de la app legítima en un dispositivo no comprometido), cifrado (AES/RSA helpers), gestión de sesión (timeout inactividad, token refresh), clipboard protection, `FLAG_SECURE` | `common` |
| **mock** | `packages/core/mock/` | ⚠️ **Solo compila en DEV** (`main_dev.dart`). Implementaciones mock de data sources de features y libs. Fixtures JSON. Solo happy path. Los features NO conocen mock — mock conoce los features | `common`, features (interfaces), libs (interfaces) |

### 2.3 Libs (Librerías compartidas de negocio)

Las libs encapsulan lógica de negocio reutilizable. Los features SÍ pueden depender de libs. Las libs NO dependen de features.

| Paquete | Path | Responsabilidad | Depende de | Quién lo usa |
|---------|------|-----------------|------------|--------------|
| **otp** | `packages/libs/otp/` | Verificación OTP transversal. `OtpInterceptor` (Dio): detecta cabecera `X-OTP-Required` en respuesta HTTP, pausa petición, lanza flujo OTP (pantalla de código), reintenta si verificado. Resultados: `verified`, `cancelled`, `expired` | `core/common`, `core/ui`, `core/security` | Cualquier feature: authentication (login), payments (confirmar transferencia), cards (activar/bloquear), accounts... |
| **webview** | `packages/libs/webview/` | Infraestructura WebView bancaria. `BankingWebView` (widget configurable), bridge bidireccional App ↔ Web (`AppBridge`), inyección de token, whitelist de dominios, cookie cleanup, gestión de sesión en WebView. Internamente usa `flutter_inappwebview` | `core/common`, `core/security` | accounts (detalle tx), cards (detalle tx tarjeta), promotions (WebView promo) |
| **promotions** | `packages/libs/promotions/` | Banners y contenido promocional. Widgets reutilizables (`PromoBanner`, `PromoCarousel`). Data sources propios. No es feature — se integra dentro de otros features | `libs/webview`, `core/common` | globalposition (banners en home) |

### 2.4 Features (Pantallas independientes de negocio)

Los features son módulos con Clean Architecture interna (presentation/domain/data). NUNCA dependen de otros features — solo de libs y core. Comunicación cross-feature vía go_router (paths).

| Feature | Path | Pantallas | Depende de (libs) |
|---------|------|-----------|--------------------|
| **authentication** | `packages/features/authentication/` | **Login** (`/login`): DNI + password, botón biometrics, selector de entorno (solo DEV). **Recuperar contraseña** (`/login/forgot-password`): introducir DNI para recibir enlace de reset | `libs/otp` (si backend pide OTP tras login) |
| **onboarding** | `packages/features/onboarding/` | **Onboarding** (`/onboarding`): 3 slides con explicación de la app. Ruta **protegida** (post-login, primera vez). Redirect guard: si `onboarding_seen == false` → redirige aquí antes de globalposition | — |
| **globalposition** | `packages/features/globalposition/` | **Global Position** (`/globalposition`): saludo personalizado, saldo total agregado, lista de cuentas, últimos 5 movimientos (`Future.wait`), accesos rápidos (Transferir, Pagar, Bizum, Tarjetas), banners promocionales | `libs/promotions` |
| **accounts** | `packages/features/accounts/` | **Detalle de cuenta** (`/accounts/:id`): saldo, IBAN, movimientos, filtros por fecha, scroll infinito. **Detalle de transacción** (`/accounts/:id/transactions/:txId`): WebView o nativo. Parseo en `Isolate.run()` si >500 items | `libs/webview`, `libs/otp` (si operativa lo requiere) |
| **payments** | `packages/features/payments/` | **Nueva transferencia** (`/payments/new`): cuenta origen, IBAN destino, importe, concepto. **Confirmación** (`/payments/confirm`): resumen + biometric/PIN. **Resultado** (`/payments/result`): éxito o error + retry | `libs/otp` (si backend pide OTP al confirmar) |
| **cards** | `packages/features/cards/` | **Mis tarjetas** (`/cards`): lista de tarjetas (débito/crédito), estado (activa/bloqueada). **Detalle tarjeta** (`/cards/:id`): número oculto, fecha, CVV oculto, límites, acciones (bloquear, activar, PIN). **Detalle tx tarjeta** (`/cards/:id/transactions/:txId`): WebView o nativo | `libs/webview`, `libs/otp` (si operativa lo requiere) |
| **notifications** | `packages/features/notifications/` | **Notificaciones** (`/notifications`): lista de notificaciones in-app, badge en bottom navigation, marcar como leída, navegación a pantalla relacionada (deep link interno) | — |
| **settings** | `packages/features/settings/` | **Ajustes** (`/settings`): perfil, seguridad, cambio de tema (light/dark en caliente), cambio de idioma (easy_localization en caliente), toggle de notificaciones push, toggle de biometrics. Persistencia en `flutter_secure_storage` | — |

### 2.5 Reglas de Dependencia (resumen visual)

```
mobile_app ──► features/* ──► libs/*  ──► core/*
                  │              │            │
                  │              ▼            │
                  │         core/domain       │
                  │         core/common       │
                  │         core/ui           │
                  │         core/security     │
                  │                           │
                  └───────────────────────────┘

features NUNCA dependen de otros features
features NUNCA dependen de core/mock (mock depende de features)
libs NUNCA dependen de features
libs SÍ pueden depender de otras libs y de core
core/mock es la excepción: depende de features y libs (para importar interfaces)
```

### 2.6 Tabla de Pantallas Completa

| # | Feature | Pantalla | Ruta | Auth | Notas |
|---|---------|----------|------|------|-------|
| 1 | authentication | Login | `/login` | No | DNI + password, biometrics, env selector (DEV) |
| 2 | authentication | Recuperar contraseña | `/login/forgot-password` | No | Introducir DNI |
| 3 | onboarding | Onboarding | `/onboarding` | Sí | Post-login, primera vez, 3 slides |
| 4 | globalposition | Global Position | `/globalposition` | Sí | Home principal, saldo total, cuentas, últimos movimientos, banners promo |
| 5 | accounts | Detalle de cuenta | `/accounts/:id` | Sí | Saldo, IBAN, movimientos, filtros, scroll infinito |
| 6 | accounts | Detalle de transacción | `/accounts/:id/transactions/:txId` | Sí | Puede ser WebView (`libs/webview`) |
| 7 | payments | Nueva transferencia | `/payments/new` | Sí | Formulario multi-step |
| 8 | payments | Confirmación | `/payments/confirm` | Sí | Resumen + biometric/PIN + OTP si requerido |
| 9 | payments | Resultado | `/payments/result` | Sí | Éxito o error + retry |
| 10 | cards | Mis tarjetas | `/cards` | Sí | Lista tarjetas, estado activa/bloqueada |
| 11 | cards | Detalle tarjeta | `/cards/:id` | Sí | Número oculto, reveal con biometrics, acciones |
| 12 | cards | Detalle tx tarjeta | `/cards/:id/transactions/:txId` | Sí | Puede ser WebView (`libs/webview`) |
| 13 | notifications | Notificaciones | `/notifications` | Sí | Lista in-app, badge, marcar leída |
| 14 | settings | Ajustes | `/settings` | Sí | Tema, idioma, biometrics, notificaciones |

**Total: 14 pantallas** distribuidas en **8 features** + **3 libs** + **5 módulos core** + **1 app**.

---

## 3. Mock Layer: Estándar de Emulación

### Filosofía

El mock layer NO es solo para la app base — es un **estándar del proyecto** que todo equipo usará mientras el backend desarrolla sus endpoints. Los mocks son **solo happy path** — datos de ejemplo realistas con latencia simulada. Para probar errores se usan herramientas externas (Charles, Proxyman, MockHttp). Cuando el backend esté listo, solo se cambia la implementación concreta sin tocar domain ni presentation.

### Compilación: solo en DEV

El módulo mock **solo compila en el build de desarrollo** (`main_dev.dart`). Los builds de STAGING (`main_staging.dart`) y PRODUCCIÓN (`main_prod.dart`) **nunca importan el paquete mock**, por lo que Dart tree-shaking lo excluye completamente del binario. Esto garantiza:

- **Cero código mock en PRE/PRO**: ni fixtures, ni data sources fake, ni configuración de mock
- **Cero overhead en tamaño**: el APK/IPA de producción no incluye nada del módulo mock
- **Cero riesgo**: imposible que datos de test lleguen a producción por error

### Arquitectura del Mock Layer

**Regla de dependencia**: los features NO conocen el módulo mock. Es al revés — el módulo `mock` conoce los features, importa sus interfaces (contratos abstractos de data sources) y proporciona las implementaciones mock. Así los features quedan limpios y desacoplados.

```
packages/core/
├── mock/                          # ── Módulo mock (TODO lo relacionado con mocks) ──
│   ├── pubspec.yaml               # Depende de los features para importar sus interfaces
│   ├── assets/
│   │   └── fixtures/
│   │       ├── user.json
│   │       ├── accounts.json
│   │       ├── transactions.json
│   │       ├── cards.json
│   │       ├── notifications.json
│   │       └── promotions.json
│   └── lib/
│       ├── config/
│       │   ├── mock_config.dart               # Configuración global (latencia)
│       │   └── mock_delay.dart                # Simula latencia de red
│       ├── datasources/
│       │   ├── mock_auth_datasource.dart          # Implementa RemoteAuthDataSource
│       │   ├── mock_account_datasource.dart       # Implementa RemoteAccountDataSource (incluye transacciones)
│       │   ├── mock_payment_datasource.dart       # Implementa RemotePaymentDataSource
│       │   ├── mock_card_datasource.dart          # Implementa RemoteCardDataSource (incluye transacciones de tarjeta)
│       │   ├── mock_notification_datasource.dart  # Implementa RemoteNotificationDataSource
│       │   └── mock_promotions_datasource.dart    # Implementa RemotePromotionsDataSource (banners, contenido promo)
│       └── di/
│           └── mock_providers.dart                # Riverpod overrides para entorno MOCK
│
└── ...

packages/features/accounts/lib/data/
├── datasources/
│   ├── remote_account_datasource.dart       # Contrato abstracto (interfaz)
│   └── remote_account_datasource_impl.dart  # Implementación REAL (Dio)
└── ...
```

```yaml
# packages/core/mock/pubspec.yaml
name: mock
description: Mock implementations of feature data sources

dependencies:
  flutter:
    sdk: flutter
  common:
    path: ../common
  # Importa features para conocer sus interfaces
  authentication:
    path: ../../features/authentication
  accounts:
    path: ../../features/accounts
  payments:
    path: ../../features/payments
  cards:
    path: ../../features/cards
  notifications:
    path: ../../features/notifications
  # Importa libs para conocer sus interfaces (promotions tiene data sources)
  promotions:
    path: ../../libs/promotions
```

**El feature NO sabe que existe mock:**

```
packages/features/accounts/pubspec.yaml
→ NO tiene dependencia de mock (ni directa ni transitiva)

packages/core/mock/pubspec.yaml
→ SÍ depende de accounts (para importar RemoteAccountDataSource)
```

### Mock Config

Los mocks son **solo happy path** — datos de ejemplo para que el equipo frontend avance sin backend. Para probar errores (timeouts, 401, 500) se usan herramientas externas en el entorno PRE: **Charles**, **Proxyman** o el plugin **MockHttp** de Android Studio, que permiten interceptar llamadas reales y cambiar respuestas en caliente sin tocar código.

```dart
// packages/core/mock/lib/config/mock_config.dart
class MockConfig {
  /// Latencia mínima simulada (ms)
  final int minDelayMs;

  /// Latencia máxima simulada (ms)
  final int maxDelayMs;

  const MockConfig({
    this.minDelayMs = 200,
    this.maxDelayMs = 1500,
  });

  /// Config por defecto: latencia realista para ver loading/shimmer
  static const standard = MockConfig();

  /// Config rápida: sin latencia (para tests automatizados)
  static const instant = MockConfig(minDelayMs: 0, maxDelayMs: 0);
}
```

### Mock Delay

```dart
// packages/core/mock/lib/config/mock_delay.dart
class MockDelay {
  static Future<void> simulate(MockConfig config) async {
    final random = Random();
    final delay = config.minDelayMs +
        random.nextInt(config.maxDelayMs - config.minDelayMs + 1);
    await Future.delayed(Duration(milliseconds: delay));
  }
}
```

### Ejemplo: Feature (contrato + implementación real)

```dart
// packages/features/accounts/lib/data/datasources/remote_account_datasource.dart
// Contrato abstracto — el feature solo define la interfaz
abstract class RemoteAccountDataSource {
  Future<List<AccountDto>> fetchAccounts();
  Future<AccountDto> fetchAccountDetail(String accountId);
  Future<List<TransactionDto>> fetchTransactions(String accountId, DateRange range);
  Future<TransactionDto> fetchTransactionDetail(String id);
}

// packages/features/accounts/lib/data/datasources/remote_account_datasource_impl.dart
// Implementación REAL (Dio) — vive dentro del feature
class RemoteAccountDataSourceImpl implements RemoteAccountDataSource {
  final Dio _dio;
  RemoteAccountDataSourceImpl(this._dio);

  @override
  Future<List<TransactionDto>> fetchTransactions(String accountId, DateRange range) async {
    final response = await _dio.get('/accounts/$accountId/transactions', queryParameters: {
      'from': range.from.toIso8601String(),
      'to': range.to.toIso8601String(),
    });
    return (response.data as List).map((e) => TransactionDto.fromJson(e)).toList();
  }
}
```

### Ejemplo: Mock module (implementación mock)

```dart
// packages/core/mock/lib/datasources/mock_account_datasource.dart
// Vive en el módulo mock — importa la interfaz del feature
import 'package:accounts/data/datasources/remote_account_datasource.dart';

class MockAccountDataSource implements RemoteAccountDataSource {
  final MockConfig config;
  MockAccountDataSource({this.config = MockConfig.standard});

  @override
  Future<List<TransactionDto>> fetchTransactions(String accountId, DateRange range) async {
    await MockDelay.simulate(config);

    // Cargar datos desde fixture JSON (happy path)
    final jsonString = await rootBundle.loadString(
      'packages/core/mock/assets/fixtures/transactions.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => TransactionDto.fromJson(e)).toList();
  }
}
```

### Inyección por entorno (Riverpod)

```dart
// packages/core/mock/lib/di/mock_providers.dart
// Los overrides de mock se definen aquí — solo se usan en main_dev.dart
final mockOverrides = <Override>[
  remoteAccountDataSourceProvider.overrideWith(
    (ref) => MockAccountDataSource(),
  ),
  remoteAuthDataSourceProvider.overrideWith(
    (ref) => MockAuthDataSource(),
  ),
  // ... todos los data sources mock
];
```

```dart
// packages/features/accounts/lib/di/account_providers.dart
// El provider del feature — por defecto devuelve la implementación real
@riverpod
RemoteAccountDataSource remoteAccountDataSource(Ref ref) {
  return RemoteAccountDataSourceImpl(ref.watch(dioProvider));
}
```

```dart
// apps/mobile_app/lib/main_dev.dart
// ✅ ÚNICO entry point que importa mock → mock SOLO compila aquí
import 'package:mock/di/mock_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer(
    overrides: [
      // En DEV, si el entorno es MOCK, inyectar mocks
      ...mockOverrides,
    ],
  );

  await _initServices(container);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BankingApp(showEnvironmentSelector: true),
    ),
  );
}
```

```dart
// apps/mobile_app/lib/main_staging.dart
// ⚠️ NO importa mock → mock NO compila en este build
// Apunta fijo a PRE, sin selector de entorno
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    overrides: [
      environmentNotifierProvider.overrideWith(
        () => EnvironmentNotifier()..switchTo(Environment.pre),
      ),
    ],
  );
  await _initServices(container);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BankingApp(showEnvironmentSelector: false),
    ),
  );
}
```

```dart
// apps/mobile_app/lib/main_prod.dart
// ⚠️ NO importa mock → mock NO compila en este build
// Apunta fijo a PRO, sin selector de entorno
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    overrides: [
      environmentNotifierProvider.overrideWith(
        () => EnvironmentNotifier()..switchTo(Environment.pro),
      ),
    ],
  );
  await _initServices(container);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BankingApp(showEnvironmentSelector: false),
    ),
  );
}
```

### Flujo de dependencias (solo en DEV)

```
┌─────────────────┐     ┌──────────────────────┐     ┌──────────────────┐
│   mobile_app     │────►│   packages/core/mock  │────►│ packages/features│
│  (main_dev.dart) │     │                      │     │                  │
│                  │     │ MockAccountDS (+ txs)  │     │ RemoteAccountDS  │
│ Inyecta          │     │ MockAuthDS            │     │ (interfaz)       │
│ mockOverrides    │     │ MockCardDS (+ txs)    │     │                  │
│ en container     │     │ MockPaymentDS         │     │ RemoteAccountDSI │
└─────────────────┘     └──────────────────────┘     │ (Dio, real)      │
                                                      └──────────────────┘

┌──────────────────────┐
│   mobile_app          │     ┌──────────────────┐
│  (main_staging.dart)  │────►│ packages/features│
│  (main_prod.dart)     │     │                  │
│                       │     │ RemoteAccountDSI │
│ ❌ NO importa mock   │     │ (Dio, real)      │
│ → mock no compila     │     └──────────────────┘
└──────────────────────┘

Los features NUNCA importan mock.
Mock importa las interfaces de los features.
mobile_app conecta todo via Riverpod overrides.
```

**Regla para los equipos**: todo nuevo feature DEBE tener su interfaz de data source abstracta. El equipo de mock añade la implementación mock en `packages/core/mock`. Así el equipo de frontend nunca se bloquea esperando al backend.

---

## 4. Selector de Entorno en Caliente

### Solo visible en build de desarrollo (DEV)

En `main_dev.dart`, el login incluye un selector flotante para cambiar entre MOCK, PRE y PRO **en caliente sin recompilar**. En `main_staging.dart` y `main_prod.dart` **no existe** — apuntan fijo a PRE y PRO respectivamente, y el módulo mock ni siquiera compila en esos builds.

### Flujo

```
┌──────────────────────────────────────────┐
│              Login Page (DEV)            │
│                                          │
│   ┌──────────────────────────────┐      │
│   │  DNI: __________________     │      │
│   │  Password: ______________    │      │
│   │                              │      │
│   │  [ Iniciar sesión ]          │      │
│   │  [ Acceder con biometría ]   │      │
│   └──────────────────────────────┘      │
│                                          │
│   ┌─ Environment ──────────────────┐    │
│   │  ● MOCK   ○ PRE   ○ PRO       │    │
│   │  Latencia: 200-1500ms          │    │
│   └────────────────────────────────┘    │
└──────────────────────────────────────────┘
```

### Implementación

```dart
// packages/core/common/lib/config/environment.dart
enum Environment { mock, pre, pro }

@Riverpod(keepAlive: true)
class EnvironmentNotifier extends _$EnvironmentNotifier {
  @override
  Environment build() => Environment.mock; // Default en DEV

  void switchTo(Environment env) => state = env;
}

// El cambio de entorno invalida automáticamente todos los providers
// que dependen de environmentProvider → Riverpod recrea los data sources
// con la implementación correcta (mock o real) sin reiniciar la app
```

```dart
// Solo en main_dev.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await _initServices(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BankingApp(showEnvironmentSelector: true),
    ),
  );
}

// En main_prod.dart — sin selector, siempre PRO
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    overrides: [
      environmentNotifierProvider.overrideWith(() => EnvironmentNotifier()..switchTo(Environment.pro)),
    ],
  );
  await _initServices(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BankingApp(showEnvironmentSelector: false),
    ),
  );
}
```

### Configuración por entorno

| Entorno | Build | Base URL | Mock Layer | Certificado SSL | Logging |
|---------|-------|----------|------------|-----------------|---------|
| **MOCK** | Solo DEV | — (no hay red) | Compilado y activado (fixtures locales) | No aplica | Verbose |
| **PRE** | DEV / STAGING | `https://api-pre.company.com/v1` | No compilado (STAGING) / compilado pero inactivo (DEV) | Pinning activado (cert PRE) | Verbose |
| **PRO** | DEV / PROD | `https://api.company.com/v1` | No compilado (PROD) / compilado pero inactivo (DEV) | Pinning activado (cert PRO) | Solo errores |

> **Resumen de compilación**: el código del módulo `mock` solo existe en el binario del flavor DEV. En STAGING y PROD, el import a `mock` no existe, así que Dart tree-shaking elimina todo el módulo del build final.

---

## 5. Pantallas y Flujos

### 5.1 Feature: Authentication

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Login** | `/login` | DNI/Documento de identidad + password + botón biometrics + selector de entorno (solo DEV) | No |
| **Recuperar contraseña** | `/login/forgot-password` | Introducir DNI para recibir enlace de reset | No |

> **Nota**: no hay registro en la app. En banca, el alta de cliente se realiza en oficina o por un flujo específico fuera del scope de esta app base.

> **OTP no vive aquí** — es una lib transversal (`packages/libs/otp/`). Si el backend responde con cabecera `X-OTP-Required`, la lib intercepta y lanza el flujo OTP automáticamente. Aplica en login, pagos, tarjetas o cualquier operativa que lo requiera.

**Flujo Login:**

```
Login → (DNI + password ok) → [si backend pide OTP → lib OTP] → Onboarding (primera vez) / GlobalPosition
Login → (biometrics ok) → GlobalPosition
Login → (error) → mostrar error inline, no navegación
Login → (sesión expirada + pendingRoute) → Login → [OTP si requerido] → pendingRoute destino
```

**Datos mock (happy path):**

| DNI | Password | OTP (si requerido) | Comportamiento |
|-----|----------|-----|----------------|
| `12345678A` | `Test1234!` | `123456` | Login exitoso, backend pide OTP, sesión estándar |
| `87654321B` | `Demo1234!` | — | Login exitoso, sin OTP, datos de demo con más transacciones |

Para probar errores de login (credenciales inválidas, 500, timeout), usar **Charles/Proxyman/MockHttp** en entorno PRE interceptando las llamadas reales.

---

### 5.2 Feature: Global Position

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Global Position** | `/globalposition` | Saludo, saldo total, lista de cuentas, últimos movimientos, acceso rápido a acciones, banners promocionales | Sí |

**Datos a mostrar:**
- Saludo personalizado con nombre del usuario
- Saldo total agregado de todas las cuentas
- Lista de cuentas (corriente, ahorro, inversión) con saldo individual
- Últimos 5 movimientos (cargados en paralelo con `Future.wait`)
- Accesos rápidos: Transferir, Pagar, Bizum, Tarjetas
- Banners promocionales (desde `packages/libs/promotions/`)

**Demuestra:**
- `Future.wait` para carga paralela
- BLoC con múltiples estados
- ui: cards, amounts, shimmer loading
- i18n con parámetros (`LocaleKeys.globalpositionGreeting.tr(namedArgs: {'name': 'Sergiy'})`)
- Integración de library de promotions con banners

---

### 5.3 Feature: Accounts

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Detalle de cuenta** | `/accounts/:id` | Saldo, IBAN, movimientos de la cuenta, filtros | Sí |
| **Detalle de transacción** | `/accounts/:id/transactions/:txId` | Detalle del movimiento (puede ser WebView) | Sí |

**Datos mock:** 3 cuentas (corriente ES12 3456..., ahorro ES98 7654..., inversión ES45 1122...)

**Demuestra:**
- Navegación con parámetros anidados (`:id` + `:txId`)
- WebView integration: detalle de transacción como WebView
- Filtrado de transacciones por fecha
- Scroll infinito (paginación mock)
- Parseo de JSON grande en `Isolate.run()` (>500 items)
- Deep link: `bankapp://accounts/acc-001/transactions/tx-001`

**Nota sobre WebViews**: El detalle de una transacción (tanto en accounts como en cards) se implementa como WebView usando `BankingWebView` de `packages/libs/webview/`. La home de cada feature es nativa (Dart/Flutter). La lib se encarga de sesión, token, bridge y seguridad — el feature solo configura URL y auth. Este patrón es habitual en apps bancarias donde el backend evoluciona el detalle independientemente de los cambios en la app nativa.

---

### 5.4 Feature: Payments

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Nueva transferencia** | `/payments/new` | Seleccionar cuenta origen, IBAN destino, importe, concepto | Sí |
| **Confirmación** | `/payments/confirm` | Resumen antes de confirmar | Sí |
| **Resultado** | `/payments/result` | Éxito o error de la transferencia | Sí |

**Flujo:**

```
Payments/new → (formulario válido) → Payments/confirm → (biometric/PIN) → [OTP si requerido] → Payments/result
                                                       → (cancelar) → volver a confirm
                                                       → (error) → result con error + retry
```

**Demuestra:**
- Flujo secuencial de operaciones (validar → verificar saldo → transferir)
- Autenticación biométrica para confirmar operación
- OTP transversal (lib: otp) — si el backend responde con cabecera OTP-required, la lib intercepta
- Manejo de errores con retry
- Formulario multi-step con validación

---

### 5.5 Feature: Cards

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Mis tarjetas** | `/cards` | Lista de tarjetas (débito, crédito), estado (activa, bloqueada) | Sí |
| **Detalle tarjeta** | `/cards/:id` | Número (oculto), fecha, CVV (oculto), límites, acciones (bloquear, activar, PIN) | Sí |
| **Detalle de transacción de tarjeta** | `/cards/:id/transactions/:txId` | Detalle de movimiento de tarjeta (puede ser WebView) | Sí |

**Datos mock:** 2 tarjetas (débito Visa activa, crédito Mastercard bloqueada)

**Demuestra:**
- Protección de datos sensibles (número oculto, reveal con biometrics)
- Acciones de toggle (bloquear/desbloquear tarjeta)
- ui: card visual con gradiente
- WebView integration: detalle de transacción de tarjeta como WebView

---

### 5.6 Feature: Notifications

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Notificaciones** | `/notifications` | Lista de notificaciones in-app | Sí |

**Datos mock:** 15 notificaciones variadas (transferencia recibida, pago realizado, alerta de seguridad, promoción)

**Demuestra:**
- Badge en bottom navigation
- Marcar como leída
- Navegación desde notificación a la pantalla relacionada (deep link interno)

---

### 5.7 Feature: Settings

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Ajustes** | `/settings` | Perfil, seguridad, apariencia, idioma, notificaciones, about | Sí |

**Demuestra:**
- Cambio de tema (light/dark) en caliente
- Cambio de idioma (easy_localization) en caliente
- Toggle de notificaciones push
- Toggle de biometrics
- Persistencia de preferencias en `flutter_secure_storage`

---

### 5.8 Feature: Onboarding

| Pantalla | Ruta | Descripción | Auth |
|----------|------|-------------|------|
| **Onboarding** | `/onboarding` | 3 slides con explicación de la app (primera apertura, post-login) | Sí |

**Demuestra:**
- Ruta protegida (post-login) — el onboarding en banca va después de la autenticación
- PageView con animaciones
- Persistencia de "ya visto" en `flutter_secure_storage`
- Redirect guard: tras login, si `onboarding_seen == false` → redirige a `/onboarding` antes de globalposition

---

### Lib: OTP (`packages/libs/otp/`)

La verificación OTP **no es parte de ningún feature** — es una lib transversal que cualquier feature puede necesitar. Se activa automáticamente cuando el backend responde con una cabecera específica (ej: `X-OTP-Required: true`).

**Mecanismo:**
1. Un interceptor de Dio (`OtpInterceptor`) detecta la cabecera en la respuesta HTTP
2. Pausa la petición, lanza el flujo OTP (pantalla de código)
3. El usuario introduce el código, la lib lo envía al backend
4. Si es correcto, la petición original se reintenta automáticamente
5. Si el usuario cancela o el código expira, la petición falla con un error controlado

**Dónde puede aparecer:**
- Login (tras validar credenciales)
- Payments (al confirmar transferencia)
- Cards (al activar/bloquear tarjeta)
- Cualquier operativa que el backend decida proteger con OTP

**Datos mock:** código `123456` siempre válido. La mock no requiere OTP a menos que se configure explícitamente.

---

### Lib: WebView (`packages/libs/webview/`)

La infraestructura WebView es una **lib** compartida que encapsula toda la lógica de negocio necesaria para mostrar WebViews dentro de features: gestión de sesión, inyección de token, bridge bidireccional App ↔ Web, whitelist de dominios y cleanup de cookies. Internamente usa `flutter_inappwebview`.

**Estructura:**

```
packages/libs/webview/
├── pubspec.yaml          # Depende de core/common (Dio), core/security (tokens, sesión)
└── lib/
    ├── banking_webview.dart      # Widget principal configurable
    ├── webview_event.dart        # Contrato de eventos Web ↔ App (close, navigate, sessionExpired, custom)
    ├── webview_bridge.dart       # AppBridge: JS channels bidireccionales
    ├── webview_session.dart      # Inyección de token, gestión de sesión en WebView
    ├── webview_security.dart     # Whitelist de dominios, cookie cleanup al cerrar sesión
    └── webview_config.dart       # Configuración (dominios permitidos, timeouts)
```

**Cómo lo usan los features:**

Los features importan la lib y solo configuran **qué URL abrir** y **si requiere auth**. Todo lo demás (token, bridge, seguridad) lo resuelve la lib. Desde fuera se navega a una page WebView igual que a cualquier otra page nativa — el consumidor no sabe si el destino es Dart nativo o un WebView.

```dart
// packages/features/accounts/lib/presentation/pages/transaction_detail_webview_page.dart
import 'package:webview/banking_webview.dart';

class TransactionDetailWebViewPage extends StatelessWidget {
  final String transactionId;
  const TransactionDetailWebViewPage({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BankingAppBar(title: 'Detalle de movimiento'),
      body: BankingWebView(
        url: 'https://bankapp.com/transactions/$transactionId',
        isAuthenticated: true,  // La lib inyecta token, bridge, whitelist
      ),
    );
  }
}
```

**Features que usan WebView:**
- **Accounts**: detalle de transacción (`/accounts/:id/transactions/:txId`)
- **Cards**: detalle de transacción de tarjeta (`/cards/:id/transactions/:txId`)
- **Promotions** (lib): contenido promocional en WebView

**Datos mock:** HTML mock local (`assets/mock/promo.html`) para la WebView de promotions. En entorno MOCK las WebViews autenticadas no se usan directamente — el detalle de transacción puede mostrar un placeholder o datos estáticos.

---

### Lib: Promotions (`packages/libs/promotions/`)

La lib de promotions gestiona **banners y contenido promocional** que se integra dentro de otros features (principalmente globalposition). No es un feature independiente con pantallas propias — es una lib que proporciona widgets reutilizables y datos promocionales.

**Estructura:**

```
packages/libs/promotions/
├── pubspec.yaml           # Depende de libs/webview (para promos en WebView), core/common
└── lib/
    ├── data/              # Data sources para contenido promocional (remote + mock fixture)
    ├── domain/            # Entidades y contratos de promotions (PromoBanner, PromoContent)
    └── presentation/      # Widgets reutilizables: PromoBanner, PromoCarousel
```

**Cómo lo usan los features:**

- **GlobalPosition** integra `PromoCarousel` o `PromoBanner` en su UI, mostrando banners promocionales entre las secciones nativas
- Los banners pueden enlazar a una ruta interna (ej: `/accounts/:id`) o abrir un WebView promocional usando `BankingWebView` de `libs/webview`

**Datos mock:**
- Fixture `assets/mock/promo.html` para WebView de promociones
- Los banners en mock se definen como datos estáticos dentro del mock datasource de promotions (título, imagen, URL de destino)

**Demuestra:**
- Lib compartida integrada en un feature (globalposition)
- Dependencia entre libs: promotions → webview
- Widgets reutilizables que un feature consume sin conocer la implementación interna

---

### Mapa de Navegación Completo

```
                              ┌──────────────┐
                              │    Login      │
                              │ DNI + Pass    │─────────┐
                              │ [ENV selector]│         │
                              └──────┬───────┘         │
                                     │                  │
                              [OTP si requerido]  ┌─────▼──────┐
                              (lib: otp)          │Forgot Pass │
                                     │            └────────────┘
                                     ▼
                              ┌─────────────┐
                              │  Onboarding  │ (post-login, primera vez)
                              └──────┬───────┘
                                     │
                         ┌──────────▼──────────┐
                    ┌────┤     Main Shell      ├────┐
                    │    │  (Bottom Navigation) │    │
                    │    └──────────┬──────────┘    │
                    │               │               │
         ┌──────────▼──────────┐  ┌─────▼─────┐  ┌─────▼─────┐
         │Global Position      │  │ Accounts   │  │  Cards    │
         │                     │  │            │  │           │
         │ • Cuentas           │  │ • Detalle  │  │ • Lista   │
         │ • Últimos movim.    │  │ • Txs      │  │ • Detalle │
         │ • Banners promo     │  │ • Filtros  │  │ • Bloqueo │
         │   (lib: promotions) │  │            │  │ • Txs     │
         └────────┬────────────┘  └──────┬─────┘  └─────┬─────┘
                  │                      │              │
                  │                ┌─────▼──────┐      │
                  │                │ Tx Detail  │      │
                  │                │(lib:webview)│      │
                  │                └────────────┘      │
                  │                                    │
                  │                           ┌────────▼──────┐
                  │                           │ Card Tx Detail│
                  │                           │ (lib:webview) │
                  │                           └───────────────┘
                  │
    ┌─────────────┼───────────────┐
    │             │               │
┌───▼────┐ ┌─────▼─────┐   ┌────▼────┐
│Payments│ │Notifications│  │Settings │
│• Nuevo │ │• Lista     │   │• Perfil │
│• Confirm││• Leer      │   │• Tema   │
│• Result ││            │   │• Idioma │
│[OTP si │ └────────────┘   └─────────┘
│requerido]
│(lib:otp)│
└─────────┘

Rutas públicas (sin shell):
┌──────────────┐
│Promo WebView │
│(lib:promotions)
└──────────────┘

OTP es transversal (lib):
Puede aparecer en login, payments, cards, accounts...
Activado por cabecera HTTP del backend.
```

---

## 6. Datos de Ejemplo

### Fixtures JSON (assets/mock/)

```
assets/mock/
├── user.json                # Usuario autenticado
├── accounts.json            # 3 cuentas (corriente, ahorro, inversión)
├── transactions.json        # 200+ transacciones con datos realistas (consumidas por accounts mock)
├── cards.json               # 2 tarjetas (débito Visa, crédito Mastercard)
├── notifications.json       # 15 notificaciones variadas
├── promotions.json          # 3 banners promocionales (datos para PromoBanner/PromoCarousel)
└── promo.html               # HTML local para WebView de promotions (lib)
```

### Ejemplo: user.json

```json
{
  "id": "usr-001",
  "dni": "12345678A",
  "first_name": "Sergiy",
  "last_name": "García",
  "email": "sergiy@company.com",
  "phone": "+34 612 345 678",
  "avatar_url": null,
  "created_at": "2024-03-15T10:00:00Z"
}
```

### Ejemplo: accounts.json

```json
[
  {
    "id": "acc-001",
    "type": "current",
    "name": "Cuenta Corriente",
    "iban": "ES12 3456 7890 1234 5678 9012",
    "balance": 4523.87,
    "currency": "EUR",
    "is_main": true
  },
  {
    "id": "acc-002",
    "type": "savings",
    "name": "Cuenta Ahorro",
    "iban": "ES98 7654 3210 9876 5432 1098",
    "balance": 15200.00,
    "currency": "EUR",
    "is_main": false
  },
  {
    "id": "acc-003",
    "type": "investment",
    "name": "Cartera Inversión",
    "iban": "ES45 1122 3344 5566 7788 9900",
    "balance": 32450.25,
    "currency": "EUR",
    "is_main": false
  }
]
```

### Ejemplo: transactions.json (muestra de 3)

```json
[
  {
    "id": "tx-001",
    "account_id": "acc-001",
    "amount": -45.99,
    "currency": "EUR",
    "description": "Amazon Prime",
    "category": "shopping",
    "status": "completed",
    "created_at": "2026-02-27T14:30:00Z",
    "merchant": {
      "name": "Amazon",
      "logo_url": "https://cdn.company.com/merchants/amazon.png"
    }
  },
  {
    "id": "tx-002",
    "account_id": "acc-001",
    "amount": 2500.00,
    "currency": "EUR",
    "description": "Nómina Febrero 2026",
    "category": "income",
    "status": "completed",
    "created_at": "2026-02-25T08:00:00Z",
    "merchant": null
  },
  {
    "id": "tx-003",
    "account_id": "acc-001",
    "amount": -12.50,
    "currency": "EUR",
    "description": "Café Central",
    "category": "restaurants",
    "status": "pending",
    "created_at": "2026-02-27T09:15:00Z",
    "merchant": {
      "name": "Café Central",
      "logo_url": null
    }
  }
]
```

### Ejemplo: promotions.json

```json
[
  {
    "id": "promo-001",
    "title": "Cuenta Nómina Sin Comisiones",
    "subtitle": "Domicilia tu nómina y olvídate de las comisiones",
    "image_url": "https://cdn.company.com/promos/cuenta-nomina.png",
    "action_url": "/accounts/new?type=payroll",
    "action_type": "deep_link",
    "priority": 1
  },
  {
    "id": "promo-002",
    "title": "Tarjeta Gold Gratis el Primer Año",
    "subtitle": "Solicita tu tarjeta Gold sin coste de emisión",
    "image_url": "https://cdn.company.com/promos/tarjeta-gold.png",
    "action_url": "/cards/new?type=gold",
    "action_type": "deep_link",
    "priority": 2
  },
  {
    "id": "promo-003",
    "title": "Plan Ahorro Inteligente",
    "subtitle": "Descubre cómo ahorrar automáticamente cada mes",
    "image_url": "https://cdn.company.com/promos/ahorro.png",
    "action_url": "https://bankapp.com/promo/ahorro-inteligente",
    "action_type": "webview",
    "priority": 3
  }
]
```

---

## 7. Checklist de Arquitectura Cubierta

Cada item debe estar implementado y funcionando en la app base:

### Estructura y Arquitectura

- [ ] Monorepo multi-módulo con `packages/core/`, `packages/libs/` y `packages/features/`
- [ ] Pub Workspaces con versionado centralizado en pubspec raíz
- [ ] Melos configurado con todos los scripts (analyze, test, build:runner, etc.)
- [ ] Clean Architecture en cada feature (presentation / domain / data)
- [ ] Reglas de dependencia: features→libs→core (features no dependen entre sí, sí de libs)

### State Management y DI

- [ ] BLoC en cada feature (Events sealed, States single class + status enum)
- [ ] Riverpod como DI único + estado global (sesión, tema, idioma, entorno)
- [ ] Providers por entorno (mock vs real) con switch en caliente
- [ ] `ProviderContainer` + `UncontrolledProviderScope` para inicialización temprana

### Navegación y Deep Links

- [ ] go_router con rutas por feature
- [ ] Redirect guard con gestión de sesión (pública vs protegida)
- [ ] Onboarding post-login: redirect a `/onboarding` si primera vez (ruta protegida)
- [ ] `PendingRouteNotifier` para deep links con sesión expirada
- [ ] ShellRoute con bottom navigation
- [ ] Deep links configurados en Android (intent-filter) e iOS (Info.plist)
- [ ] Tabla de rutas completa (públicas y protegidas)

### Networking y Datos

- [ ] Dio con cadena de interceptors (auth, logging, retry, cache, certificate pinning, **OTP**)
- [ ] `AuthInterceptor` con `QueuedInterceptor` y token refresh
- [ ] `OtpInterceptor` (`packages/libs/otp/`) — detecta cabecera OTP-required, lanza flujo OTP, reintenta petición
- [ ] `dio_cache_interceptor` con `MemCacheStore` (solo en memoria)
- [ ] `flutter_secure_storage` como única persistencia en disco
- [ ] Mock data sources con fixtures JSON y latencia simulada (solo happy path)
- [ ] `SecureStorageService` genérico (no conoce conceptos de negocio)

### Modelos y Code Generation

- [ ] Freezed en domain (Model, sin serialización) y en data (Dto, con `fromJson`/`toJson`)
- [ ] Mappers en clases separadas (nunca métodos dentro de Model/Dto)
- [ ] `build_runner` configurado y funcionando con Melos

### Internacionalización

- [ ] `easy_localization` con JSON por idioma (mínimo ES + EN)
- [ ] `RemoteDeltaAssetLoader` custom (base local + deltas remotos)
- [ ] `LocaleKeys` generadas automáticamente (cero strings hardcodeados)
- [ ] Cambio de idioma en caliente desde Settings

### WebViews (`packages/libs/webview/`)

- [ ] `BankingWebView` en `packages/libs/webview/` con JS channels (AppBridge)
- [ ] Comunicación bidireccional App ↔ Web (WebViewEvent, WebViewBridge)
- [ ] Gestión de sesión en WebView (inyección de token, detección de 401)
- [ ] Whitelist de dominios configurable (WebViewConfig)
- [ ] Cookie cleanup al cerrar sesión
- [ ] Features importan la lib: accounts y cards usan BankingWebView para detalle de transacción
- [ ] HTML mock local para la WebView de promociones (lib promotions)

### Seguridad

- [ ] Certificate pinning configurado (aunque apunte a mock, la estructura está)
- [ ] `flutter_secure_storage` con wrapper genérico
- [ ] Biometric auth (`local_auth`) en login y confirmación de pago
- [ ] Detección local de amenazas sin terceros (root/jailbreak, hooks, debugger, emulator, mock GPS, tampering) via `safe_device` + `flutter_jailbreak_detection`
- [ ] Attestation de integridad: [Play Integrity API](https://developer.android.com/google/play/integrity/overview) (Android) + [App Attest / DeviceCheck](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity) (iOS) via [`app_device_integrity`](https://pub.dev/packages/app_device_integrity) — token generado en cliente, validado en backend del banco
- [ ] Ofuscación configurada en los builds de release
- [ ] `FLAG_SECURE` para prevención de captura de pantalla
- [ ] Gestión de sesión con timeout de inactividad
- [ ] Clipboard protection para datos sensibles

### Concurrencia

- [ ] `Isolate.run()` para parseo de JSON grande (transacciones 200+)
- [ ] `Future.wait()` para carga paralela en globalposition
- [ ] Flujo secuencial en payments (validar → verificar → transferir → notificar)

### UI System

- [ ] Paquete `ui` con tokens (colors, typography, spacing, radii)
- [ ] Tema light + dark con `ThemeExtension` (`BankingColorExtension`)
- [ ] Atomic design: atoms (AppButton, AppInput), molecules (AmountDisplay), organisms (AppBar, BottomSheet)
- [ ] Cambio de tema en caliente desde Settings

### Testing

- [ ] Unit tests: al menos 1 UseCase + 1 Repository + 1 BLoC por feature
- [ ] Widget tests: al menos 1 por feature
- [ ] Golden tests: AccountListItem, AmountDisplay, AppButton
- [ ] BLoC tests con `bloc_test`
- [ ] Mocks con `mocktail`
- [ ] Coverage > 80% en domain y BLoC layers
- [ ] WebView integration tests en accounts y cards

### CI/CD y DevOps

- [ ] Flavors configurados: dev, staging, prod
- [ ] Entry points separados: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`
- [ ] GitHub Actions workflow para PR checks (analyze, format, test)
- [ ] `lefthook` configurado (pre-commit: format + analyze, commit-msg: conventional commits)
- [ ] `CODEOWNERS` configurado
- [ ] `very_good_analysis` como lint rules

### Developer Experience

- [ ] Selector de entorno en caliente (MOCK / PRE / PRO) en login DEV
- [ ] Datos mock realistas y variados
- [ ] Conventional commits configurados con lefthook
- [ ] Widgetbook configurado con componentes del ui system
- [ ] WebView integration dentro de features (detalle de transacción como WebView en accounts y cards)
- [ ] promotions lib integrada en globalposition feature

---

> **Siguiente paso**: Validar esta especificación y proceder a crear la estructura del proyecto y la implementación.
