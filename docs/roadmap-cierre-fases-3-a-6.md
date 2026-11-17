# Roadmap de cierre — Calendario 3.0

## Alcance y reglas
- Workspace único: `~/Desktop/Calendario-riverpod`.
- No commit, push, merge, release, publicación ni instalación en dispositivos sin orden expresa.
- Mantener compatibilidad con las dos bases SQLite actuales y con el backup JSON v1 mientras no exista una migración probada.
- Todo cálculo de turnos debe tratar turnos nocturnos y límites de fecha correctamente.
- No afirmar sincronización remota funcional hasta probar autenticación, reglas del backend, conflictos y dos dispositivos reales.
- Cada fase termina con pruebas, análisis estático y build Android/Web; documentar cualquier bloqueo iOS.

## Fase 3 — Motor avanzado de cuadrantes
- Motor puro de rotaciones por pasos/bloques, duración variable por turno, desplazamiento de ciclo, límites y generación determinista.
- Previsualización y validación antes de guardar.
- Mantener la edición de cuadrantes ya guardados, incluida inferencia del patrón cuando sea inequívoco.
- Pruebas de ciclos, bloques, desfases, rangos inclusivos, años bisiestos y límites.

## Fase 4 — Estadísticas, horas y salario
- Un único cálculo de duración para turnos diurnos/nocturnos; excluir libres y registros inválidos.
- Informes por mes/año/rango: horas, turnos, días libres, fines de semana, noches y distribución.
- Preferencias locales para tarifa/hora y complementos configurables; mostrar siempre estimación bruta orientativa, nunca nómina legal.
- Exportación PDF/CSV y desglose auditable; preferencias persistentes sin cambiar esquema SQLite.

## Fase 5 — Sincronización y funciones inteligentes
- Estado local de sincronización, revisión de backups, exportación/importación, detección de divergencias y resolución explícita.
- Autenticación Firebase por correo/contraseña, grupos de hasta 10 miembros, códigos de invitación con hash, rotación de código y salida/eliminación de grupo.
- Merge de tres vías con baseline local y resolución explícita de conflictos; las notas personales quedan excluidas.
- Sincronización manual desde la pantalla; sin ejecución automática en segundo plano.
- Firebase Auth/Firestore y reglas seguras están implementados en el cliente y archivos de configuración; falta habilitar Email/Password, crear Firestore, validar reglas con Emulator Suite y desplegarlas desde una CLI autenticada. No usar reglas abiertas.
- No habilitar sync remoto si no se puede verificar autorización, aislamiento por usuario, cifrado/transporte y comportamiento offline.

## Fase 6 — Acabado comercial y preparación para publicación
- Auditoría de accesibilidad, tamaños, navegación, estados vacíos/errores/carga, orientación y pantallas pequeñas.
- Política de privacidad revisada en el archivo y pantalla de la app; incluye Firebase, publicidad, borrado de cuenta y datos locales. Identidad legal y consentimiento EEE siguen pendientes.
- Revisar iconos, nombre, versión, enlaces legales, metadatos y build release reproducible.
- Pruebas Android y Web; iOS según compatibilidad real de Xcode.
- Lista final de bloqueos de publicación; no publicar ni firmar producción.

## Criterio de cierre
No marcar fase como completa por tener pantallas: requiere comportamiento probado, regresiones, análisis y builds. El usuario hará después la prueba visual/funcional en el móvil y aportará incidencias.
