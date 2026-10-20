import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/app/modules/notas/services/notificaciones_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditNotaState {
  final Task? currentNote;
  final DateTime startTime;
  final DateTime endTime;
  final bool isImportant;
  final bool alarmaCreada;
  final DateTime alarmTime;
  final String alarmaHora;
  final String alarmaActivadaString;
  final bool loading;

  const EditNotaState({
    this.currentNote,
    required this.startTime,
    required this.endTime,
    required this.isImportant,
    required this.alarmaCreada,
    required this.alarmTime,
    required this.alarmaHora,
    required this.alarmaActivadaString,
    required this.loading,
  });

  EditNotaState copyWith({
    Task? currentNote,
    DateTime? startTime,
    DateTime? endTime,
    bool? isImportant,
    bool? alarmaCreada,
    DateTime? alarmTime,
    String? alarmaHora,
    String? alarmaActivadaString,
    bool? loading,
  }) {
    return EditNotaState(
      currentNote: currentNote ?? this.currentNote,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isImportant: isImportant ?? this.isImportant,
      alarmaCreada: alarmaCreada ?? this.alarmaCreada,
      alarmTime: alarmTime ?? this.alarmTime,
      alarmaHora: alarmaHora ?? this.alarmaHora,
      alarmaActivadaString:
          alarmaActivadaString ?? this.alarmaActivadaString,
      loading: loading ?? this.loading,
    );
  }
}

class EditNotaNotifier extends Notifier<EditNotaState> {
  late final TextEditingController title;
  late final TextEditingController site;
  late final TextEditingController notes;

  @override
  EditNotaState build() {
    title = TextEditingController();
    site = TextEditingController();
    notes = TextEditingController();

    ref.onDispose(() {
      title.dispose();
      site.dispose();
      notes.dispose();
    });

    return EditNotaState(
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      isImportant: false,
      alarmaCreada: false,
      alarmTime: DateTime.now(),
      alarmaHora: '',
      alarmaActivadaString: 'Sin recordatorio',
      loading: true,
    );
  }

  Future<void> load(int id) async {
    final note = await NotasDB.instance.select(id);

    title.text = note.title ?? '';
    site.text = note.site ?? '';
    notes.text = note.notes ?? '';

    final start = DateTime.fromMillisecondsSinceEpoch(
      note.startTimeMilliseconds!,
    );
    final end = DateTime.fromMillisecondsSinceEpoch(
      note.endTimeMilliseconds!,
    );

    final alarmaCreada = note.isAlarmaCreated ?? false;
    final etiquetaAlarma =
        note.alarmaActivadaString ?? 'Sin recordatorio';

    // Preferir siempre la fecha completa si la base de datos la conserva.
    DateTime horaAlarma = start;
    if (alarmaCreada) {
      if (note.alarmaTimestamp != null) {
        horaAlarma = DateTime.fromMillisecondsSinceEpoch(
          note.alarmaTimestamp!,
        );
      } else {
        // Recuperar las opciones estándar usando la fecha del evento.
        switch (etiquetaAlarma) {
          case 'Al Principio':
            horaAlarma = start;
            break;
          case '5 minutos de anticipación':
            horaAlarma = start.subtract(const Duration(minutes: 5));
            break;
          case '30 minutos de anticipación':
            horaAlarma = start.subtract(const Duration(minutes: 30));
            break;
          case '1 hora de anticipación':
            horaAlarma = start.subtract(const Duration(hours: 1));
            break;
          case '1 día de antelación':
            horaAlarma = start.subtract(const Duration(days: 1));
            break;
          default:
            // Para recordatorios personalizados, recuperar HH:mm.
            final partes = (note.alarmaHora ?? '').split(':');
            if (partes.length == 2) {
              final hora = int.tryParse(partes[0]);
              final minuto = int.tryParse(partes[1]);
              if (hora != null &&
                  minuto != null &&
                  hora >= 0 &&
                  hora <= 23 &&
                  minuto >= 0 &&
                  minuto <= 59) {
                horaAlarma = DateTime(
                  start.year,
                  start.month,
                  start.day,
                  hora,
                  minuto,
                );
                // Si la hora supera la hora del evento, el aviso
                // corresponde al día anterior.
                if (horaAlarma.isAfter(start)) {
                  horaAlarma = horaAlarma.subtract(
                    const Duration(days: 1),
                  );
                }
              }
            }
            break;
        }
      }
    }

    state = state.copyWith(
      currentNote: note,
      startTime: start,
      endTime: end,
      isImportant: note.isImportant ?? false,
      alarmaCreada: alarmaCreada,
      alarmTime: horaAlarma,
      alarmaHora: note.alarmaHora ?? '',
      alarmaActivadaString: etiquetaAlarma,
      loading: false,
    );
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

  void setAlarmaHoraString(String value) {
    state = state.copyWith(alarmaHora: value);
  }

  Future<void> editNote(Task oldNote) async {
    if (oldNote.id == null) {
      throw StateError('La nota no tiene un ID válido.');
    }

    // Capturar todos los datos antes del primer await.
    final notaId = oldNote.id!;
    final alarmaId = oldNote.idAlarma ?? notaId;
    final titulo = title.text;
    final textoNotas = notes.text;
    final importante = state.isImportant;
    final inicio = state.startTime;
    final fin = state.endTime;
    final alarmaCreada = state.alarmaCreada;
    final horaAlarma = state.alarmTime;
    final alarmaHora = state.alarmaHora;
    final alarmaActivada = state.alarmaActivadaString;

    await NotasDB.instance.update(
      Task(
        id: notaId,
        title: titulo,
        site: site.text,
        notes: textoNotas,
        isImportant: importante,
        startTimeMilliseconds: inicio.millisecondsSinceEpoch,
        endTimeMilliseconds: fin.millisecondsSinceEpoch,
        idAlarma: alarmaId,
        alarmaHora: alarmaHora,
        alarmaTimestamp:
            alarmaCreada ? horaAlarma.millisecondsSinceEpoch : null,
        alarmaActivadaString: alarmaActivada,
        isAlarmaCreated: alarmaCreada,
      ),
    );

    // La nota ya está guardada. Un fallo de notificaciones no debe
    // impedir que se actualicen las listas ni confundirse con un fallo
    // al guardar los datos de la nota.
    try {
      if (alarmaCreada) {
        await NotificacionesService.instance.programar(
          id: alarmaId,
          titulo: 'Nota: $titulo',
          mensaje: textoNotas,
          fechaRecordatorio: horaAlarma,
        );
      } else {
        await NotificacionesService.instance.cancelar(alarmaId);
      }
    } catch (error, stackTrace) {
      debugPrint(
        'La nota $notaId se guardó, pero falló la sincronización '
        'de su recordatorio: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    // No usar ref si este notifier ya se ha destruido.
    if (!ref.mounted) return;

    await ref.read(notasListProvider.notifier).reload();
    if (!ref.mounted) return;

    await ref.read(notasProvider.notifier).reload();
  }
}

final editNotaProvider =
    NotifierProvider.autoDispose<EditNotaNotifier, EditNotaState>(
  EditNotaNotifier.new,
);
