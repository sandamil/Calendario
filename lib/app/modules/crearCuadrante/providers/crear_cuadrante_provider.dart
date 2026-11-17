import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/model/turnoType.dart';
import '../services/rotation_engine.dart';

class CrearCuadranteState {
  const CrearCuadranteState({
    this.cuadranteName = '',
    this.cuadrantesNameList = const <String>[],
    required this.inicialDate,
    required this.endDate,
    this.list = const <TurnoType>[],
    this.turnoType = const <TurnoType>[],
    this.isSwitched = false,
    this.cuadranteLoading = true,
    this.firstTime = false,
    this.daysPerTurno = 1,
    this.offsetDays = 0,
  });

  final String cuadranteName;
  final List<String> cuadrantesNameList;
  final DateTime inicialDate;
  final DateTime endDate;
  final List<TurnoType> list;
  final List<TurnoType> turnoType;
  final bool isSwitched;
  final bool cuadranteLoading;
  final bool firstTime;
  final int daysPerTurno;
  final int offsetDays;

  bool get canSubmit =>
      list.isNotEmpty &&
      !endDate.isBefore(inicialDate) &&
      endDate.difference(inicialDate).inDays <=
          RotationEngine.maxGeneratedDays - 1 &&
      list.length * daysPerTurno <= 366;

  CrearCuadranteState copyWith({
    String? cuadranteName,
    List<String>? cuadrantesNameList,
    DateTime? inicialDate,
    DateTime? endDate,
    List<TurnoType>? list,
    List<TurnoType>? turnoType,
    bool? isSwitched,
    bool? cuadranteLoading,
    bool? firstTime,
    int? daysPerTurno,
    int? offsetDays,
  }) {
    return CrearCuadranteState(
      cuadranteName: cuadranteName ?? this.cuadranteName,
      cuadrantesNameList: cuadrantesNameList ?? this.cuadrantesNameList,
      inicialDate: inicialDate ?? this.inicialDate,
      endDate: endDate ?? this.endDate,
      list: list ?? this.list,
      turnoType: turnoType ?? this.turnoType,
      isSwitched: isSwitched ?? this.isSwitched,
      cuadranteLoading: cuadranteLoading ?? this.cuadranteLoading,
      firstTime: firstTime ?? this.firstTime,
      daysPerTurno: daysPerTurno ?? this.daysPerTurno,
      offsetDays: offsetDays ?? this.offsetDays,
    );
  }
}

class CrearCuadranteNotifier extends Notifier<CrearCuadranteState> {
  @override
  CrearCuadranteState build() {
    Future<void>.microtask(loadInitialData);
    return CrearCuadranteState(
      inicialDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Future<void> loadInitialData() async {
    final cuadrantes = await CalendarioDB.db.getCuadranteList();
    final nombres = <String>[];

    for (final cuadrante in cuadrantes) {
      final nombre = cuadrante.cuadranteName;
      if (nombre != null && !nombres.contains(nombre)) {
        nombres.add(nombre);
      }
    }

    await MySharedPref.setCuadrantesList(nombres);
    final tipos = await CalendarioDB.db.getTypeModels();

    state = state.copyWith(
      cuadrantesNameList: List<String>.unmodifiable(nombres),
      turnoType: List<TurnoType>.unmodifiable(tipos),
    );
  }

  void resetForCreate() {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);

    state = state.copyWith(
      cuadranteName: '',
      inicialDate: inicio,
      endDate: inicio.add(const Duration(days: 365)),
      list: <TurnoType>[],
      daysPerTurno: 1,
      offsetDays: 0,
      isSwitched: false,
      cuadranteLoading: false,
      firstTime: false,
    );
  }

  void setCuadranteName(String value) {
    state = state.copyWith(cuadranteName: value);
  }

  void setInicialDate(DateTime value) {
    state = state.copyWith(inicialDate: value);
  }

  void setEndDate(DateTime value) {
    state = state.copyWith(endDate: value);
  }

  void setFirstTime(bool value) {
    state = state.copyWith(firstTime: value);
  }

  void setDaysPerTurno(int value) {
    if (value < 1 || value > 31) return;
    state = state.copyWith(daysPerTurno: value);
  }

  void setOffsetDays(int value) {
    if (value < 0 || value > 365) return;
    state = state.copyWith(offsetDays: value);
  }

  void addTurno(TurnoType turno) {
    state = state.copyWith(list: [...state.list, turno]);
  }

  void removeTurnoAt(int index) {
    if (index < 0 || index >= state.list.length) return;
    final nuevaLista = List<TurnoType>.of(state.list)..removeAt(index);
    state = state.copyWith(list: nuevaLista);
  }

  void clearTurnos() {
    state = state.copyWith(list: <TurnoType>[]);
  }

  Future<bool> prepareEdit(String name) async {
    final registros = await CalendarioDB.db.getCuadranteList();
    final dias = registros.where((item) => item.cuadranteName == name).toList();

    if (dias.isEmpty || dias.any((item) => item.dateTime == null)) {
      return false;
    }

    dias.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    final inicio = dias.first.dateTime!;
    final fin = dias.last.dateTime!;
    final fechaInicio = DateTime(inicio.year, inicio.month, inicio.day);
    final fechaFin = DateTime(fin.year, fin.month, fin.day);

    bool mismoTurno(dynamic a, dynamic b) =>
        a.title == b.title &&
        a.description == b.description &&
        a.startHour == b.startHour &&
        a.endHour == b.endHour &&
        a.color == b.color;

    bool fechasConsecutivas() {
      for (var i = 1; i < dias.length; i++) {
        final anterior = dias[i - 1].dateTime!;
        final actual = dias[i].dateTime!;
        final diferencia = DateTime(actual.year, actual.month, actual.day)
            .difference(DateTime(anterior.year, anterior.month, anterior.day))
            .inDays;
        if (diferencia != 1) return false;
      }
      return true;
    }

    // La base guarda los días ya expandidos, no la longitud original del ciclo.
    // Al editar, reconstruimos el ciclo periódico más corto para no convertir
    // una rotación de 4/5/7 días en una secuencia anual de 365 días.
    var cycleLength = dias.length;
    if (fechasConsecutivas()) {
      final maxCandidate = dias.length < 366 ? dias.length : 366;
      for (var candidate = 1; candidate <= maxCandidate; candidate++) {
        var repeats = true;
        for (var i = candidate; i < dias.length; i++) {
          if (!mismoTurno(dias[i], dias[i % candidate])) {
            repeats = false;
            break;
          }
        }
        if (repeats) {
          cycleLength = candidate;
          break;
        }
      }
    }

    final turnos = dias
        .take(cycleLength)
        .map(
          (dia) => TurnoType(
            title: dia.title,
            description: dia.description,
            startHour: dia.startHour,
            endHour: dia.endHour,
            color: dia.color,
          ),
        )
        .toList(growable: false);

    state = state.copyWith(
      cuadranteName: name,
      inicialDate: fechaInicio,
      endDate: fechaFin,
      list: List<TurnoType>.unmodifiable(turnos),
      daysPerTurno: 1,
      offsetDays: 0,
      cuadranteLoading: false,
    );
    return true;
  }

  Future<void> deleteCuadrante(String name) async {
    await CalendarioDB.db.deleteCuadrante(name);

    final nombres = List<String>.of(state.cuadrantesNameList)..remove(name);

    await MySharedPref.setCuadrantesList(nombres);
    state = state.copyWith(
      cuadrantesNameList: List<String>.unmodifiable(nombres),
    );
  }

  Future<void> deleteAllCuadrante() async {
    await CalendarioDB.db.deleteALlCuadrante();
    await MySharedPref.deleteCuadrantesList();

    state = state.copyWith(cuadrantesNameList: <String>[]);
  }

  Future<void> cuadranteLoad() async {
    if (!state.canSubmit || state.cuadranteName.isEmpty) return;

    state = state.copyWith(cuadranteLoading: true);

    try {
      await rotation(
        DateTime(
          state.inicialDate.year,
          state.inicialDate.month,
          state.inicialDate.day,
        ),
        DateTime(state.endDate.year, state.endDate.month, state.endDate.day),
      );
    } finally {
      state = state.copyWith(cuadranteLoading: false);
    }
  }

  Future<void> rotation(DateTime start, DateTime end) async {
    if (state.list.isEmpty || end.isBefore(start)) return;

    final nombre = state.cuadranteName;
    final actualizar = state.cuadrantesNameList.contains(nombre);
    final pattern = RotationPattern(
      name: nombre,
      offsetDays: 0,
      steps: state.list
          .map((turno) => RotationStep(shift: turno, days: 1))
          .toList(growable: false),
    );
    final items = RotationEngine.generate(
      pattern: pattern,
      start: start,
      end: end,
      calendarName: nombre,
    );

    await CalendarioDB.db.replaceCuadranteItems(nombre, items);

    if (!actualizar) {
      final nombres = <String>[...state.cuadrantesNameList, nombre];
      await MySharedPref.setCuadrantesList(nombres);
      state = state.copyWith(
        cuadrantesNameList: List<String>.unmodifiable(nombres),
      );
    }
  }
}

final crearCuadranteProvider =
    NotifierProvider<CrearCuadranteNotifier, CrearCuadranteState>(
      CrearCuadranteNotifier.new,
    );
