# Contribuir a Calendario

Gracias por contribuir. Este documento describe cómo trabajar de forma segura y coherente con el funcionamiento real del proyecto.

## Ramas y flujo

- Rama de desarrollo/publicación actual: **`migracion-riverpod`**.
- Crea ramas descriptivas desde `migracion-riverpod` para cambios no triviales.
- Haz commits pequeños y con mensajes claros. No hagas force-push a ramas compartidas sin coordinación.
- Antes de abrir PR o fusionar, asegúrate de que el cambio compila y pasa las comprobaciones relevantes.

## Entorno

- Instala una versión de Flutter/Dart compatible con `pubspec.yaml` (`sdk: '>=3.13.0 <4.0.0'`).
- Ejecuta `flutter pub get` tras cambiar dependencias.
- Para iOS se requiere macOS con Xcode configurado.

## Desarrollo y validación

Comandos recomendados:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter test integration_test   # cuando aplique (p. ej. recuperación/storage)
```

Builds de verificación según el área tocada:

```bash
flutter build apk      # Android
flutter build ios      # iOS (macOS/Xcode)
flutter build web --release --base-href /Calendario/
```

- Ejecuta al menos `flutter analyze` y los tests relacionados con tu cambio.
- Si modificas lógica de recuperación, sincronización, base de datos local o UI crítica, añade o actualiza tests cuando sea viable.

## Convenciones

- Respeta la estructura existente (`lib/app/modules`, `lib/app/data`, `bootstrap`, rutas con `go_router`, estado con Riverpod).
- Sigue el estilo y lints del proyecto (`analysis_options.yaml`, `flutter_lints`); usa `dart format`.
- Evita refactors masivos no relacionados con el objetivo del cambio.
- No edites archivos de respaldo/históricos (`*.bak_*`, `.backup_integracion_*`, artefactos en `build/`, `.dart_tool/`) salvo que el cambio lo requiera explícitamente.

## Configuración, datos y secretos

- **No** subas secretos, claves privadas, tokens ni credenciales (Firebase/Supabase, etc.).
- Los cambios de backend (reglas de Firestore, índices, configuración remota) deben documentarse y **no** desplegarse sin autorización explícita. Consulta `docs/firebase-sync-setup.md`.
- La app debe seguir funcionando en modo local cuando la sync remota no esté disponible.

## Documentación

- Actualiza `README.md` y la documentación en `docs/` si cambias flujos, comandos, estructura o requisitos.
- Si un comportamiento es orientativo/limitado (p. ej. sync manual, conflictos), descríbelo con precisión.

## Pull requests

- Describe el problema, la solución y cómo validaste el cambio.
- Indica plataformas afectadas (Android/iOS/web) y pasos de prueba manual si procede.
- Adjunta capturas para cambios visuales relevantes.
