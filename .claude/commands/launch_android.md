# Lanzar app en Android

Lanza la app Flutter del banking en un emulador/dispositivo Android.

## Instrucciones

Sigue estos pasos EN ORDEN:

### 1. Detectar dispositivos Android corriendo

Usa `mcp__dart__list_devices` para ver qué dispositivos están corriendo. Filtra solo los que tengan `targetPlatform` con `android`.

### 2. Evaluar disponibilidad

Si hay al menos un dispositivo Android corriendo → ve al paso 5.
Si no hay ninguno → ve al paso 3.

### 3. Buscar emuladores Android instalados

Ejecuta `flutter emulators` con Bash para listar los AVDs instalados.

### 4. Preguntar y arrancar emulador

Si hay AVDs instalados, usa `AskUserQuestion` para que el usuario elija cuál arrancar. Si solo hay uno, pregunta si quiere arrancarlo.

Si no hay AVDs instalados, informa al usuario que no tiene emuladores Android configurados y sugiere crear uno con Android Studio.

Arranca el emulador seleccionado:
```
flutter emulators --launch <emulator_id>
```

Espera a que esté listo ejecutando `flutter devices` hasta que aparezca el dispositivo Android.

### 5. Seleccionar dispositivo

Si hay múltiples dispositivos Android corriendo, usa `AskUserQuestion` para que elija cuál usar. Si solo hay uno, úsalo directamente.

### 6. Preguntar entrypoint

Usa `AskUserQuestion` para preguntar qué entrypoint usar:
- `lib/main_dev.dart` (Recomendado) — con mocks
- `lib/main_staging.dart` — staging
- `lib/main_prod.dart` — producción

### 7. Lanzar la app

Usa `mcp__dart__launch_app` con:
- `root`: `/Users/sergiy/StudioProjects/FlutterReactiveMultimoduleArch/apps/mobile_app`
- `device`: el device ID del dispositivo Android
- `target`: el entrypoint seleccionado

### 8. Conectar al DTD

Tras un lanzamiento exitoso, usa `mcp__dart__connect_dart_tooling_daemon` con la URI DTD devuelta.

### 9. Confirmar

Informa al usuario que la app está corriendo en Android. Recuérdale:
- `/hot-reload` para aplicar cambios
- `/hot-restart` para reiniciar la app
- `/stop-app` para detener la app
