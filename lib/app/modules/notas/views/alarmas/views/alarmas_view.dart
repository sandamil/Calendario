import 'package:calendario2/app/modules/notas/providers/alarmas_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmasView extends ConsumerStatefulWidget {
  const AlarmasView({super.key, this.routeArguments});

  final Object? routeArguments;

  @override
  ConsumerState<AlarmasView> createState() => _AlarmasViewState();
}

class _AlarmasViewState extends ConsumerState<AlarmasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = widget.routeArguments;
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
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Guardar recordatorio',
            icon: const Icon(Icons.check),
            onPressed: () async {
              await notifier.confirm();
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
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
            SizedBox(height: 8.h),
            RadioGroup<String>(
              groupValue: state.selectedOption,
              onChanged: (value) {
                if (value != null) notifier.selectOption(value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Al Principio'),
                    value: 'Al Principio',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('5 minutos de anticipación'),
                    value: '5 minutos de anticipación',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('30 minutos de anticipación'),
                    value: '30 minutos de anticipación',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('1 hora de anticipación'),
                    value: '1 hora de anticipación',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('1 día de antelación'),
                    value: '1 día de antelación',
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
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
                key: ValueKey(state.selectedUnit),
                initialValue: state.selectedUnit,
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
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                state.reminderEnabled
                    ? 'Aviso previsto: ${state.startTime.subtract(notifier.duration)}'
                    : 'No se creará ningún recordatorio.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () async {
              await notifier.confirm();
              if (context.mounted) context.pop();
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
