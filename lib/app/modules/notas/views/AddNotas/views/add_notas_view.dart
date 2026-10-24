import 'package:calendario2/app/modules/notas/providers/add_nota_provider.dart';
import 'package:calendario2/app/modules/notas/views/widgets/example_alarm_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddNotasView extends ConsumerStatefulWidget {
  const AddNotasView({super.key});

  @override
  ConsumerState<AddNotasView> createState() => _AddNotasViewState();
}

class _AddNotasViewState extends ConsumerState<AddNotasView> {
  Future<void> _editReminderTime(
    BuildContext context,
    AddNotaState notaState,
    AddNotaNotifier notaNotifier,
  ) async {
    final initial = notaState.alarmaCreada
        ? notaState.alarmTime
        : notaState.startTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!context.mounted || selected == null) return;

    final updated = DateTime(
      notaState.startTime.year,
      notaState.startTime.month,
      notaState.startTime.day,
      selected.hour,
      selected.minute,
    );
    notaNotifier.setAlarmaCreada(true);
    notaNotifier.setAlarmaTime(updated);
    notaNotifier.setAlarmaActivadaString(
      'A las ${TimeOfDay(hour: updated.hour, minute: updated.minute).format(context)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final notaState = ref.watch(addNotaProvider);
    final notaNotifier = ref.read(addNotaProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir nota'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          TextField(
            controller: notaNotifier.title,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: notaNotifier.notes,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          SizedBox(height: 20.h),
          TextButton(
            onPressed: () async {
              final initial = notaState.startTime;
              final selected = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
              );
              if (!context.mounted || selected == null) return;
              notaNotifier.setStartTime(DateTime(
                selected.year,
                selected.month,
                selected.day,
                initial.hour,
                initial.minute,
              ));
            },
            child: _dateTimeRow('Fecha de inicio', notaState.startTime.toString()),
          ),
          TextButton(
            onPressed: () async {
              final initial = notaState.startTime;
              final selected = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(initial),
              );
              if (!context.mounted || selected == null) return;
              notaNotifier.setStartTime(DateTime(
                initial.year,
                initial.month,
                initial.day,
                selected.hour,
                selected.minute,
              ));
            },
            child: _dateTimeRow(
              'Hora de inicio',
              notaState.startTime.formatDateTime24H,
            ),
          ),
          TextButton(
            onPressed: () async {
              final initial = notaState.endTime;
              final selected = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
              );
              if (!context.mounted || selected == null) return;
              var updated = DateTime(
                selected.year,
                selected.month,
                selected.day,
                initial.hour,
                initial.minute,
              );
              if (updated.isBefore(notaState.startTime)) {
                updated = notaState.startTime;
              }
              notaNotifier.setEndTime(updated);
            },
            child: _dateTimeRow('Fecha de fin', notaState.endTime.formatDateYMD),
          ),
          TextButton(
            onPressed: () async {
              final initial = notaState.endTime;
              final selected = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(initial),
              );
              if (!context.mounted || selected == null) return;
              var updated = DateTime(
                initial.year,
                initial.month,
                initial.day,
                selected.hour,
                selected.minute,
              );
              if (updated.isBefore(notaState.startTime)) {
                updated = notaState.startTime;
              }
              notaNotifier.setEndTime(updated);
            },
            child: _dateTimeRow(
              'Hora de fin',
              notaState.endTime.formatDateTime24H,
            ),
          ),
          SizedBox(height: 8.h),
          const Divider(),
          InkWell(
            onTap: () => _editReminderTime(context, notaState, notaNotifier),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recordatorio', style: theme.textTheme.titleMedium),
                        SizedBox(height: 2.h),
                        Text(
                          notaState.alarmaCreada
                              ? 'A las ${TimeOfDay(hour: notaState.alarmTime.hour, minute: notaState.alarmTime.minute).format(context)}'
                              : 'Sin recordatorio',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 6.w),
                      ),
                    ),
                    segments: const [
                      ButtonSegment<String>(
                        value: 'notificacion',
                        label: Text('Notif.'),
                        icon: Icon(Icons.notifications_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'alarma',
                        label: Text('Alarma'),
                        icon: Icon(Icons.alarm_rounded),
                      ),
                    ],
                    selected: {notaState.notificationMode},
                    onSelectionChanged: (selection) {
                      notaNotifier.setNotificationMode(selection.first);
                    },
                  ),
                  SizedBox(width: 4.w),
                  Switch(
                    value: notaState.alarmaCreada,
                    onChanged: (enabled) {
                      if (enabled) {
                        _editReminderTime(context, notaState, notaNotifier);
                      } else {
                        notaNotifier.setAlarmaCreada(false);
                        notaNotifier.setAlarmaActivadaString('Sin recordatorio');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: notaNotifier.toggleImportant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Marcar como importante'),
                Icon(
                  notaState.isImportant ? Icons.flag : Icons.outlined_flag,
                  color: notaState.isImportant ? Colors.red : null,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          FilledButton(
            onPressed: () async {
              final ok = await notaNotifier.saveNota();
              if (ok && context.mounted) context.pop();
            },
            child: const Text('Guardar nota'),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}
