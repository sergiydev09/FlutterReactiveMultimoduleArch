# Lanzar app en iOS

Lanza la app Flutter del banking en un simulador/dispositivo iOS.

## Instrucciones

Sigue estos pasos EN ORDEN:

### 1. Detectar dispositivos iOS corriendo

Usa `mcp__dart__list_devices` para ver qué dispositivos están corriendo. Filtra solo los que tengan `targetPlatform` con `ios`.

### 2. Evaluar disponibilidad

Si hay al menos un dispositivo iOS corriendo → ve al paso 5.
Si no hay ninguno → ve al paso 3.

### 3. Buscar simuladores iOS instalados

Ejecuta `xcrun simctl list devices available` con Bash para listar los simuladores iOS disponibles.

### 4. Preguntar y arrancar simulador

Si hay simuladores disponibles, usa `AskUserQuestion` para que el usuario elija cuál arrancar. Preferir modelos iPhone recientes en las opciones.

Si no hay simuladores disponibles, informa al usuario que no tiene simuladores iOS configurados y sugiere instalar runtimes desde Xcode.

Arranca el simulador seleccionado:
```
xcrun simctl boot <device_udid> && open -a Simulator
```

Espera a que esté listo ejecutando `flutter devices` hasta que aparezca el dispositivo iOS.

### 5. Seleccionar dispositivo

Si hay múltiples dispositivos iOS corriendo, usa `AskUserQuestion` para que elija cuál usar. Si solo hay uno, úsalo directamente.

### 6. Preguntar entrypoint

Usa `AskUserQuestion` para preguntar qué entrypoint usar:
- `lib/main_dev.dart` (Recomendado) — con mocks
- `lib/main_staging.dart` — staging
- `lib/main_prod.dart` — producción

### 7. Lanzar la app

Usa `mcp__dart__launch_app` con:
- `root`: `/Users/sergiy/StudioProjects/FlutterReactiveMultimoduleArch/apps/mobile_app`
- `device`: el device ID del dispositivo iOS
- `target`: el entrypoint seleccionado

### 8. Conectar al DTD

Tras un lanzamiento exitoso, usa `mcp__dart__connect_dart_tooling_daemon` con la URI DTD devuelta.

### 9. Confirmar

Informa al usuario que la app está corriendo en iOS. Recuérdale:
- `/hot-reload` para aplicar cambios
- `/hot-restart` para reiniciar la app
- `/stop-app` para detener la app
