---
name: feature
description: Scaffold a new Clean Architecture feature package for the Flutter banking app
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Scaffold New Feature

Crea un paquete feature completo siguiendo la arquitectura Clean del proyecto.

**Uso**: `/feature <nombre_feature>`
- Ejemplo: `/feature pagos_programados`

El nombre se recibe en: $ARGUMENTS

## Instrucciones

1. **Crear el paquete** en `packages/features/<nombre>/` con esta estructura exacta:

```
packages/features/<nombre>/
├── pubspec.yaml
└── lib/
    ├── presentation/
    │   ├── <nombre>/                     # Carpeta por pantalla (misma que el feature para la pantalla principal)
    │   │   ├── <nombre>_page.dart        # Page (StatelessWidget con BlocBuilder)
    │   │   ├── <nombre>_bloc.dart        # extends Bloc<Event, State>
    │   │   ├── <nombre>_event.dart       # sealed class + final class per event
    │   │   └── <nombre>_state.dart       # sealed class + final class per state
    │   └── widgets/                      # Widgets compartidos entre pantallas del feature
    │       └── .gitkeep
    ├── domain/
    │   ├── entities/
    │   │   └── .gitkeep
    │   ├── repositories/
    │   │   └── <nombre>_repository.dart
    │   └── usecases/
    │       └── .gitkeep
    └── data/
        ├── datasources/
        │   └── remote_<nombre>_datasource.dart
        ├── models/
        │   └── .gitkeep
        └── repositories/
            └── <nombre>_repository_impl.dart
```

2. **pubspec.yaml** — seguir este patrón exacto (sin versiones, resolution workspace):

```yaml
name: <nombre>
description: <Nombre> feature
publish_to: 'none'

environment:
  sdk: ^3.11.0

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc:
  fpdart:
  equatable:
  dio:
  common:
    path: ../../core/common
  ui:
    path: ../../core/ui
  domain:
    path: ../../core/domain

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis:
  bloc_test:
  mocktail:
```

3. **BLoC** — seguir el patrón exacto de `packages/features/authentication/lib/presentation/login/auth_bloc.dart` (o la pantalla principal del feature de referencia):
   - Usar `part` / `part of` para events y states
   - Events: `sealed class` que extiende `Equatable`
   - States: `sealed class` que extiende `Equatable` con `Initial`, `Loading`, `Loaded`, `Error`
   - Constructor injection de use cases
   - Handlers nombrados `_on<EventName>`

4. **Repository abstracto** en `domain/repositories/` — métodos retornan `Future<Either<Failure, T>>`

5. **DataSource abstracto** en `data/datasources/` — métodos retornan `Future<Model>` y lanzan excepciones

6. **Repository impl** en `data/repositories/` — catch `DioException` → `ServerFailure`, catch genérico → `ServerFailure`

7. **Page** — `StatelessWidget` con `BlocBuilder` básico, usando `BankingColors` de `ui/tokens/colors.dart`

8. **Registrar en el proyecto**:
   - Añadir providers en `apps/mobile_app/lib/di/providers.dart` (remoteDataSource + repository)
   - Añadir ruta en `apps/mobile_app/lib/routing/app_router.dart`
   - Añadir mock datasource en `packages/core/mock/lib/datasources/`
   - Añadir override en `apps/mobile_app/lib/main_dev.dart`

9. Ejecutar `melos bootstrap` al finalizar

## Referencia

Usar `packages/features/authentication/` como ejemplo de referencia — leer sus archivos para replicar el patrón exacto.
**IMPORTANTE**: La estructura de presentation/ está organizada por pantalla, NO por tipo (no usar subcarpetas `bloc/`, `pages/`).
