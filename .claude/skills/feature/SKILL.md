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
├── build.yaml
└── lib/
    ├── presentation/
    │   ├── <nombre>/                     # Carpeta por pantalla (misma que el feature para la pantalla principal)
    │   │   ├── <nombre>_page.dart        # Page (StatelessWidget con BlocBuilder)
    │   │   ├── <nombre>_bloc.dart        # extends Bloc<Event, State>
    │   │   ├── <nombre>_event.dart       # @freezed sealed class
    │   │   └── <nombre>_state.dart       # @freezed sealed class
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
  common:
    path: ../../core/common
  dio:
  domain:
    path: ../../core/domain
  flutter:
    sdk: flutter
  flutter_bloc:
  fpdart:
  freezed_annotation:
  ui:
    path: ../../core/ui

dev_dependencies:
  bloc_test:
  build_runner:
  flutter_test:
    sdk: flutter
  freezed:
  mocktail:
  very_good_analysis:
```

3. **build.yaml** — configurar Freezed para generar en subcarpeta `generated/`:

```yaml
targets:
  $default:
    builders:
      freezed|freezed:
        enabled: true
        options:
          build_extensions:
            '^lib/{{path}}/{{file}}.dart': 'lib/{{path}}/generated/{{file}}.freezed.dart'
```

4. **BLoC** — seguir el patrón Freezed del proyecto:
   - Usar `part` / `part of` para events y states
   - Events: `@freezed sealed class` con `_$<Name>Event` mixin
   - States: `@freezed sealed class` con `_$<Name>State` mixin, con `Initial`, `Loading`, `Loaded`, `Error`
   - `part 'generated/<name>_bloc.freezed.dart';` para el archivo generado
   - Constructor injection de use cases
   - Handlers nombrados `_on<EventName>`

5. **Repository abstracto** en `domain/repositories/` — métodos retornan `Future<Either<Failure, T>>`

6. **DataSource abstracto** en `data/datasources/` — métodos retornan `Future<Model>` y lanzan excepciones

7. **Repository impl** en `data/repositories/` — catch `DioException` → `ServerFailure`, catch genérico → `ServerFailure`

8. **Page** — `StatelessWidget` con `BlocBuilder` básico, usando `BankingColors` de `ui/tokens/colors.dart`

9. **Registrar en el proyecto**:
   - Añadir providers en `apps/mobile_app/lib/di/providers.dart` (remoteDataSource + repository)
   - Añadir ruta en `apps/mobile_app/lib/routing/app_router.dart`
   - Añadir mock datasource en `packages/core/mock/lib/datasources/`
   - Añadir override en `apps/mobile_app/lib/main_dev.dart`

10. Ejecutar `melos bootstrap` y luego `melos run build:runner` al finalizar

## Referencia

Usar `packages/features/authentication/` como ejemplo de referencia — leer sus archivos para replicar el patrón exacto.
**IMPORTANTE**: La estructura de presentation/ está organizada por pantalla, NO por tipo (no usar subcarpetas `bloc/`, `pages/`).
