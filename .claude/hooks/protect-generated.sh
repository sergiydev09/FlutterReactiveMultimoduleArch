#!/bin/bash
# PreToolUse hook: block direct edits to generated files and lock files

FILE_PATH="${CLAUDE_FILE_PATH:-}"

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Block generated files
if [[ "$FILE_PATH" == *.g.dart ]] || [[ "$FILE_PATH" == *.freezed.dart ]] || [[ "$FILE_PATH" == *.gen.dart ]]; then
  echo "BLOCKED: No editar archivos generados (*.g.dart, *.freezed.dart). Usa 'dart run build_runner build' para regenerarlos."
  exit 2
fi

# Block pubspec.lock
if [[ "$FILE_PATH" == */pubspec.lock ]]; then
  echo "BLOCKED: No editar pubspec.lock directamente. Usa 'flutter pub get' o 'melos bootstrap'."
  exit 2
fi

exit 0
