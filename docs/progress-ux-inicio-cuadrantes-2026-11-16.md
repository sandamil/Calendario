# Ajustes UX — inicio y creación de cuadrantes

Fecha: 2026-11-16
Workspace: `~/Desktop/Calendario-riverpod`

## Inicio
- Selector de vista único en la barra superior; cada pulsación alterna Mes → Semana → Agenda → Mes.
- Eliminados los tres selectores independientes del cuerpo.
- Título del mes sin año en el año actual; incluye año para cualquier otro año. El título conserva truncado con puntos suspensivos dentro del espacio flexible de la barra.
- Los días de meses adyacentes vuelven a mostrarse con opacidad muy reducida.
- En meses que requieren seis filas, la altura de fila baja de 88 a 78 unidades relativas.
- Se mantienen las flechas anterior/siguiente y la selección de fecha.

## Creación de cuadrantes
- Eliminadas las dos tarjetas duplicadas «Motor de rotación», el selector de días por bloque y el desfase.
- La secuencia ahora se define día a día: cada elemento añadido representa exactamente un día y, al acabar la lista, el ciclo vuelve al primero.
- La vista previa muestra el patrón que se repetirá y los primeros días generados.
- Al editar, se reconstruye el ciclo periódico más corto de los días guardados (por ejemplo, una secuencia de 4 días no se convierte en 365); si las fechas no son consecutivas, se conserva la secuencia registrada.
- Se conserva el motor de generación cíclica y su límite de 366 días por ciclo.

## Validación
- `flutter test test/rotation_engine_test.dart test/home`: correcto.
- `flutter analyze --no-pub` sobre los seis archivos Dart modificados: sin incidencias.
- `git diff --check`: correcto.
- Build Web release recompilado tras los últimos cambios; salida `build/web/main.dart.js` verificada.
- No se ha hecho commit, push, despliegue ni instalación en dispositivo.
