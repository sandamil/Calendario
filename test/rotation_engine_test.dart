import 'package:flutter_test/flutter_test.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/app/modules/crearCuadrante/services/rotation_engine.dart';

TurnoType shift(String title) => TurnoType(
  title: title,
  description: title,
  startHour: '22:00',
  endHour: '07:00',
  color: '123456',
);

void main() {
  group('RotationEngine', () {
    test('repeats a daily sequence over an inclusive date range', () {
      final rows = RotationEngine.generate(
        pattern: RotationPattern(
          name: 'Ciclo',
          steps: [
            RotationStep(shift: shift('M')),
            RotationStep(shift: shift('T')),
            RotationStep(shift: shift('N')),
            RotationStep(shift: shift('L')),
          ],
        ),
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 6),
      );
      expect(rows.map((e) => e.title).toList(), ['M', 'T', 'N', 'L', 'M', 'T']);
      expect(rows.first.dateTime, DateTime(2026, 1, 1, 6));
      expect(rows.last.dateTime, DateTime(2026, 1, 6, 6));
    });

    test('supports blocks with different lengths', () {
      final rows = RotationEngine.generate(
        pattern: RotationPattern(
          name: '2-2-3',
          steps: [
            RotationStep(shift: shift('M'), days: 2),
            RotationStep(shift: shift('N'), days: 2),
            RotationStep(shift: shift('L'), days: 3),
          ],
        ),
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 7),
      );
      expect(rows.map((e) => e.title).toList(), [
        'M',
        'M',
        'N',
        'N',
        'L',
        'L',
        'L',
      ]);
    });

    test('applies a positive and normalized cycle offset', () {
      final rows = RotationEngine.generate(
        pattern: RotationPattern(
          name: 'Ciclo',
          offsetDays: 5,
          steps: [
            RotationStep(shift: shift('M')),
            RotationStep(shift: shift('T')),
            RotationStep(shift: shift('N')),
          ],
        ),
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 2),
      );
      expect(rows.map((e) => e.title).toList(), ['N', 'M']);
    });

    test('supports leap-day and month/year boundaries', () {
      final rows = RotationEngine.generate(
        pattern: RotationPattern(
          name: 'Ciclo',
          steps: [RotationStep(shift: shift('M'))],
        ),
        start: DateTime(2024, 2, 28),
        end: DateTime(2024, 3, 1),
      );
      expect(rows.map((e) => e.dateTime!.day).toList(), [28, 29, 1]);
    });

    test('rejects invalid dates, empty cycles and excessive ranges', () {
      expect(
        () => RotationEngine.generate(
          pattern: RotationPattern(
            name: 'X',
            steps: [RotationStep(shift: shift('M'))],
          ),
          start: DateTime(2026, 2, 2),
          end: DateTime(2026, 2, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => RotationEngine.generate(
          pattern: RotationPattern(name: 'X', steps: const []),
          start: DateTime(2026),
          end: DateTime(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => RotationEngine.generate(
          pattern: RotationPattern(
            name: 'X',
            steps: [RotationStep(shift: shift('M'))],
          ),
          start: DateTime(2020),
          end: DateTime(2031),
        ),
        throwsRangeError,
      );
    });

    test('rejects invalid block sizes', () {
      expect(
        () => RotationEngine.generate(
          pattern: RotationPattern(
            name: 'X',
            steps: [RotationStep(shift: shift('M'), days: 32)],
          ),
          start: DateTime(2026),
          end: DateTime(2026),
        ),
        throwsRangeError,
      );
    });
  });
}
