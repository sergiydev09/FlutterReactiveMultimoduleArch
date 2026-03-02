---
name: conventions
description: Project architecture conventions and patterns. Apply automatically when writing, reviewing, or modifying Dart/Flutter code in this banking app project.
user-invocable: false
---

# Convenciones del Proyecto — Banking App Flutter

Claude DEBE aplicar estas reglas automáticamente al escribir o modificar código en este proyecto.

## Arquitectura

- Cada feature es un paquete Dart independiente en `packages/features/`
- Cada feature sigue Clean Architecture: `presentation/` → `domain/` → `data/`
- **Presentation organizada por pantalla**: `presentation/<screen_name>/` contiene page + bloc + event + state juntos
- Widgets propios de una pantalla van en `presentation/<screen_name>/widgets/`
- Widgets compartidos entre varias pantallas del feature van en `presentation/widgets/`
- Las features NUNCA importan otras features
- Comunicación entre features SOLO vía go_router (`context.go()`, `context.push()`)

## BLoC

- Events y States son `sealed class` que extienden `Equatable`
- Usar `part` / `part of` para separar events y states en archivos propios
- Inyección de dependencias SOLO por constructor
- Handlers nombrados `_on<EventName>`
- SIEMPRE emitir al menos un estado en cada handler

## Either Pattern

- Repositories retornan `Future<Either<Failure, T>>` — NUNCA lanzan excepciones
- En BLoC handlers usar `result.match()` para manejar Left/Right
- Failure types: `ServerFailure`, `CacheFailure`, `AuthFailure`, `NetworkFailure`

## Riverpod

- Usar `Notifier` (NO `StateProvider`) para estado global mutable
- Providers definidos en `apps/mobile_app/lib/di/providers.dart`
- DataSources como `Provider` con `throw UnimplementedError('Must be overridden')`

## Nombrado

- Archivos: snake_case (`auth_bloc.dart`)
- Clases: PascalCase (`AuthBloc`)
- BLoC: `<Feature>Bloc`, Events: `<Acción>Requested`, States: `<Feature><Estado>`
- UseCase: `<Acción>UseCase`
- Repository abstracto: `<Feature>Repository`, implementación: `<Feature>RepositoryImpl`

## Prohibiciones

- NO importar features desde otros features
- NO crear BlocProvider dentro de páginas (se hace en app_router.dart)
- NO lanzar excepciones en repositories
- NO usar `dynamic`
- NO editar archivos generados (*.g.dart, *.freezed.dart)
- NO importar core/mock fuera de main_dev.dart
- NO usar StateProvider de Riverpod
- NO hardcodear tokens o secretos

## UI

- Usar componentes de `packages/core/ui/` (BankingColors, BankingTypography, atoms, molecules)
- Textos en español para la UI
- Material 3 compliant
