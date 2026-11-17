# Plan de prueba en móvil — Calendario

Usar primero datos de prueba. No probar restauraciones con la única copia de datos reales.

## Preparación
- Abrir en Android Studio: `~/Desktop/Calendario-riverpod`.
- Ejecutar en el móvil Android de prueba con Run ▶.
- APK debug generado: `build/app/outputs/flutter-apk/app-debug.apk`.
- La instalación no se ha hecho desde este entorno.

## Fase 3 — Rotaciones
1. Crear o elegir cuatro tipos: Mañana, Tarde, Noche y Libre.
2. Crear un cuadrante de prueba con secuencia M → T → N → L.
3. Poner 2 días por bloque y comprobar que el ciclo indica 8 días.
4. Mover el desfase de inicio y comprobar que cambia la vista previa.
5. Guardar 30 días y comprobar la secuencia en Mes, Semana y Agenda.
6. Editar el cuadrante y verificar que se recuperan los bloques de dos días.
7. Probar un ciclo diario existente para comprobar que no cambia.

## Fase 4 — Informes y salario
1. Abrir Informes y elegir un mes con turnos.
2. Configurar tarifa base 12 €/h, plus nocturno 3 €/h y plus fin de semana 2 €/h.
3. Comprobar un turno 22:00–07:00: 9 horas totales y 8 nocturnas.
4. Comprobar un viernes 22:00–sábado 06:00: 8 horas totales y 6 de fin de semana.
5. Verificar que Libre no suma horas y que un horario inválido queda excluido.
6. Exportar PDF y CSV; abrir ambos desde la hoja de compartir.
7. Cambiar de mes y confirmar que el informe filtra el periodo.

## Fase 5 — Sincronización (solo después de activar Firebase)
1. Activar Email/Password, crear Firestore y desplegar reglas según `docs/firebase-sync-setup.md`.
2. Crear cuenta de prueba en el móvil A y compartir un cuadrante de prueba.
3. Unirse desde móvil B con una cuenta distinta y el código.
4. Añadir un turno en A y sincronizar B; luego modificarlo en B y sincronizar A.
5. Editar el mismo día en ambos antes de sincronizar; confirmar que aparece la elección de conflicto.
6. Desconectar Internet e intentar sincronizar; debe rechazar la operación sin borrar datos.
7. Comprobar que las notas personales no se comparten.
8. Probar salir del grupo, regenerar invitación y eliminar cuenta.

## Fase 6 — Acabado
- Revisar menú, navegación atrás, textos, tamaños, modo oscuro y pantallas pequeñas.
- Abrir Política de privacidad y comprobar que no hay desbordamientos.
- Verificar exportaciones, mensajes de error y estados vacíos.
- No publicar ni compartir la build de depuración como versión de producción.

## Recuperación y persistencia
- Crear una copia de seguridad antes de probar.
- Reiniciar la app y confirmar que cuadrantes, notas y preferencias persisten.
- No forzar corrupción ni interrumpir una restauración con datos reales; esas pruebas ya tienen cobertura automatizada.
