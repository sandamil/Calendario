import 'package:flutter_test/flutter_test.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/modules/home/utils/shift_time_utils.dart';

CuadranteDay shift({
  required int id,
  required DateTime date,
  required String start,
  required String end,
  String title = 'T',
  String description = 'Trabajo',
}) => CuadranteDay(
  id: id,
  cuadranteName: 'Turnos sueltos',
  title: title,
  description: description,
  startHour: start,
  endHour: end,
  dateTime: DateTime(date.year, date.month, date.day),
  color: '#607D8B',
);

void main() {
  group('ShiftTimeUtils', () {
    test('calcula correctamente un turno nocturno que cruza medianoche', () {
      expect(ShiftTimeUtils.durationMinutes('22:00', '06:00'), 480);
    });

    test('calcula turnos normales y rechaza horas inválidas', () {
      expect(ShiftTimeUtils.durationMinutes('07:30', '15:00'), 450);
      expect(ShiftTimeUtils.durationMinutes('25:00', '06:00'), isNull);
      expect(ShiftTimeUtils.durationMinutes('07:00', 'xx:00'), isNull);
    });

    test('detecta solapamiento de dos turnos que empiezan el mismo día', () {
      final day = DateTime(2026, 11, 15);
      final conflicts = ShiftTimeUtils.findOverlaps([
        shift(id: 1, date: day, start: '22:00', end: '06:00'),
        shift(id: 2, date: day, start: '23:00', end: '02:00'),
      ]);
      expect(conflicts, hasLength(1));
      expect(conflicts.single.first.id, 1);
      expect(conflicts.single.second.id, 2);
    });

    test(
      'detecta un turno nocturno del día anterior contra el siguiente día',
      () {
        final day = DateTime(2026, 11, 15);
        final conflicts = ShiftTimeUtils.findOverlaps([
          shift(
            id: 1,
            date: day.subtract(const Duration(days: 1)),
            start: '22:00',
            end: '06:00',
          ),
          shift(id: 2, date: day, start: '05:00', end: '08:00'),
        ]);
        expect(conflicts, hasLength(1));
      },
    );

    test('no considera solapados intervalos contiguos', () {
      final day = DateTime(2026, 11, 15);
      final conflicts = ShiftTimeUtils.findOverlaps([
        shift(id: 1, date: day, start: '07:00', end: '15:00'),
        shift(id: 2, date: day, start: '15:00', end: '22:00'),
      ]);
      expect(conflicts, isEmpty);
    });

    test('ignora turnos libres de día completo al detectar conflictos', () {
      final day = DateTime(2026, 11, 15);
      final conflicts = ShiftTimeUtils.findOverlaps([
        shift(
          id: 1,
          date: day,
          start: '00:00',
          end: '23:59',
          title: 'L',
          description: 'Libre',
        ),
        shift(id: 2, date: day, start: '08:00', end: '16:00'),
      ]);
      expect(conflicts, isEmpty);
    });
  });
}
