import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/providers/add_nota_provider.dart';
import 'package:calendario2/app/modules/notas/providers/edit_nota_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmasState {
  final bool initialized;
  final bool isEditing;
  final DateTime startTime;
  final DateTime savedAlarmTime;
  final bool reminderEnabled;
  final bool advanced;
  final String selectedOption;
  final String selectedUnit;
  final String customAmount;

  const AlarmasState({
    this.initialized = false,
    this.isEditing = false,
    required this.startTime,
    required this.savedAlarmTime,
    this.reminderEnabled = false,
    this.advanced = false,
    this.selectedOption = 'Sin recordatorio',
    this.selectedUnit = 'Minutos',
    this.customAmount = '10',
  });

  AlarmasState copyWith({
    bool? initialized,
    bool? isEditing,
    DateTime? startTime,
    DateTime? savedAlarmTime,
    bool? reminderEnabled,
    bool? advanced,
    String? selectedOption,
    String? selectedUnit,
    String? customAmount,
  }) {
    return AlarmasState(
      initialized: initialized ?? this.initialized,
      isEditing: isEditing ?? this.isEditing,
      startTime: startTime ?? this.startTime,
      savedAlarmTime: savedAlarmTime ?? this.savedAlarmTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      advanced: advanced ?? this.advanced,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      customAmount: customAmount ?? this.customAmount,
    );
  }
}

class AlarmasNotifier extends Notifier<AlarmasState> {
  static const sinRecordatorio = 'Sin recordatorio';
  static const alPrincipio = 'Al Principio';
  static const cincoMinutos = '5 minutos de anticipación';
  static const treintaMinutos = '30 minutos de anticipación';
  static const unaHora = '1 hora de anticipación';
  static const unDia = '1 día de antelación';
  static const personalizado = 'Personalizado';

  @override
  AlarmasState build() {
    final now = DateTime.now();
    return AlarmasState(startTime: now, savedAlarmTime: now);
  }

  void initialize(Map<dynamic, dynamic>? args) {
    if (state.initialized) return;

    final editing = args?['isEditing'] == true;

    Task? note;
    final argumentNote = args?['currentNote'] ?? args?['currentNota'];
    if (argumentNote is Task) note = argumentNote;

    late DateTime start;
    late DateTime alarm;
    late bool enabled;

    if (editing) {
      final editState = ref.read(editNotaProvider);
      note ??= editState.currentNote;

      start = args?['startTime'] is DateTime
          ? args!['startTime'] as DateTime
          : note?.startTimeMilliseconds != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  note!.startTimeMilliseconds!,
                )
              : editState.startTime;

      alarm = editState.alarmaCreada
          ? editState.alarmTime
          : note?.alarmaTimestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  note!.alarmaTimestamp!,
                )
              : start;

      enabled = editState.alarmaCreada || (note?.isAlarmaCreated ?? false);
    } else {
      final addState = ref.read(addNotaProvider);

      start = args?['startTime'] is DateTime
          ? args!['startTime'] as DateTime
          : addState.startTime;
      alarm = addState.alarmTime;
      enabled = addState.alarmaCreada;
    }

    var selected = sinRecordatorio;
    var advanced = false;
    var unit = 'Minutos';
    var amount = '10';

    if (enabled) {
      final duration = start.difference(alarm);

      if (duration == Duration.zero) {
        selected = alPrincipio;
      } else if (duration == const Duration(minutes: 5)) {
        selected = cincoMinutos;
      } else if (duration == const Duration(minutes: 30)) {
        selected = treintaMinutos;
      } else if (duration == const Duration(hours: 1)) {
        selected = unaHora;
      } else if (duration == const Duration(days: 1)) {
        selected = unDia;
      } else {
        selected = personalizado;
        advanced = true;

        if (duration.inDays > 0 && duration.inHours == duration.inDays * 24) {
          unit = 'Dias';
          amount = duration.inDays.toString();
        } else if (duration.inHours > 0 &&
            duration.inMinutes == duration.inHours * 60) {
          unit = 'Horas';
          amount = duration.inHours.toString();
        } else {
          unit = 'Minutos';
          amount = duration.inMinutes.abs().toString();
        }
      }
    }

    state = state.copyWith(
      initialized: true,
      isEditing: editing,
      startTime: start,
      savedAlarmTime: alarm,
      reminderEnabled: enabled,
      advanced: advanced,
      selectedOption: enabled ? selected : sinRecordatorio,
      selectedUnit: unit,
      customAmount: amount,
    );
  }

  void setReminderEnabled(bool value) {
    state = state.copyWith(
      reminderEnabled: value,
      selectedOption: value
          ? (state.selectedOption == sinRecordatorio
              ? alPrincipio
              : state.selectedOption)
          : sinRecordatorio,
    );
  }

  void selectOption(String value) {
    state = state.copyWith(
      selectedOption: value,
      reminderEnabled: value != sinRecordatorio,
      advanced: value == personalizado,
    );
  }

  void setAdvanced(bool value) {
    state = state.copyWith(
      advanced: value,
      selectedOption: value
          ? personalizado
          : (state.selectedOption == personalizado
              ? alPrincipio
              : state.selectedOption),
      reminderEnabled: true,
    );
  }

  void setUnit(String value) {
    state = state.copyWith(selectedUnit: value);
  }

  void setCustomAmount(String value) {
    state = state.copyWith(customAmount: value);
  }

  Duration get duration {
    switch (state.selectedOption) {
      case alPrincipio:
        return Duration.zero;
      case cincoMinutos:
        return const Duration(minutes: 5);
      case treintaMinutos:
        return const Duration(minutes: 30);
      case unaHora:
        return const Duration(hours: 1);
      case unDia:
        return const Duration(days: 1);
      case personalizado:
        final amount = int.tryParse(state.customAmount) ?? 0;
        switch (state.selectedUnit) {
          case 'Horas':
            return Duration(hours: amount);
          case 'Dias':
            return Duration(days: amount);
          default:
            return Duration(minutes: amount);
        }
      default:
        return Duration.zero;
    }
  }

  Future<void> confirm() async {
    final enabled = state.reminderEnabled;
    final option = enabled ? state.selectedOption : sinRecordatorio;
    final start = state.startTime;

    var alarm = enabled ? start.subtract(duration) : start;
    var finalEnabled = enabled;
    var finalOption = option;

    // No programar recordatorios en el pasado.
    if (enabled && alarm.isBefore(DateTime.now())) {
      finalEnabled = false;
      finalOption = sinRecordatorio;
      alarm = start;
    }

    if (state.isEditing) {
      final notifier = ref.read(editNotaProvider.notifier);
      notifier.setAlarmaCreada(finalEnabled);
      notifier.setAlarmaActivadaString(finalOption);
      notifier.setAlarmaTime(alarm);
    } else {
      final notifier = ref.read(addNotaProvider.notifier);
      notifier.setAlarmaCreada(finalEnabled);
      notifier.setAlarmaActivadaString(finalOption);
      notifier.setAlarmaTime(alarm);
    }
  }
}

final alarmasProvider =
    NotifierProvider.autoDispose<AlarmasNotifier, AlarmasState>(
  AlarmasNotifier.new,
);
