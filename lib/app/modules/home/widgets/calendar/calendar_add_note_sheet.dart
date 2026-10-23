import 'package:calendario2/app/modules/notas/providers/add_nota_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarAddNoteSheet extends ConsumerStatefulWidget {
  const CalendarAddNoteSheet({required this.selectedDate, super.key});

  final DateTime selectedDate;

  @override
  ConsumerState<CalendarAddNoteSheet> createState() =>
      CalendarAddNoteSheetState();
}

class CalendarAddNoteSheetState extends ConsumerState<CalendarAddNoteSheet> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(addNotaProvider.notifier);
      notifier.resetForm();
      notifier.setInitialDate(widget.selectedDate);
    });
  }

  Future<void> save() => _save();

  Future<void> _save() async {
    if (_saving) return;
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _saving = true);
    final saved = await ref.read(addNotaProvider.notifier).saveNota();
    if (!mounted) return;

    setState(() => _saving = false);
    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido guardar la nota.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addNotaProvider);
    final notifier = ref.read(addNotaProvider.notifier);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 10.h),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateLabel(state.startTime),
                style: TextStyle(fontSize: 13.sp, color: color.withOpacity(.58)),
              ),
              SizedBox(height: 12.h),
              _field(
                controller: notifier.title,
                label: 'Título',
                hint: '¿Qué quieres recordar?',
                icon: Icons.title_rounded,
              ),
              SizedBox(height: 10.h),
              _field(
                controller: notifier.site,
                label: 'Ubicación',
                hint: 'Opcional',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 10.h),
              _field(
                controller: notifier.notes,
                label: 'Observaciones',
                hint: 'Añade una descripción',
                icon: Icons.notes_rounded,
                maxLines: 4,
              ),
              SizedBox(height: 14.h),
              _sectionTitle('Fecha y hora'),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _choiceTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Inicio',
                      value: _dateLabel(state.startTime),
                      onTap: () => _pickStartDate(notifier, state.startTime),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _choiceTile(
                      icon: Icons.schedule_rounded,
                      label: 'Hora',
                      value: _timeLabel(state.startTime),
                      onTap: () => _pickStartTime(notifier, state.startTime),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _choiceTile(
                      icon: Icons.event_available_rounded,
                      label: 'Fin',
                      value: _dateLabel(state.endTime),
                      onTap: () => _pickEndDate(notifier, state.endTime),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _choiceTile(
                      icon: Icons.schedule_rounded,
                      label: 'Hora fin',
                      value: _timeLabel(state.endTime),
                      onTap: () => _pickEndTime(notifier, state.endTime),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _optionTile(
                icon: state.isImportant ? Icons.flag_rounded : Icons.outlined_flag,
                title: 'Importante',
                trailing: Switch.adaptive(
                  value: state.isImportant,
                  onChanged: notifier.setImportant,
                ),
                onTap: notifier.toggleImportant,
              ),
              SizedBox(height: 8.h),
              _optionTile(
                icon: Icons.notifications_none_rounded,
                title: 'Recordatorio',
                subtitle: state.alarmaCreada ? state.alarmaHora : 'Sin recordatorio',
                trailing: Icon(Icons.chevron_right_rounded, color: color.withOpacity(.55)),
                onTap: () => _pickReminder(notifier, state.startTime),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 3.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textColor.withOpacity(.72)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(.48),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35)),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(13.w, maxLines > 1 ? 14.h : 0, 0, 0),
                child: Icon(icon, size: 20.sp, color: PRIMARY_COLOR.withOpacity(.9)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  minLines: maxLines > 1 ? 3 : 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 14.sp, color: textColor),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(fontSize: 13.sp, color: textColor.withOpacity(.42)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: maxLines > 1 ? 12.h : 14.h),
                  ),
                ),
              ),
              SizedBox(width: 13.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(.72)),
    );
  }

  Widget _choiceTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.55),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: PRIMARY_COLOR),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 11.sp)),
                    SizedBox(height: 2.h),
                    Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.55),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Row(
            children: [
              Icon(icon, color: PRIMARY_COLOR),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Text(subtitle, style: TextStyle(fontSize: 12.sp, color: color.withOpacity(.55))),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate(AddNotaNotifier notifier, DateTime current) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (!mounted || selected == null) return;
    notifier.setStartTime(DateTime(selected.year, selected.month, selected.day, current.hour, current.minute));
  }

  Future<void> _pickStartTime(AddNotaNotifier notifier, DateTime current) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted || selected == null) return;
    notifier.setStartTime(DateTime(current.year, current.month, current.day, selected.hour, selected.minute));
  }

  Future<void> _pickEndDate(AddNotaNotifier notifier, DateTime current) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (!mounted || selected == null) return;
    notifier.setEndDate(selected);
  }

  Future<void> _pickEndTime(AddNotaNotifier notifier, DateTime current) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted || selected == null) return;
    notifier.setEndClock(selected);
  }

  Future<void> _pickReminder(AddNotaNotifier notifier, DateTime start) async {
    if (ref.read(addNotaProvider).alarmaCreada) {
      notifier.setAlarmaCreada(false);
      notifier.setAlarmaActivadaString('Sin recordatorio');
      return;
    }

    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(start),
    );
    if (!mounted || selected == null) return;

    final reminder = DateTime(start.year, start.month, start.day, selected.hour, selected.minute);
    notifier.setAlarmaTime(reminder);
    notifier.setAlarmaCreada(true);
    notifier.setAlarmaActivadaString(reminder.hour.toString().padLeft(2, '0') + ':' + reminder.minute.toString().padLeft(2, '0'));
  }

  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _timeLabel(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
