import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/alarma_config_state.dart';
import '../services/alarm_service.dart';

class AlarmaConfigNotifier extends StateNotifier<AlarmaConfigState> {
  AlarmaConfigNotifier() : super(AlarmaConfigState.initial());

  final customAmountController = TextEditingController();

  Future<void> load() async {
    final savedAlarm = await AlarmService.getAlarm();
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day);

    String? label;
    Duration? duration;
    bool enabled = false;
    bool custom = false;
    String amount = '';
    String unit = 'minutos';

    if (savedAlarm != null) {
      enabled = true;
      final difference = savedAlarm.difference(startTime);

      if (difference.inMinutes == 15) {
        label = '15 minutos antes';
        duration = difference;
      } else if (difference.inMinutes == 30) {
        label = '30 minutos antes';
        duration = difference;
      } else if (difference.inHours == 1) {
        label = '1 hora antes';
        duration = difference;
      } else if (difference.inHours == 2) {
        label = '2 horas antes';
        duration = difference;
      } else {
        custom = true;
        duration = difference;
        amount = difference.inMinutes.toString();
        unit = 'minutos';
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

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    if (!value) {
      await AlarmService.cancelAlarm();
    }
  }

  Future<void> setDuration(Duration duration, String newLabel) async {
    state = state.copyWith(
      duration: duration,
      label: newLabel,
      custom: false,
    );
  }

  Future<void> setCustom(String amount, String unit) async {
    final parsedAmount = int.tryParse(amount) ?? 0;
    final duration = switch (unit) {
      'horas' => Duration(hours: parsedAmount),
      'días' => Duration(days: parsedAmount),
      _ => Duration(minutes: parsedAmount),
    };

    state = state.copyWith(
      duration: duration,
      label: 'Personalizado',
      custom: true,
      customAmount: amount,
      customUnit: unit,
    );
  }

  Future<void> save() async {
    if (!state.enabled || state.duration == null) {
      await AlarmService.cancelAlarm();
      return;
    }

    final alarmTime = state.startTime.add(state.duration!);
    await AlarmService.scheduleAlarm(alarmTime);
    state = state.copyWith(alarmTime: alarmTime);
  }

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }
}
