# Calendario — diseño de recuperación accesible

## Intención

Permitir que Calendario muestre diagnóstico y restaure un backup JSON v1 aunque el arranque normal falle antes de `runApp` o una base SQLite no pueda abrirse. La recuperación no dependerá de Riverpod ni de los providers normales.

## Estado actual

`main()` espera `recoverPendingRestore()` antes de `runApp`. Después espera en paralelo la inicialización de los dos servicios de notificaciones y `initMemory()` (SharedPreferences y GetStorage). Un error en cualquier Future impide que Flutter monte una interfaz. La recuperación v1 actual abre ambas bases y guarda su journal dentro de la base de calendario; no puede recuperar una base que no abra o que no pase `integrity_check`.

## Objetivos y límites

- Montar una interfaz Flutter mínima inmediatamente después de `WidgetsFlutterBinding.ensureInitialized()`.
- Mantener la interfaz de rescate independiente de providers, router, notificaciones, ads, SharedPreferences y GetStorage.
- Diagnosticar archivos existentes en modo de solo lectura y presentar error comprensible más detalle técnico.
- Seleccionar, validar y previsualizar un backup v1; exigir confirmación explícita antes de sustituir archivos.
- Construir calendario y notas en bases temporales, validar ambas y preparar una operación durable externa a las dos bases normales.
- Reproducir esa operación antes de abrir repositorios normales; mantener el manifiesto y las bases temporales hasta verificar ambas bases finales.
- Ofrecer conservar/exportar los bytes actuales cuando se puedan leer de forma segura. La exportación nunca sustituirá un archivo externo elegido previamente.
- Mantener IDs, fechas, campos de recordatorio, payloads, esquema y formato JSON v1.

Fuera de alcance: sincronización, backend, publicar, modificar servicios de notificaciones o garantizar recuperación si falla el propio motor de almacenamiento/plataforma.

## Enfoques considerados

1. **Capturar el error y reutilizar el restore actual.** Es el menor cambio, pero no puede restaurar si una SQLite no abre o si su integridad falla; incumple el objetivo central.
2. **UI temprana y sustitución de dos bases preparadas con manifiesto externo.** Construye las dos bases en rutas temporales, las valida, conserva opcionalmente las bases actuales y guarda un manifiesto durable fuera de SQLite. Antes del arranque normal, copia ambas bases temporales a sus rutas estables, verifica ambas y solo entonces elimina el manifiesto. Permite repetir tras cierre abrupto y aplica a archivos nativos y VFS Web. **Recomendado.**
3. **Un solo database-control adicional para el manifiesto.** Evita una implementación de manifiesto por plataforma, pero sigue dependiendo de SQLite y no ofrece más seguridad que un manifiesto pequeño fuera de las bases que se están reparando.

## Decisiones provisionales

- El arranque ejecutará un `BootstrapRoot` Flutter con estados cargando, aplicación normal y rescate. El primer árbol no creará `ProviderScope` ni inicializará servicios de producto.
- El manifiesto se escribirá como JSON atómico en almacenamiento de archivos Android/iOS y en `localStorage` para Web. La abstracción será inyectable para pruebas. Si no se puede persistir el manifiesto, no se reemplazará ninguna base.
- Se reutilizará `DatabaseFactory.readDatabaseBytes/writeDatabaseBytes` para conservar y sustituir archivos. Las bases temporales se construirán con los esquemas vigentes y el backup v1, sin migrar ni escribir las bases estables durante la prevalidación.
- La operación quedará bloqueada hasta confirmar el resumen de filas. Cancelar el selector, cerrar el diálogo o fallar al leer no modifica bases ni manifiesto.
- La copia de los dos archivos estables no es una transacción física común. El manifiesto externo mantiene bloqueado el arranque normal y vuelve a aplicar ambas copias hasta que las dos pasen las comprobaciones; por ello la exposición de un estado mixto queda evitada dentro de la app.
- La inspección de daño binario puede no abrir el motor SQLite; se mostrarán por separado existencia/lectura de bytes e integridad SQL. Nunca se declarará íntegra una base solo porque sus bytes se puedan leer.
- Si el entorno de Web no puede arrancar el worker/WASM o acceder a IndexedDB, se mantendrá la UI, se ofrecerá guardar el backup seleccionado fuera de la app y se explicará que la reparación local requiere volver a disponer del almacenamiento Web.

## Plataforma y límites de prueba

- Android/iOS: usar la factory sqflite y rutas proporcionadas por `path_provider`; no usar `dart:io` desde código compartido Web.
- Web/PWA: usar `sqflite_common_ffi_web` (VFS persistida en IndexedDB) y `localStorage` para el manifiesto; probar en un navegador real, no inferir ejecución solo del build.
- iOS: ejecutar compilación sin firma y pruebas disponibles en el entorno. La ausencia de simulador/dispositivo se informará como limitación, no como prueba pasada.
- FilePicker solo se invocará desde la pantalla al seleccionar/guardar archivos, nunca durante el arranque inicial.

## Riesgos que debe resolver la implementación

- Errores de inicialización de Flutter binding ocurren antes de que pueda montarse cualquier pantalla y quedan fuera del rescate.
- Manifiesto, nombres de staging y checksums deben validarse antes de copiar; archivos ausentes o manipulados mantienen el modo rescate.
- El fallo después de copiar solo una base debe dejar manifiesto y ambas bases temporales intactos para repetir.
- Un fallo de `integrity_check` de cualquiera de las bases finales debe conservar el manifiesto y no iniciar providers.
- La limpieza de temporales solo sucede después de verificar ambas bases y persistir que la recuperación concluyó.
- Deben comprobarse el primer arranque sin archivos, la migración normal de archivos antiguos y la cancelación sin efectos.
