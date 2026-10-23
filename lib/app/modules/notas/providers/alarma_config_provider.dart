import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmaConfigState {
  final DateTime startTime;
  final DateTime alarmTime;
  final bool enabled;
  final String label;
  final Duration? duration;
  final bool custom;
  final String customAmount;
  final String? customUnit;

  const AlarmaConfigState({
    required this.startTime,
    required this.alarmTime,
    required this.enabled,
    required this.label,
    required this.duration,
    required this.custom,
    required this.customAmount,
    required this.customUnit,
  });

  AlarmaConfigState copyWith({
    DateTime? startTime,
    DateTime? alarmTime,
    bool? enabled,
    String? label,
    Duration? duration,
    bool clearDuration = false,
    bool? custom,
    String? customAmount,
    String? customUnit,
    bool clearCustomUnit = false,
  }) {
    return AlarmaConfigState(
      startTime: startTime ?? this.startTime,
      alarmTime: alarmTime ?? this.alarmTime,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
      duration: clearDuration ? null : (duration ?? this.duration),
      custom: custom ?? this.custom,
      customAmount: customAmount ?? this.customAmount,
      customUnit: clearCustomUnit ? null : (customUnit ?? this.customUnit),
    );
  }
}

class AlarmaConfigNotifier extends Notifier<AlarmaConfigState> {
  late final TextEditingController customAmountController;

  @override
  AlarmaConfigState build() {
    customAmountController = TextEditingController();
    ref.onDispose(customAmountController.dispose);

    final now = DateTime.now();
    return AlarmaConfigState(
      startTime: now,
      alarmTime: now,
      enabled: false,
      label: 'Sin recordatorio',
      duration: null,
      custom: false,
      customAmount: '',
      customUnit: null,
    );
  }

  void initialize({
    required DateTime startTime,
    DateTime? alarmTime,
    bool enabled = false,
    String? label,
  }) {
    final savedAlarm = alarmTime ?? startTime;
    final difference = startTime.difference(savedAlarm);

    Duration? duration;
    bool custom = false;
    String? unit;
    String amount = '';

    if (enabled && difference.inSeconds >= 0) {
      if (difference == Duration.zero) {
        duration = Duration.zero;
        label = 'Al Principio';
      } else if (difference == const Duration(minutes: 5)) {
        duration = difference;
        label = '5 minutos de anticipación';
      } else if (difference == const Duration(minutes: 30)) {
        duration = difference;
        label = '30 minutos de anticipación';
      } else if (difference == const Duration(hours: 1)) {
        duration = difference;
        label = '1 hora de anticipación';
      } else if (difference == const Duration(days: 1)) {
        duration = difference;
        label = '1 día de antelación';
      } else {
        custom = true;
        if (difference.inDays > 0 &&
            difference == Duration(days: difference.inDays)) {
          unit = 'Dias';
          amount = difference.inDays.toString();
        } else if (difference.inHours > 0 &&
            difference == Duration(hours: difference.inHours)) {
          unit = 'Horas';
          amount = difference.inHours.toString();
        } else {
          unit = 'Minutos';
          amount = difference.inMinutes.toString();
        }
        duration = difference;
        label = 'Personalizado';
      }
    } else {
      enabled = false;
      label = 'Sin recordatorio';
    }

    customAmountController.text = amount;
    state = AlarmaConfigState(
      startTime: startTime,
      alarmTime: savedAlarm,
      enabled: enabled,
      label: label,
      duration: duration,
      custom: custom,
      customAmount: amount,
      customUnit: unit,
    );
  }

  void setEnabled(bool value) {
    state = state.copyWith(
      enabled: value,
      label: value ? state.label : 'Sin recordatorio',
      clearDuration: !value,
      custom: value ? state.custom : false,
      customUnit: value ? state.customUnit : null,
      clearCustomUnit: !value,
    );
  }

  void selectPreset(Duration duration, String label) {
    state = state.copyWith(
      enabled: true,
      duration: duration,
      label: label,
      custom: false,
      customAmount: '',
      clearCustomUnit: true,
    );
    customAmountController.clear();
  }

  void setCustom(bool value) {
    state = state.copyWith(
      enabled: true,
      custom: value,
      label: value ? 'Personalizado' : state.label,
      clearDuration: value,
      clearCustomUnit: !value,
    );
  }

  void setCustomAmount(String value) {
    state = state.copyWith(customAmount: value);
  }

  void setCustomUnit(String? value) {
    state = state.copyWith(customUnit: value);
  }

  Duration? get selectedDuration {
    if (!state.enabled) return null;
    if (!state.custom) return state.duration;

    final amount = int.tryParse(state.customAmount);
    if (amount == null || amount <= 0 || state.customUnit == null) {
      return null;
    }

    switch (state.customUnit) {
      case 'Minutos':
        return Duration(minutes: amount);
      case 'Horas':
        return Duration(hours: amount);
      case 'Dias':
        return Duration(days: amount);
      default:
        return null;
    }
  }

  DateTime? get calculatedAlarmTime {
    final duration = selectedDuration;
    if (!state.enabled || duration == null) return null;
    return state.startTime.subtract(duration);
  }
}

final alarmaConfigProvider =
    NotifierProvider<AlarmaConfigNotifier, AlarmaConfigState>(
  AlarmaConfigNotifier.new,
);
