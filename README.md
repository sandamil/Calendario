# Calendario (Flutter, Riverpod)

Aplicación de calendario y gestión de turnos/cuadrantes para uso personal y compartido, desarrollada en **Flutter**. La rama activa de este repositorio es **`migracion-riverpod`** (versión 3.x).

> Nota: el nombre del paquete en `pubspec.yaml` es `calendario2` por motivos históricos, pero el proyecto corresponde a la evolución actual basada en Riverpod.

## Funcionalidades principales

- Calendario y vistas de agenda para consultar días, turnos y notas.
- Gestión de **turnos** y **cuadrantes** (creación/edición y asignación).
- Notas asociadas al calendario y utilidades de productividad (p. ej. apertura de ubicaciones en Google Maps cuando aplica).
- **Recuperación y copias de seguridad** locales (manifest/almacenamiento de recuperación y pruebas de integración asociadas).
- **Sincronización compartida opcional** con Firebase/Supabase (autenticación por correo, grupos con código de invitación, sincronización manual de turnos del cuadrante seleccionado y resolución de conflictos). Las notas/preferencias personales no se suben.
- PWA/web con soporte de inicialización específica (p. ej. `sqflite_common_ffi_web`).
- Notificaciones locales y servicios auxiliares (anuncios, temas/ajustes, onboarding/ayuda).

## Stack técnico

- **Flutter** (SDK `>=3.13.0 <4.0.0`) / Dart 3
- **Estado y navegación:** `flutter_riverpod`, `go_router`
- **Persistencia local:** `sqflite` (+ FFI web), `shared_preferences`, `get_storage`, `path_provider`
- **Backend/sync:** `firebase_core`, `firebase_messaging`, `supabase_flutter`, Cloud Firestore (reglas/índices en el repo)
- **UI/utilidades:** `table_calendar`, `flutter_screenutil`, `google_fonts`, `flutter_local_notifications`, `intl`, `file_picker`, `share_plus`, `pdf`, etc.

## Requisitos

- Flutter/Dart compatibles con `environment.sdk` de `pubspec.yaml`.
- Para Android/iOS: toolchains habituales de Flutter (`Xcode` en macOS para iOS).
- Para funciones de sync: proyecto Firebase configurado y credenciales/ajustes correspondientes (ver `docs/firebase-sync-setup.md`).

## Puesta en marcha

```bash
cd calendario
flutter pub get
```

Ejecutar en desarrollo:

```bash
flutter run            # dispositivo/plataforma por defecto
flutter run -d chrome  # web
```

## Comandos habituales

```bash
flutter analyze
flutter test
flutter test integration_test
dart format .
```

Builds:

```bash
flutter build apk
flutter build ios      # requiere entorno macOS/Xcode configurado
flutter build web --release --base-href /Calendario/
```

> La PWA se publica en GitHub Pages desde la rama `migracion-riverpod` (workflow `.github/workflows/deploy-pwa.yml`) con `--base-href /Calendario/` y copia `app-ads.txt` a `build/web/`.

## Estructura del proyecto (resumen)

- `lib/main.dart`, `lib/app/bootstrap/`: arranque e inicialización.
- `lib/app/modules/`: funcionalidades por módulo (home/calendario, cuadrantes, turnos, ajustes, notas, recuperación, ayuda, sync, etc.).
- `lib/app/data/`: modelos y acceso a datos local/remoto.
- `lib/app/routes/` y uso de `go_router`: navegación.
- `lib/app/controllers/`, `lib/app/services/` (según módulo): lógica y servicios.
- `assets/`: recursos (iconos, imágenes, datos).
- `test/`, `integration_test/`: pruebas (incluye recuperación/almacenamiento).
- `docs/`: planes, specs, progreso y guías (sync Firebase, roadmap/fases, pruebas).
- `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `.firebaserc`: configuración de Firestore/Firebase.

## Configuración de sincronización (Firebase/Supabase)

La app funciona en **modo local** si la inicialización remota no está disponible. Para habilitar sync compartido revisa y sigue `docs/firebase-sync-setup.md` (activar Email/Password, crear Firestore, desplegar reglas con Firebase CLI autenticada, y validar con datos de prueba). No despliegues reglas ni cambies backend sin autorización explícita.

## Notas importantes

- Existen copias/archivos de respaldo históricos en el árbol (p. ej. `.backup_integracion_*`, `*.bak_*`); evita modificarlos salvo necesidad explícita.
- Revisa `analysis_options.yaml` y los lints antes de cambios amplios; el proyecto usa `flutter_lints`.
- Mantén secretos y credenciales fuera del control de versiones.
