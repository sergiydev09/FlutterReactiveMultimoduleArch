---
name: usecase
description: Scaffold a new UseCase extending the base UseCase class with Either return type
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep
---

# Scaffold New UseCase

Crea un UseCase siguiendo el patrón exacto del proyecto.

**Uso**: `/usecase <NombreUseCase>` (PascalCase, sin sufijo "UseCase")
- Ejemplo: `/usecase GetAccountTransactions` → genera `get_account_transactions_usecase.dart`

El nombre se recibe en: $ARGUMENTS

## Instrucciones

1. Convertir el nombre PascalCase a snake_case para el archivo
2. Crear en el directorio `domain/usecases/` del feature correspondiente
3. Preguntar al usuario por el tipo de retorno y el tipo de parámetros si no es evidente

### Plantilla

```dart
import 'package:<feature>/domain/repositories/<feature>_repository.dart';
import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for <descripción>.
class <Name>UseCase extends UseCase<ReturnType, ParamsType> {
  <Name>UseCase({required this.repository});

  final <Feature>Repository repository;

  @override
  Future<Either<Failure, ReturnType>> call(ParamsType params) {
    return repository.<method>(params);
  }
}
```

### Reglas

- Si no requiere parámetros, usar `NoParams` de `package:common/usecases/usecase.dart`
- Si requiere parámetros complejos, crear una clase `@freezed` en `domain/entities/` o junto al usecase
- El UseCase SOLO delega al repository — NO contiene lógica de negocio compleja
- Si necesita orquestar múltiples repositories, inyectar ambos por constructor

## Referencia

Usar `packages/features/authentication/lib/domain/usecases/login_usecase.dart` como modelo.
