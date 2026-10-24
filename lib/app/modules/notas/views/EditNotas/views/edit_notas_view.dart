import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/notas/providers/edit_nota_provider.dart';
import 'package:calendario2/app/modules/notas/widgets/recordatorio_dialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditNotasView extends ConsumerStatefulWidget {
  const EditNotasView({super.key, this.routeArguments});

  final Object? routeArguments;

  @override
  ConsumerState<EditNotasView> createState() => _EditNotasViewState();
}

class _EditNotasViewState extends ConsumerState<EditNotasView> {
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) return;
    _loadStarted = true;

    final args = widget.routeArguments;
    int? id;
    if (args is Map) {
      final value = args['id'];
      if (value is int) id = value;
      if (value is String) id = int.tryParse(value);
    } else if (args is int) {
      id = args;
    }

    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(editNotaProvider.notifier).load(id!);
    });
  }

  Widget _buildGeneralFormField(TextEditingController controller, String label, int lines) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final lower = label.toLowerCase();
    final icon = lower.contains('ubic')
        ? Icons.location_on_outlined
        : lower.contains('observ')
            ? Icons.notes_rounded
            : Icons.title_rounded;
    final hint = lower.contains('ubic')
        ? 'Añade una ubicación (opcional)'
        : lower.contains('observ')
            ? 'Escribe los detalles que quieras recordar'
            : 'Escribe un título breve';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 3.w, bottom: 6.h),
          child: Text(label.replaceFirst('Titulo', 'Título'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: .72))),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .48),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .38)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: lines,
            minLines: lines > 1 ? (lines < 3 ? lines : 3) : 1,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 14.sp, color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: PRIMARY_COLOR, size: 20.sp),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13.sp, color: textColor.withValues(alpha: .42)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: lines > 1 ? 14.h : 15.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateTimeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CustomTextStyle.rowButomText),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(color: MyColors.textButtomBlack, fontSize: 16.sp)),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: PRIMARY_COLOR),
          ],
        ),
      ],
    );
  }

  Future<void> _openReminderDialog(
    EditNotaNotifier notifier,
    EditNotaState state,
  ) async {
    final result = await showRecordatorioDialog(
      context: context,
      enabled: state.alarmaCreada,
      initialTime: state.alarmaCreada ? state.alarmTime : state.startTime,
      initialMode: state.notificationMode,
      eventDate: state.startTime,
    );
    if (!mounted || result == null) return;

    notifier.setAlarmaCreada(result.enabled);
    notifier.setNotificationMode(result.mode);
    if (result.enabled) {
      notifier.setAlarmaTime(result.time);
      notifier.setAlarmaActivadaString(
        'A las ${TimeOfDay(hour: result.time.hour, minute: result.time.minute).format(context)}',
      );
    } else {
      notifier.setAlarmaActivadaString('Sin recordatorio');
    }
  }

  Widget _reminderTile(EditNotaState state, EditNotaNotifier notifier) {
    final color = Theme.of(context).colorScheme.onSurface;
    final reminderTime = state.alarmaCreada
        ? TimeOfDay(
            hour: state.alarmTime.hour,
            minute: state.alarmTime.minute,
          ).format(context)
        : 'Sin recordatorio';

    return Material(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: .55),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _openReminderDialog(notifier, state),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(
                state.notificationMode == 'alarma'
                    ? Icons.alarm_rounded
                    : Icons.notifications_outlined,
                color: PRIMARY_COLOR,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recordatorio',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      reminderTime,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: color.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withValues(alpha: .55)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editNotaProvider);
    final notifier = ref.read(editNotaProvider.notifier);

    if (state.loading || state.currentNote == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Editar Nota', style: CustomTextStyle.appBarTitle(context: context))),
        body: Center(child: state.loading ? const CircularProgressIndicator() : const Text('No se ha podido cargar la nota.')),
      );
    }

    final note = state.currentNote!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Editar Nota', style: CustomTextStyle.appBarTitle(context: context), overflow: TextOverflow.clip, softWrap: false),
        leading: IconButton(
          icon: Icon(Icons.clear, color: PRIMARY_COLOR, size: 26.sp),
          onPressed: () => context.go('/notas'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: PRIMARY_COLOR, size: 26.sp),
            padding: EdgeInsets.only(right: 3.w),
            onPressed: () async {
              await notifier.editNote(note);
              if (mounted) context.go('/notas');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Container(margin: EdgeInsets.symmetric(horizontal: 6.w), child: _buildGeneralFormField(notifier.title, 'Titulo del evento', 1)),
                SizedBox(height: 8.h),
                Container(margin: EdgeInsets.symmetric(horizontal: 6.w), child: _buildGeneralFormField(notifier.site, 'Ubicación', 2)),
                SizedBox(height: 8.h),
                _buildGeneralFormField(notifier.notes, 'Observaciones', 8),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () async {
                    final initial = state.startTime;
                    final selected = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1900), lastDate: DateTime(2200));
                    if (!context.mounted || selected == null) return;
                    notifier.setStartTime(DateTime(selected.year, selected.month, selected.day, initial.hour, initial.minute));
                  },
                  child: _dateTimeRow('Fecha de inicio', state.startTime.formatDateYMD),
                ),
                TextButton(
                  onPressed: () async {
                    final initial = state.startTime;
                    final selected = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
                    if (!context.mounted || selected == null) return;
                    notifier.setStartTime(DateTime(initial.year, initial.month, initial.day, selected.hour, selected.minute));
                  },
                  child: _dateTimeRow('Hora de inicio', state.startTime.formatDateTime24H),
                ),
                TextButton(
                  onPressed: () async {
                    final initial = state.endTime;
                    final selected = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1900), lastDate: DateTime(2200));
                    if (!context.mounted || selected == null) return;
                    var updated = DateTime(selected.year, selected.month, selected.day, initial.hour, initial.minute);
                    if (updated.isBefore(state.startTime)) updated = state.startTime;
                    notifier.setEndTime(updated);
                  },
                  child: _dateTimeRow('Fecha de fin', state.endTime.formatDateYMD),
                ),
                TextButton(
                  onPressed: () async {
                    final initial = state.endTime;
                    final selected = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
                    if (!context.mounted || selected == null) return;
                    var updated = DateTime(initial.year, initial.month, initial.day, selected.hour, selected.minute);
                    if (updated.isBefore(state.startTime)) {
                      final start = state.startTime;
                      updated = DateTime(start.year, start.month, start.day, selected.hour, selected.minute);
                      if (updated.isBefore(start)) updated = updated.add(const Duration(days: 1));
                    }
                    notifier.setEndTime(updated);
                  },
                  child: _dateTimeRow('Hora de fin', state.endTime.formatDateTime24H),
                ),
                SizedBox(height: 6.h),
                LineWidget(),
                SizedBox(height: 8.h),
                _reminderTile(state, notifier),
                SizedBox(height: 8.h),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: notifier.toggleImportant,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      child: Row(
                        children: [
                          Icon(state.isImportant ? Icons.flag_rounded : Icons.outlined_flag, color: state.isImportant ? Colors.red : PRIMARY_COLOR),
                          SizedBox(width: 10.w),
                          Expanded(child: Text('Marcar como importante', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600))),
                          Switch(value: state.isImportant, onChanged: notifier.setImportant),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                LineWidget(),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
