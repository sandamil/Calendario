import '../../../data/model/cuadranteDay.dart';
import '../../../data/model/turnoType.dart';

/// One contiguous block in a repeating shift rotation.
class RotationStep {
  const RotationStep({required this.shift, this.days = 1});

  final TurnoType shift;
  final int days;
}

/// A cyclic rotation made of one or more blocks.
class RotationPattern {
  RotationPattern({
    required this.name,
    required this.steps,
    this.offsetDays = 0,
  });

  final String name;
  final List<RotationStep> steps;
  final int offsetDays;

  int get cycleLength => steps.fold<int>(0, (sum, step) => sum + step.days);

  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'El nombre no puede estar vacío.',
      );
    }
    if (steps.isEmpty) {
      throw ArgumentError('La rotación necesita al menos un turno.');
    }
    for (final step in steps) {
      if (step.days < 1 || step.days > 31) {
        throw RangeError.range(step.days, 1, 31, 'days');
      }
      if ((step.shift.title ?? '').trim().isEmpty) {
        throw ArgumentError('Todos los bloques deben tener un turno válido.');
      }
    }
    if (cycleLength > 366) {
      throw RangeError('El ciclo no puede superar 366 días.');
    }
  }
}

/// Pure deterministic generator. It never writes to SQLite.
class RotationEngine {
  static const int maxGeneratedDays = 3660;

  static List<CuadranteDay> generate({
    required RotationPattern pattern,
    required DateTime start,
    required DateTime end,
    String? calendarName,
  }) {
    pattern.validate();
    final first = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    if (last.isBefore(first)) {
      throw ArgumentError('La fecha final es anterior a la inicial.');
    }

    final count = last.difference(first).inDays + 1;
    if (count > maxGeneratedDays) {
      throw RangeError('El rango supera el máximo de $maxGeneratedDays días.');
    }

    final cycle = <RotationStep>[];
    for (final step in pattern.steps) {
      for (var i = 0; i < step.days; i++) {
        cycle.add(step);
      }
    }
    final offset =
        ((pattern.offsetDays % cycle.length) + cycle.length) % cycle.length;

    return List<CuadranteDay>.generate(count, (index) {
      final shift = cycle[(index + offset) % cycle.length].shift;
      return CuadranteDay(
        cuadranteName: calendarName ?? pattern.name,
        title: shift.title,
        description: shift.description,
        startHour: shift.startHour,
        endHour: shift.endHour,
        color: shift.color,
        dateTime: first.add(Duration(days: index, hours: 6)),
      );
    }, growable: false);
  }
}
