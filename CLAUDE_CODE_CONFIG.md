# Configuración de Claude Code — Flutter Banking App

Este documento describe toda la configuración de Claude Code en este proyecto y los comandos para verificar que funciona correctamente.

---

## Estructura de configuración

```
FlutterReactiveMultimoduleArch/
├── CLAUDE.md                          # Instrucciones principales (cargado automáticamente)
├── .mcp.json                          # MCP servers del proyecto
├── .claude/
│   ├── settings.json                  # Permisos, deny list, hooks
│   ├── skills/
│   │   ├── feature/SKILL.md           # /feature — scaffold feature completa
│   │   ├── bloc/SKILL.md              # /bloc — scaffold BLoC + events + states
│   │   ├── usecase/SKILL.md           # /usecase — scaffold UseCase
│   │   └── conventions/SKILL.md       # Auto-aplicada por Claude al escribir código
│   ├── agents/
│   │   ├── architecture-reviewer.md   # Revisor de arquitectura Clean
│   │   └── security-reviewer.md       # Revisor de seguridad bancaria
│   └── hooks/
│       ├── format-dart.sh             # PostToolUse: auto-format archivos .dart
│       └── protect-generated.sh       # PreToolUse: bloquea edición de *.g.dart, *.freezed.dart, pubspec.lock
```

---

## Comandos de verificación

Ejecutar estos comandos en una nueva sesión de Claude Code para verificar que todo está configurado correctamente.

### 1. Verificar MCP Servers

```
/mcp
```

Debe mostrar:
- **dart-mcp-server** — herramientas de Dart/Flutter (analyze, hot reload, widget tree, etc.)
- **context7** — documentación actualizada de librerías

### 2. Verificar Skills disponibles

```
/skills
```

Debe mostrar:
- **feature** — Scaffold a new Clean Architecture feature package
- **bloc** — Scaffold a new BLoC with sealed events and states
- **usecase** — Scaffold a new UseCase

> `conventions` NO aparece porque es `user-invocable: false` (Claude la aplica automáticamente)

### 3. Verificar Agents disponibles

Los agents se invocan automáticamente por Claude cuando es relevante, o puedes pedirlos explícitamente:
- "Revisa la arquitectura del feature accounts" → usa `architecture-reviewer`
- "Revisa la seguridad del módulo authentication" → usa `security-reviewer`

### 4. Verificar Hooks

Editar cualquier archivo `.dart` — debe auto-formatearse después de guardar.

Intentar editar un archivo `*.g.dart` o `pubspec.lock` — debe ser bloqueado con mensaje de error.

### 5. Verificar Permisos

Los siguientes comandos deben ejecutarse sin pedir confirmación:
```bash
dart format .
flutter pub get
melos analyze
melos test
dart run build_runner build --delete-conflicting-outputs
```

Los siguientes comandos deben estar BLOQUEADOS:
```bash
rm -rf <cualquier cosa>          # Borrado recursivo
git push --force                  # Force push
firebase deploy                   # Deploy (debe ser manual)
```

### 6. Verificar CLAUDE.md

Al iniciar una nueva sesión, Claude debe conocer:
- La arquitectura del proyecto (preguntarle "¿Qué arquitectura usa este proyecto?")
- Las reglas de dependencia (preguntarle "¿Puede un feature importar otro feature?")
- Los patrones obligatorios (preguntarle "¿Cómo se manejan errores en los repositories?")

---

## Skills — Uso rápido

### `/feature <nombre>`
Crea un paquete feature completo con Clean Architecture:
```
/feature pagos_programados
```
Genera: pubspec.yaml, BLoC, events, states, page, repository, datasource, model.
Registra providers en DI y rutas en router.

### `/bloc <NombrePascalCase>`
Crea un BLoC con events y states sealed:
```
/bloc AccountDetail
```
Genera: `account_detail_bloc.dart`, `account_detail_event.dart`, `account_detail_state.dart`

### `/usecase <NombrePascalCase>`
Crea un UseCase con Either:
```
/usecase GetAccountTransactions
```
Genera: `get_account_transactions_usecase.dart` extendiendo `UseCase<Type, Params>`

---

## MCP Servers — Herramientas disponibles

### dart-mcp-server (22 herramientas)

| Herramienta | Descripción |
|-------------|-------------|
| `analyze_files` | Analizar archivos Dart (errores, warnings) |
| `dart_format` | Formatear código Dart |
| `dart_fix` | Aplicar quick fixes automáticos |
| `hot_reload` | Hot reload de la app en ejecución |
| `hot_restart` | Hot restart de la app |
| `launch_app` | Lanzar la app en un dispositivo |
| `stop_app` | Detener la app |
| `list_devices` | Listar dispositivos disponibles |
| `list_running_apps` | Listar apps en ejecución |
| `get_widget_tree` | Inspeccionar el widget tree |
| `get_runtime_errors` | Ver errores en tiempo de ejecución |
| `get_app_logs` | Ver logs de la app |
| `run_tests` | Ejecutar tests |
| `pub` | Operaciones de pub (get, add, remove) |
| `pub_dev_search` | Buscar paquetes en pub.dev |
| `hover` | Hover info (tipo, documentación) |
| `signature_help` | Info de firma de funciones |
| `create_project` | Crear nuevo proyecto Flutter |
| `flutter_driver` | Tests de integración |
| `get_active_location` | Ubicación activa en el editor |
| `get_selected_widget` | Widget seleccionado en el inspector |
| `connect_dart_tooling_daemon` | Conectar al daemon de herramientas |

### context7 (2 herramientas)

| Herramienta | Descripción |
|-------------|-------------|
| `resolve-library-id` | Resolver ID de una librería (flutter_bloc, riverpod, etc.) |
| `get-library-docs` | Obtener documentación actualizada de una librería |

---

## Agents — Cuándo se usan

### architecture-reviewer
Se invoca cuando pides revisar arquitectura o cuando Claude detecta posibles violaciones de dependencias.

**Busca**: imports entre features, BLoC patterns incorrectos, Either no usado en repositories, lógica de negocio en widgets.

### security-reviewer
Se invoca cuando pides revisar seguridad o cuando se trabaja en código sensible (auth, payments, storage).

**Busca**: secretos expuestos, PII en logs, almacenamiento inseguro, HTTP sin TLS, falta de certificate pinning.

---

## Hooks — Automatización

| Hook | Evento | Matcher | Qué hace |
|------|--------|---------|----------|
| `format-dart.sh` | PostToolUse | `Write\|Edit` | Auto-format de archivos `.dart` (ignora generados) |
| `protect-generated.sh` | PreToolUse | `Write\|Edit` | Bloquea edición de `*.g.dart`, `*.freezed.dart`, `pubspec.lock` |

---

## Permisos configurados

### Permitidos (allow)
- Dart/Flutter CLI (format, analyze, build_runner, pub, run, test, clean)
- Melos scripts (analyze, test, build:runner, clean, format:check, bootstrap)
- Git (push, remote, gh CLI)
- dart-mcp-server (22 herramientas)
- context7 (resolve-library-id, get-library-docs)
- github MCP (get_file_contents, search_code, get_issue)
- WebFetch (pub.dev, dart.dev, api.flutter.dev, stackoverflow.com, github.com)

### Bloqueados (deny)
- `rm -rf` — prevenir borrados recursivos accidentales
- `git push --force` / `git push -f` — nunca force push
- `firebase deploy` — deploy manual en app bancaria
