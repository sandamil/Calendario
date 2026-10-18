import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/app/modules/notas/services/notificaciones_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNotaState {
  final DateTime startTime;
  final DateTime endTime;
  final bool isImportant;
  final bool alarmaCreada;
  final DateTime alarmTime;
  final String alarmaHora;
  final String alarmaActivadaString;
  final bool firstTime;
  final int idGenerated;

  const AddNotaState({
    required this.startTime,
    required this.endTime,
    required this.isImportant,
    required this.alarmaCreada,
    required this.alarmTime,
    required this.alarmaHora,
    required this.alarmaActivadaString,
    required this.firstTime,
    required this.idGenerated,
  });

  AddNotaState copyWith({
    DateTime? startTime,
    DateTime? endTime,
    bool? isImportant,
    bool? alarmaCreada,
    DateTime? alarmTime,
    String? alarmaHora,
    String? alarmaActivadaString,
    bool? firstTime,
  }) {
    return AddNotaState(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isImportant: isImportant ?? this.isImportant,
      alarmaCreada: alarmaCreada ?? this.alarmaCreada,
      alarmTime: alarmTime ?? this.alarmTime,
      alarmaHora: alarmaHora ?? this.alarmaHora,
      alarmaActivadaString:
          alarmaActivadaString ?? this.alarmaActivadaString,
      firstTime: firstTime ?? this.firstTime,
      idGenerated: idGenerated,
    );
  }
}

class AddNotaNotifier extends Notifier<AddNotaState> {
  late final TextEditingController title;
  late final TextEditingController site;
  late final TextEditingController notes;

  @override
  AddNotaState build() {
    title = TextEditingController();
    site = TextEditingController();
    notes = TextEditingController();

    ref.onDispose(() {
      title.dispose();
      site.dispose();
      notes.dispose();
    });

    final now = DateTime.now();
    var start = now;
    var end = now;

    // El formulario puede abrirse desde un día concreto del calendario.
    // La vista debe llamar setInitialDate si recibe ese argumento.
    return AddNotaState(
      startTime: start,
      endTime: end,
      isImportant: false,
      alarmaCreada: false,
      alarmTime: now,
      alarmaHora: '',
      alarmaActivadaString: 'Sin recordatorio',
      firstTime: false,
      idGenerated: int.parse(randomIdGenerator()),
    );
  }

  void setInitialDate(DateTime date) {
    state = state.copyWith(startTime: date, endTime: date);
  }

  void setStartTime(DateTime value) {
    state = state.copyWith(
      startTime: value,
      alarmaHora: value.formatDateTime24H.toString(),
    );
  }

  void setEndTime(DateTime value) {
    state = state.copyWith(endTime: value);
  }

  void toggleImportant() {
    state = state.copyWith(isImportant: !state.isImportant);
  }

  void setImportant(bool value) {
    state = state.copyWith(isImportant: value);
  }

  void setAlarmaCreada(bool value) {
    state = state.copyWith(alarmaCreada: value);
  }

  void setAlarmaTime(DateTime value) {
    state = state.copyWith(
      alarmTime: value,
      alarmaHora: value.formatDateTime24H.toString(),
    );
  }

  void setAlarmaActivadaString(String value) {
    state = state.copyWith(alarmaActivadaString: value);
  }

  void setFirstTime(bool value) {
    state = state.copyWith(firstTime: value);
  }

  Future<void> saveNota({int? id}) async {
    final notaId = id ?? state.idGenerated;

    final nota = Task(
      id: notaId,
      title: title.text,
      site: site.text,
      notes: notes.text,
      isImportant: state.isImportant,
      startTimeMilliseconds: state.startTime.millisecondsSinceEpoch,
      endTimeMilliseconds: state.endTime.millisecondsSinceEpoch,
      idAlarma: notaId,
      alarmaHora: state.alarmaHora,
      alarmaTimestamp: state.alarmaCreada
          ? state.alarmTime.millisecondsSinceEpoch
          : null,
      alarmaActivadaString: state.alarmaActivadaString,
      isAlarmaCreated: state.alarmaCreada,
    );

    // Primero guardamos la nota. La notificación nunca debe existir
    // como consecuencia de un guardado que todavía no ha terminado.
    await NotasDB.instance.insertNotas(nota);

    // Sincronizamos la notificación DESPUÉS de guardar correctamente.
    if (state.alarmaCreada) {
      await NotificacionesService.instance.programar(
        id: notaId,
        titulo: 'Nota: ${title.text}',
        mensaje: notes.text,
        fechaRecordatorio: state.alarmTime,
      );
    } else {
      // Garantiza que no quede una notificación antigua con este ID.
      await NotificacionesService.instance.cancelar(notaId);
    }

    await ref.read(notasListProvider.notifier).reload();
    await ref.read(notasProvider.notifier).reload();
  }
}

final addNotaProvider =
    NotifierProvider<AddNotaNotifier, AddNotaState>(
  AddNotaNotifier.new,
);
