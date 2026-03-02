# Lanzar app en Android e iOS

Lanza la app Flutter del banking en ambas plataformas (Android + iOS).

## Instrucciones

Sigue estos pasos EN ORDEN:

### 1. Detectar dispositivos corriendo

Usa `mcp__dart__list_devices` para ver qué dispositivos están corriendo actualmente.

### 2. Evaluar disponibilidad por plataforma

Clasifica los dispositivos corriendo:
- **Android**: dispositivos con `targetPlatform` que contenga `android`
- **iOS**: dispositivos con `targetPlatform` que contenga `ios`

Si **ambas plataformas** tienen al menos un dispositivo corriendo → ve al paso 5.
Si **falta alguna plataforma** (o ambas) → ve al paso 3 solo para las que falten.

### 3. Buscar emuladores/simuladores instalados (solo plataformas sin dispositivo corriendo)

Ejecuta en paralelo según lo que falte:

- **Si falta Android**: `flutter emulators` — lista AVDs instalados
- **Si falta iOS**: `xcrun simctl list devices available` — lista simuladores iOS instalados

### 4. Preguntar y arrancar emuladores faltantes

Usa `AskUserQuestion` con una pregunta por cada plataforma que falte:

- **Android** (si falta): Muestra los AVDs instalados como opciones + opción "No lanzar en Android". Si no hay AVDs instalados, informa y omite.
- **iOS** (si falta): Muestra los simuladores iPhone disponibles como opciones (preferir modelos recientes) + opción "No lanzar en iOS". Si no hay simuladores, informa y omite.

Arranca los emuladores seleccionados en paralelo:
- **Android**: `flutter emulators --launch <emulator_id>`
- **iOS**: `xcrun simctl boot <device_udid> && open -a Simulator`

Espera a que estén listos ejecutando `flutter devices` hasta que aparezcan.

### 5. Preguntar al usuario qué dispositivos usar

Si hay múltiples dispositivos corriendo por plataforma, usa `AskUserQuestion` para que elija cuál usar en cada plataforma. Si solo hay uno por plataforma, úsalo directamente.

### 6. Preguntar entrypoint

Usa `AskUserQuestion` para preguntar qué entrypoint usar:
- `lib/main_dev.dart` (Recomendado) — con mocks
- `lib/main_staging.dart` — staging
- `lib/main_prod.dart` — producción

### 7. Lanzar la app

Usa `mcp__dart__launch_app` para lanzar en cada dispositivo seleccionado (en paralelo). Parámetros:
- `root`: `/Users/sergiy/StudioProjects/FlutterReactiveMultimoduleArch/apps/mobile_app`
- `device`: el device ID del dispositivo
- `target`: el entrypoint seleccionado

### 8. Conectar al DTD

Tras un lanzamiento exitoso, usa `mcp__dart__connect_dart_tooling_daemon` con la URI DTD devuelta.

### 9. Confirmar

Informa al usuario que la app está corriendo y en qué dispositivos. Recuérdale:
- `/hot-reload` para aplicar cambios
- `/hot-restart` para reiniciar la app
- `/stop-app` para detener la app
