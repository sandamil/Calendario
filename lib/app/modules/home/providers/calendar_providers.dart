import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';

int _turnosDayHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<CuadranteDay> getTurnosOfDayFromMap(
  DateTime day,
  Map<DateTime, List<CuadranteDay>> mapa,
) {
  final events = LinkedHashMap<DateTime, List<CuadranteDay>>(
    equals: isSameDay,
    hashCode: _turnosDayHashCode,
  )..addAll(mapa);

  return events[day] ?? <CuadranteDay>[];
}

class FocusedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime month) => state = month;
  void setFocusedDay(DateTime day) => state = day;
}

final focusedMonthProvider = NotifierProvider<FocusedMonthNotifier, DateTime>(
  FocusedMonthNotifier.new,
);

class SelectedDayNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setSelectedDay(DateTime? day) => state = day;
  void clear() => state = null;
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime?>(
  SelectedDayNotifier.new,
);

class CuadranteMapNotifier extends Notifier<Map<DateTime, List<CuadranteDay>>> {
  @override
  Map<DateTime, List<CuadranteDay>> build() => <DateTime, List<CuadranteDay>>{};

  Map<DateTime, List<CuadranteDay>> _agrupar(List<CuadranteDay> turnos) {
    final nuevoMapa = <DateTime, List<CuadranteDay>>{};
    for (final turno in turnos) {
      final fecha = turno.dateTime!;
      nuevoMapa.putIfAbsent(fecha, () => <CuadranteDay>[]);
      nuevoMapa[fecha]!.add(turno);
    }
    return nuevoMapa;
  }

  void setMap(Map<DateTime, List<CuadranteDay>> mapa) {
    state = mapa.map(
      (fecha, turnos) => MapEntry(fecha, List<CuadranteDay>.of(turnos)),
    );
  }

  Future<void> reload() async {
    final turnos = await CalendarioDB.db.getCuadranteList();
    state = _agrupar(turnos);
  }
}

final cuadranteMapProvider =
    NotifierProvider<CuadranteMapNotifier, Map<DateTime, List<CuadranteDay>>>(
  CuadranteMapNotifier.new,
);

class NotasNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => <Task>[];

  Future<void> reload() async {
    state = await NotasDB.instance.getNotesFromDB();
  }

  List<Task> getNotasOfDay(DateTime day) {
    return state.where((nota) {
      final timestamp = nota.startTimeMilliseconds;
      if (timestamp == null) return false;
      final fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return fecha.year == day.year &&
          fecha.month == day.month &&
          fecha.day == day.day;
    }).toList();
  }

  bool hasEvent(DateTime day) => getNotasOfDay(day).isNotEmpty;
}

final notasProvider = NotifierProvider<NotasNotifier, List<Task>>(
  NotasNotifier.new,
);

class SelectedDayTurnosNotifier extends Notifier<List<CuadranteDay>> {
  @override
  List<CuadranteDay> build() => <CuadranteDay>[];

  void setTurnos(List<CuadranteDay> turnos) {
    state = List<CuadranteDay>.of(turnos);
  }

  void clear() => state = <CuadranteDay>[];
}

final selectedDayTurnosProvider =
    NotifierProvider<SelectedDayTurnosNotifier, List<CuadranteDay>>(
  SelectedDayTurnosNotifier.new,
);

class TurnoTypesNotifier extends AsyncNotifier<List<TurnoType>> {
  @override
  Future<List<TurnoType>> build() async {
    return CalendarioDB.db.getTypeModels();
  }

  Future<void> addTurno(TurnoType turno) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = await CalendarioDB.db.addTypeModel(turno);
      if (id < 0) {
        throw StateError(
          'La base de datos ha rechazado la inserción del tipo de turno.',
        );
      }

      final turnos = await CalendarioDB.db.getTypeModels();
      if (!turnos.any((item) => item.id == id)) {
        throw StateError(
          'No se ha podido confirmar la inserción del tipo de turno.',
        );
      }
      return turnos;
    });
  }

  Future<void> deleteById(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await CalendarioDB.db.deleteTypeId(id);
      final turnos = await CalendarioDB.db.getTypeModels();
      if (turnos.any((item) => item.id == id)) {
        throw StateError(
          'No se ha podido confirmar la eliminación del tipo de turno.',
        );
      }
      return turnos;
    });
  }

  Future<void> updateTurno(TurnoType turno) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = turno.id;
      if (id == null) {
        throw ArgumentError(
          'No se puede editar un tipo de turno sin identificador.',
        );
      }

      final anterior = await CalendarioDB.db.fetchTurnoType(id);
      if (anterior == null) {
        throw StateError(
          'El tipo de turno que se intenta editar ya no existe.',
        );
      }

      await CalendarioDB.db.updateTurno(turno);
      final actualizado = await CalendarioDB.db.fetchTurnoType(id);

      if (actualizado == null ||
          actualizado.title != turno.title ||
          actualizado.description != turno.description ||
          actualizado.startHour != turno.startHour ||
          actualizado.endHour != turno.endHour ||
          actualizado.color != turno.color ||
          actualizado.reminderEnabled != turno.reminderEnabled ||
          actualizado.reminderMinutesBefore != turno.reminderMinutesBefore ||
          actualizado.reminderMode != turno.reminderMode) {
        throw StateError(
          'No se ha podido confirmar la actualización del tipo de turno.',
        );
      }

      return CalendarioDB.db.getTypeModels();
    });
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => CalendarioDB.db.getTypeModels(),
    );
  }
}

final turnoTypesProvider =
    AsyncNotifierProvider<TurnoTypesNotifier, List<TurnoType>>(
  TurnoTypesNotifier.new,
);

final cuadranteNamesProvider = FutureProvider<List<String>>((ref) async {
  final cuadrantes = await CalendarioDB.db.getCuadranteList();
  final nombres = <String>[];

  for (final cuadrante in cuadrantes) {
    final nombre = cuadrante.cuadranteName;
    if (nombre != null && nombre.isNotEmpty && !nombres.contains(nombre)) {
      nombres.add(nombre);
    }
  }

  await MySharedPref.setCuadrantesList(nombres);
  return List<String>.unmodifiable(nombres);
});
