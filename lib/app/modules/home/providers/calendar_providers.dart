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

  void setMonth(DateTime month) {
    state = month;
  }

  void setFocusedDay(DateTime day) {
    state = day;
  }
}

final focusedMonthProvider = NotifierProvider<FocusedMonthNotifier, DateTime>(
  FocusedMonthNotifier.new,
);

class SelectedDayNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setSelectedDay(DateTime? day) {
    state = day;
  }

  void clear() {
    state = null;
  }
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime?>(
  SelectedDayNotifier.new,
);

class CuadranteMapNotifier extends Notifier<Map<DateTime, List<CuadranteDay>>> {
  @override
  Map<DateTime, List<CuadranteDay>> build() => <DateTime, List<CuadranteDay>>{};

  Map<DateTime, List<CuadranteDay>> _agrupar(
    List<CuadranteDay> turnos,
  ) {
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
    final nuevoMapa = _agrupar(turnos);

    // Riverpod publica el mapa como estado principal.
    state = nuevoMapa;
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

// Turnos del día seleccionado en el calendario.
class SelectedDayTurnosNotifier extends Notifier<List<CuadranteDay>> {
  @override
  List<CuadranteDay> build() => <CuadranteDay>[];

  void setTurnos(List<CuadranteDay> turnos) {
    state = List<CuadranteDay>.of(turnos);
  }

  void clear() {
    state = <CuadranteDay>[];
  }
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

  Future<void> deleteById(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await CalendarioDB.db.deleteTypeId(id);
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

// Nombres únicos de cuadrantes. La base de datos es la fuente principal.
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
