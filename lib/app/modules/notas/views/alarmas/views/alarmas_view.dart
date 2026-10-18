import 'package:calendario2/app/modules/notas/providers/alarmas_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AlarmasView extends ConsumerStatefulWidget {
  const AlarmasView({super.key});

  @override
  ConsumerState<AlarmasView> createState() => _AlarmasViewState();
}

class _AlarmasViewState extends ConsumerState<AlarmasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = Get.arguments;
      ref.read(alarmasProvider.notifier).initialize(
            args is Map ? args : null,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alarmasProvider);
    final notifier = ref.read(alarmasProvider.notifier);

    if (!state.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            tooltip: 'Guardar recordatorio',
            icon: const Icon(Icons.check),
            onPressed: () async {
              await notifier.confirm();
              if (context.mounted) Get.back();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              state.reminderEnabled ? 'Recordar' : 'No recordar',
            ),
            subtitle: Text(
              state.reminderEnabled
                  ? 'Selecciona cuándo quieres recibir el aviso.'
                  : 'La nota se guardará sin notificación.',
            ),
            value: state.reminderEnabled,
            onChanged: notifier.setReminderEnabled,
          ),
          if (state.reminderEnabled) ...[
            const Divider(),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Al Principio'),
              value: 'Al Principio',
              groupValue: state.selectedOption,
              onChanged: (value) {
                if (value != null) notifier.selectOption(value);
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('5 minutos de anticipación'),
              value: '5 minutos de anticipación',
              groupValue: state.selectedOption,
              onChanged: (value) {
                if (value != null) notifier.selectOption(value);
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('30 minutos de anticipación'),
              value: '30 minutos de anticipación',
              groupValue: state.selectedOption,
              onChanged: (value) {
                if (value != null) notifier.selectOption(value);
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('1 hora de anticipación'),
              value: '1 hora de anticipación',
              groupValue: state.selectedOption,
              onChanged: (value) {
                if (value != null) notifier.selectOption(value);
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('1 día de antelación'),
              value: '1 día de antelación',
              groupValue: state.selectedOption,
              onChanged: (value) {
                if (value != null) notifier.selectOption(value);
              },
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Personalizado'),
              subtitle: const Text('Define minutos, horas o días antes.'),
              value: state.advanced,
              onChanged: notifier.setAdvanced,
            ),
            if (state.advanced) ...[
              const SizedBox(height: 8),
              TextFormField(
                key: ValueKey(state.customAmount),
                initialValue: state.customAmount,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: notifier.setCustomAmount,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: state.selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Minutos',
                    child: Text('Minutos'),
                  ),
                  DropdownMenuItem(
                    value: 'Horas',
                    child: Text('Horas'),
                  ),
                  DropdownMenuItem(
                    value: 'Dias',
                    child: Text('Días'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) notifier.setUnit(value);
                },
              ),
            ],
          ],
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.reminderEnabled
                    ? 'Aviso previsto: ${state.startTime.subtract(notifier.duration)}'
                    : 'No se creará ningún recordatorio.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await notifier.confirm();
              if (context.mounted) Get.back();
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
