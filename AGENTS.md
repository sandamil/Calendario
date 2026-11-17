# Instrucciones para agentes (Calendario)

Guía para agentes de código (p. ej. OpenCode) que trabajen en este repositorio. Prioriza cambios fieles al comportamiento actual y mínimos.

## Contexto del proyecto

- App Flutter de calendario/turnos/cuadrantes (**v3.x**, rama activa `migracion-riverpod`, paquete `calendario2`).
- **Estado/navegación:** Riverpod (`flutter_riverpod`) y `go_router`.
- **Datos:** local con `sqflite` (+ FFI web), `shared_preferences`, `get_storage`; sync compartida opcional vía Firebase/Supabase (manual, con resolución de conflictos). Notas/preferencias personales no se sincronizan.
- **PWA:** build web con `--base-href /Calendario/` y despliegue a GitHub Pages (`.github/workflows/deploy-pwa.yml`).

## Comandos clave

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter test integration_test
flutter run -d chrome
flutter build web --release --base-href /Calendario/
```

SDK: `>=3.13.0 <4.0.0` (ver `pubspec.yaml`).

## Estructura relevante

- `lib/main.dart`, `lib/app/bootstrap/` — arranque/inicialización.
- `lib/app/modules/` — módulos funcionales (home/calendario, crearCuadrante, crearTurno, ajustes, notas, recovery, sync, ayuda, etc.).
- `lib/app/data/` — modelos y acceso a datos.
- `lib/app/routes/` — enrutado.
- `docs/` — specs/planes/progreso y configuración (p. ej. `docs/firebase-sync-setup.md`).
- `test/`, `integration_test/` — pruebas.

## Convenciones y límites

- Mantén compatibilidad con el modo local si falla Firebase/Supabase.
- No despliegues reglas/configuración remota ni modifiques backends sin instrucción explícita.
- No introduzcas ni expongas secretos/credenciales; respeta `firestore.rules` y la configuración existente.
- Evita tocar `build/`, `.dart_tool/`, `.backup_integracion_*` y archivos `*.bak_*` salvo petición explícita.
- Respeta `analysis_options.yaml` y formatea con `dart format`.
- Al cambiar flujos o comandos, actualiza `README.md`/`CONTRIBUTING.md` y docs afectadas.

## Validación

- Ejecuta `flutter analyze` y los tests pertinentes al área modificada antes de dar por terminado un cambio.
- Para cambios de UI/PWA o sync, describe cómo verificar manualmente cuando no haya cobertura automática suficiente.
