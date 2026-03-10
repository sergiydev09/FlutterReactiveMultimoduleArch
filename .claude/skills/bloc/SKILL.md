---
name: bloc
description: Scaffold a new BLoC with sealed events and single-class state following the project pattern
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep
---

# Scaffold New BLoC

Crea un BLoC completo con events y states siguiendo el patrón exacto del proyecto.

**Uso**: `/bloc <NombreBLoC>` (PascalCase, sin sufijo "Bloc")
- Ejemplo: `/bloc AccountDetail` → genera `account_detail_bloc.dart`, `account_detail_event.dart`, `account_detail_state.dart`

El nombre se recibe en: $ARGUMENTS

## Instrucciones

1. Convertir el nombre PascalCase a snake_case para los archivos
2. Crear 3 archivos en el directorio `presentation/<screen_name>/` de la pantalla correspondiente (donde `<screen_name>` es el snake_case del nombre)

### <name>_bloc.dart
```dart
import 'package:<feature>/domain/usecases/<usecase>.dart';
import 'package:common/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '<name>_event.dart';
part '<name>_state.dart';
part 'generated/<name>_bloc.freezed.dart';

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
    //   (failure) => emit(state.copyWith(
    //     status: <Name>Status.error,
    //     errorMessage: failure.message,
    //   )),
    //   (data) => emit(state.copyWith(
    //     status: <Name>Status.loaded,
    //     data: data,
    //   )),
    // );
  }
}
```

### <name>_event.dart
```dart
part of '<name>_bloc.dart';

@freezed
sealed class <Name>Event with _$<Name>Event {
  const factory <Name>Event.loadRequested() = <Name>LoadRequested;
}
```

### <name>_state.dart
```dart
part of '<name>_bloc.dart';

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

## Post-creación

Ejecutar `melos run build:runner` para generar los archivos `.freezed.dart` en `generated/`.

## Referencia

Usar los BLoCs existentes dentro de carpetas `presentation/<screen>/` como modelo exacto.
**IMPORTANTE**: Los archivos BLoC viven junto a la page dentro de `presentation/<screen_name>/`, NO en una subcarpeta `bloc/` separada.
