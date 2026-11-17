# Progreso de implementación — fases 3 a 6

Fecha: 2026-11-16
Workspace: `~/Desktop/Calendario-riverpod`
Rama local: `migracion-riverpod`; HEAD base `8b26b40`. No commit, push, merge ni publicación.

## Fase 3 — Motor avanzado de cuadrantes
Estado: implementada en código.
- Motor puro de rotación por bloques de 1–31 días, ciclos de hasta 366 días, desfase, rangos inclusivos y límite de 10 años.
- Previsualización de los primeros días, duración del ciclo y control de desfase en la pantalla de creación.
- Inferencia de bloques uniformes al editar rotaciones existentes cuando el patrón es inequívoco; en patrones irregulares se conserva la secuencia diaria.
- Validación de límites antes de permitir guardar.
- Pruebas unitarias del motor y límites.

## Fase 4 — Estadísticas, horas y salario
Estado: implementada en código.
- Cálculo central de duración con turnos nocturnos, medianoche, fines de semana y validación de horarios.
- Informes por mes/año/rango con horas totales, noches, fines de semana, turnos, libres y distribución.
- Preferencias locales de tarifa base y plus nocturno/fin de semana.
- Estimación bruta orientativa, no nómina; se excluyen registros inválidos.
- Exportación PDF y CSV/Excel mediante compartir.
- Pruebas unitarias de cálculos y persistencia de tarifas.

## Fase 5 — Sincronización y funciones inteligentes
Estado: cliente y reglas implementados; backend pendiente de activación.
- Firebase Core se inicializa de forma opcional: un fallo cloud no bloquea el modo local.
- Registro/inicio de sesión por email y contraseña, restablecimiento de contraseña y eliminación de cuenta.
- Crear grupo, invitar con código aleatorio de 12 caracteres, regenerar código, unirse, salir y eliminar grupo. Límite de 10 miembros.
- Sincroniza únicamente los turnos del cuadrante elegido; no sincroniza notas ni preferencias.
- Merge de tres vías con baseline local; detecta ediciones concurrentes y exige elección explícita. No pisa conflictos silenciosamente.
- Protecciones ante pérdida de conexión, cuadrante local vacío/renombrado y borrado remoto accidental.
- Reglas Firestore y configuración CLI creadas en raíz.
- Sincronización manual desde la pantalla; no hay ejecución automática en segundo plano.
- No se ha desplegado Firestore ni probado dos dispositivos reales: falta activar Email/Password, crear Firestore y publicar `firestore.rules` desde una Firebase CLI autenticada. Instrucciones en `docs/firebase-sync-setup.md`.
- Reglas revisadas en código, pero no validadas con Emulator Suite ni desplegadas. No se han abierto permisos públicos.

## Fase 6 — Acabado y preparación
Estado: código de producto mejorado; preparación de publicación aún abierta.
- Acceso a sincronización desde el menú.
- Exportación PDF/CSV integrada en informes.
- Política de privacidad revisada tanto en archivo como en pantalla; describe almacenamiento local, Firebase, publicidad y borrado de cuenta.
- Eliminación de cuenta desde la app.
- Prueba de pantalla de sincronización en modo local si Firebase no está disponible.
- Lista de prueba móvil en `docs/PRUEBA-MOVIL-FASES-3-A-6.md`.
- Identidad legal del responsable y consentimiento publicitario EEE pendientes antes de publicación.
- iOS mantiene el bloqueo conocido de Xcode 14.3 con Flutter 3.47.7.

## Verificación final
- Suite completa: **130 pruebas pasaron, 1 prueba Web quedó omitida** por guard de plataforma; exit code 0.
- Pruebas adicionales focalizadas de rotación, estadísticas, merge y pantalla de sync: pasaron.
- Analyzer: sin errores ni warnings; permanecen diagnósticos informativos de estilo.
- Android debug: build correcto, `build/app/outputs/flutter-apk/app-debug.apk` (aprox. 200 MB).
- Web release JS: build correcto en `build/web`. Advertencias existentes deprecación del service worker/FlutterLoader.
- Wasm: no validado; el proyecto conserva la limitación conocida de dependencias Web no compatibles con Wasm.
- Android Gradle Plugin 8.11.1 y Gradle 8.14.3 generan aviso de futura retirada de soporte; build actual correcto.
- iOS no compilado por incompatibilidad conocida Xcode 14.3 / Flutter 3.47.7.
- Android APK no instalado en móvil desde este entorno. La prueba visual/funcional física queda para la siguiente sesión.
- `git diff --check`: limpio.
- Sin commit, push, merge, deploy, publicación ni instalación en dispositivo.

## Bloqueos externos para cierre de publicación
1. Activar Email/Password, crear Firestore y desplegar reglas; luego validar sync real entre dos móviles, conflicto, desconexión, borrado y reentrada.
2. Resolver compatibilidad iOS con una versión de Xcode soportada.
3. Completar identidad legal del responsable y consentimiento AdMob/EEE.
4. Ejecutar la prueba visual/funcional en el móvil de test y corregir incidencias.
