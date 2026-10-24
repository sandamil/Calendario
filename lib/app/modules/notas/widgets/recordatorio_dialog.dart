import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordatorioDialogResult {
  const RecordatorioDialogResult({
    required this.enabled,
    required this.time,
    required this.mode,
  });

  final bool enabled;
  final DateTime time;
  final String mode;
}

Future<RecordatorioDialogResult?> showRecordatorioDialog({
  required BuildContext context,
  required bool enabled,
  required DateTime initialTime,
  required String initialMode,
  required DateTime eventDate,
}) async {
  var selectedAlertTime = initialTime;
  var selectedMode = initialMode == 'alarma' ? 'alarma' : 'notificacion';
  var reminderEnabled = enabled;

  return showDialog<RecordatorioDialogResult>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Recordatorio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activar recordatorio'),
                value: reminderEnabled,
                onChanged: (value) => setDialogState(
                  () => reminderEnabled = value,
                ),
              ),
              if (reminderEnabled) ...[
                const SizedBox(height: 12),
                const Text('Hora del aviso'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      TimeOfDay(
                        hour: selectedAlertTime.hour,
                        minute: selectedAlertTime.minute,
                      ).format(dialogContext),
                    ),
                    onPressed: () async {
                      final selected = await showTimePicker(
                        context: dialogContext,
                        initialTime: TimeOfDay.fromDateTime(selectedAlertTime),
                      );
                      if (selected == null) return;
                      setDialogState(() {
                        selectedAlertTime = DateTime(
                          eventDate.year,
                          eventDate.month,
                          eventDate.day,
                          selected.hour,
                          selected.minute,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tipo de aviso'),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'notificacion',
                        label: Text('Notificación'),
                        icon: Icon(Icons.notifications_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'alarma',
                        label: Text('Alarma'),
                        icon: Icon(Icons.alarm_rounded),
                      ),
                    ],
                    selected: <String>{selectedMode},
                    onSelectionChanged: (selection) {
                      setDialogState(() => selectedMode = selection.first);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedMode == 'alarma'
                      ? 'Aviso con canal de alarma independiente.'
                      : 'Notificación normal con el sonido del móvil.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(dialogContext)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .65),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              RecordatorioDialogResult(
                enabled: reminderEnabled,
                time: selectedAlertTime,
                mode: selectedMode,
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}
