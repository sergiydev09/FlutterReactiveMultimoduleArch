---
name: page
description: Scaffold a new page (screen) inside an existing feature, with its BLoC, event, state, and page files
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Scaffold New Page (Screen)

Añade una nueva pantalla a un feature existente, creando su carpeta con page + BLoC completo.

**Uso**: `/page <NombrePantalla>` (PascalCase)
- Ejemplo: `/page AccountDetail` → genera `presentation/account_detail/` con page, bloc, event, state

El nombre se recibe en: $ARGUMENTS

## Instrucciones

1. **Detectar el feature**: Buscar en qué feature se trabaja actualmente (mirar archivos abiertos o preguntar al usuario)

2. **Convertir nombre** PascalCase → snake_case para carpeta y archivos

3. **Crear la carpeta** `presentation/<screen_name>/` dentro del feature con estos archivos:

```
presentation/<screen_name>/
├── <screen_name>_page.dart
├── <screen_name>_bloc.dart
├── <screen_name>_event.dart
└── <screen_name>_state.dart
```

### <screen_name>_bloc.dart
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '<screen_name>_event.dart';
part '<screen_name>_state.dart';
part 'generated/<screen_name>_bloc.freezed.dart';

class <Name>Bloc extends Bloc<<Name>Event, <Name>State> {
  <Name>Bloc({
    // required use cases via constructor injection
  }) : super(const <Name>State()) {
    on<<Name>LoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    <Name>LoadRequested event,
    Emitter<<Name>State> emit,
  ) async {
    emit(state.copyWith(status: <Name>Status.loading));
    // TODO: call use case and handle Either result
    // result.match(
    //   (failure) => emit(state.copyWith(status: <Name>Status.error, errorMessage: failure.message)),
    //   (data) => emit(state.copyWith(status: <Name>Status.loaded, ...)),
    // );
  }
}
```

### <screen_name>_event.dart
```dart
part of '<screen_name>_bloc.dart';

@freezed
sealed class <Name>Event with _$<Name>Event {
  const factory <Name>Event.loadRequested() = <Name>LoadRequested;
}
```

### <screen_name>_state.dart
```dart
part of '<screen_name>_bloc.dart';

enum <Name>Status { initial, loading, loaded, error }

@freezed
abstract class <Name>State with _$<Name>State {
  const factory <Name>State({
    @Default(<Name>Status.initial) <Name>Status status,
    // TODO: add data fields with @Default values
    @Default('') String errorMessage,
  }) = _<Name>State;
}
```

### <screen_name>_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';

import '<screen_name>_bloc.dart';

class <Name>Page extends StatelessWidget {
  const <Name>Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('<Nombre visible>'),
      ),
      body: BlocBuilder<<Name>Bloc, <Name>State>(
        builder: (context, state) {
          return switch (state.status) {
            <Name>Status.initial => const SizedBox.shrink(),
            <Name>Status.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            <Name>Status.error => Center(
                child: Text(
                  state.errorMessage,
                  style: TextStyle(color: BankingColors.error),
                ),
              ),
            <Name>Status.loaded => const SizedBox.shrink(),
            // TODO: build loaded UI
          };
        },
      ),
    );
  }
}
```

4. **Registrar la ruta** en `apps/mobile_app/lib/routing/app_router.dart`:
   - Añadir `GoRoute` con el path correspondiente
   - Crear `BlocProvider` en el `builder` de la ruta (NUNCA en la page)

5. **Ejecutar** `melos run build:runner` para generar los archivos `.freezed.dart` en `generated/`

6. **Informar al usuario** qué archivos se crearon y qué falta por completar (use cases, providers, etc.)

## Reglas

- Page, BLoC, event y state conviven en la MISMA carpeta — NO crear subcarpetas `bloc/` o `pages/`
- Si la pantalla necesita widgets propios, crear `presentation/<screen_name>/widgets/`
- Si necesita widgets compartidos con otras pantallas del feature, usar `presentation/widgets/`
- Revisar si ya existe un BLoC que podría reutilizarse antes de crear uno nuevo

## Referencia

Usar las pantallas existentes en el proyecto como modelo. Leer archivos del feature actual para mantener coherencia en imports y estilo.
