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
    int? idGenerated,
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
      idGenerated: idGenerated ?? this.idGenerated,
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
    return AddNotaState(
      startTime: now,
      endTime: now,
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
    final alarmaActual = state.alarmTime;
    final alarmaActualizada = DateTime(
      value.year,
      value.month,
      value.day,
      alarmaActual.hour,
      alarmaActual.minute,
    );

    state = state.copyWith(
      startTime: value,
      endTime: state.endTime.isBefore(value) ? value : null,
      alarmTime: alarmaActualizada,
      alarmaHora: alarmaActualizada.formatDateTime24H.toString(),
    );
  }

  void setEndTime(DateTime value) {
    state = state.copyWith(endTime: value);
  }

  void setEndDate(DateTime value) {
    final current = state.endTime;
    var updated = DateTime(
      value.year,
      value.month,
      value.day,
      current.hour,
      current.minute,
    );
    if (updated.isBefore(state.startTime)) updated = state.startTime;
    state = state.copyWith(endTime: updated);
  }

  void setEndClock(TimeOfDay value) {
    final current = state.endTime;
    var updated = DateTime(
      current.year,
      current.month,
      current.day,
      value.hour,
      value.minute,
    );
    if (updated.isBefore(state.startTime)) updated = state.startTime;
    state = state.copyWith(endTime: updated);
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

  void resetForm() {
    title.clear();
    site.clear();
    notes.clear();

    final now = DateTime.now();
    state = AddNotaState(
      startTime: now,
      endTime: now,
      isImportant: false,
      alarmaCreada: false,
      alarmTime: now,
      alarmaHora: '',
      alarmaActivadaString: 'Sin recordatorio',
      firstTime: false,
      idGenerated: int.parse(randomIdGenerator()),
    );
  }

  bool _saving = false;

  Future<bool> saveNota({int? id}) async {
    if (_saving) return false;
    _saving = true;

    try {
      final currentState = state;
      final notaId = id ?? currentState.idGenerated;
      final titleText = title.text;
      final siteText = site.text;
      final notesText = notes.text;

      final nota = Task(
        id: notaId,
        title: titleText,
        site: siteText,
        notes: notesText,
        isImportant: currentState.isImportant,
        startTimeMilliseconds:
            currentState.startTime.millisecondsSinceEpoch,
        endTimeMilliseconds:
            currentState.endTime.millisecondsSinceEpoch,
        idAlarma: notaId,
        alarmaHora: currentState.alarmaHora,
        alarmaTimestamp: currentState.alarmaCreada
            ? currentState.alarmTime.millisecondsSinceEpoch
            : null,
        alarmaActivadaString: currentState.alarmaActivadaString,
        isAlarmaCreated: currentState.alarmaCreada,
      );

      var insertedId = await NotasDB.instance.insertNotas(nota);
      var attempts = 0;

      while (insertedId <= 0 && attempts < 5) {
        final newId = int.parse(randomIdGenerator());
        nota.id = newId;
        nota.idAlarma = newId;
        state = state.copyWith(idGenerated: newId);
        insertedId = await NotasDB.instance.insertNotas(nota);
        attempts++;
      }

      if (insertedId <= 0) return false;

      try {
        if (currentState.alarmaCreada) {
          await NotificacionesService.instance.programar(
            id: nota.id!,
            titulo: 'Nota: $titleText',
            mensaje: notesText,
            fechaRecordatorio: currentState.alarmTime,
          );
        } else {
          await NotificacionesService.instance.cancelar(nota.id!);
        }
      } catch (error, stackTrace) {
        debugPrint('Nota guardada; error al sincronizar recordatorio: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      try {
        await ref.read(notasListProvider.notifier).reload();
        await ref.read(notasProvider.notifier).reload();
      } catch (error, stackTrace) {
        debugPrint('Nota guardada; error al actualizar las listas: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      resetForm();
      return true;
    } finally {
      _saving = false;
    }
  }
}

final addNotaProvider =
    NotifierProvider<AddNotaNotifier, AddNotaState>(
  AddNotaNotifier.new,
);
