#!/bin/bash
# PostToolUse hook: auto-format Dart files after Write/Edit
# Only formats .dart files, skips generated files

FILE_PATH="${CLAUDE_FILE_PATH:-}"

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" != *.dart ]]; then
  exit 0
fi

# Skip generated files
if [[ "$FILE_PATH" == *.g.dart ]] || [[ "$FILE_PATH" == *.freezed.dart ]] || [[ "$FILE_PATH" == *.gen.dart ]]; then
  exit 0
fi

if [[ -f "$FILE_PATH" ]]; then
  dart format "$FILE_PATH" 2>/dev/null
fi
