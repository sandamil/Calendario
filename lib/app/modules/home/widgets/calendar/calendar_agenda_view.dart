import 'package:calendario2/app/modules/home/widgets/calendar/calendar_add_note_sheet.dart';
import 'package:flutter/material.dart';

import '../../../../components/ad_banner_slot.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/cuadranteDay.dart';
import '../../../../data/model/taskModel.dart';
import '../../../notas/views/widgets/taskCard.dart';
import '../../providers/calendar_providers.dart';
import '../../utils/shift_conflict_dialog.dart';
import 'calendar_shift_editor_sheet.dart';
import 'dialog_addTurnosTo_calendar.dart';

class CalendarAgendaView extends ConsumerWidget {
  const CalendarAgendaView({
    this.scrollController,
    this.showAddActions = true,
    super.key,
  });

  final ScrollController? scrollController;
  final bool showAddActions;

  Future<void> _reload(WidgetRef ref, DateTime date) async {
    await ref.read(cuadranteMapProvider.notifier).reload();
    ref
        .read(selectedDayTurnosProvider.notifier)
        .setTurnos(getTurnosOfDayFromMap(date, ref.read(cuadranteMapProvider)));
  }

  List<CuadranteDay> _nearbyShifts(WidgetRef ref, DateTime date) => ref
      .read(cuadranteMapProvider)
      .entries
      .where((entry) {
        final day = DateTime(entry.key.year, entry.key.month, entry.key.day);
        final base = DateTime(date.year, date.month, date.day);
        return !day.isBefore(base.subtract(const Duration(days: 1))) &&
            !day.isAfter(base.add(const Duration(days: 1)));
      })
      .expand((entry) => entry.value)
      .toList();

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    CuadranteDay shift,
    DateTime selectedDate,
  ) async {
    final edited = await showModalBottomSheet<CuadranteDay>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarShiftEditorSheet(shift: shift),
    );
    if (edited == null || !context.mounted) return;
    await ref.read(cuadranteMapProvider.notifier).reload();
    if (!context.mounted) return;
    final allowed = await confirmShiftConflicts(
      context,
      candidate: edited,
      existing: _nearbyShifts(ref, selectedDate),
      ignoreId: shift.id,
    );
    if (!allowed || !context.mounted) return;
    try {
      await CalendarioDB.db.updateItem(edited);
      await _reload(ref, selectedDate);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo editar el turno: $error')),
      );
    }
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    CuadranteDay shift,
    DateTime selectedDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: shift.dateTime ?? selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      helpText: 'Selecciona el nuevo día',
      confirmText: 'Mover turno',
    );
    if (date == null || !context.mounted) return;
    await ref.read(cuadranteMapProvider.notifier).reload();
    if (!context.mounted) return;
    final moved = _copyWithDate(shift, date, keepId: true);
    final allowed = await confirmShiftConflicts(
      context,
      candidate: moved,
      existing: _nearbyShifts(ref, date),
      ignoreId: shift.id,
    );
    if (!allowed || !context.mounted) return;
    try {
      await CalendarioDB.db.updateItem(moved);
      await _reload(ref, date);
      ref.read(selectedDayProvider.notifier).setSelectedDay(date);
      ref.read(focusedMonthProvider.notifier).setFocusedDay(date);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo mover el turno: $error')),
      );
    }
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    CuadranteDay shift,
    DateTime selectedDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.add(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      helpText: 'Selecciona dónde copiar el turno',
      confirmText: 'Copiar turno',
    );
    if (date == null || !context.mounted) return;
    await ref.read(cuadranteMapProvider.notifier).reload();
    if (!context.mounted) return;
    final copy = _copyWithDate(shift, date, keepId: false);
    final allowed = await confirmShiftConflicts(
      context,
      candidate: copy,
      existing: _nearbyShifts(ref, date),
    );
    if (!allowed || !context.mounted) return;
    try {
      await CalendarioDB.db.addCuadranteItem(copy);
      await _reload(ref, date);
      ref.read(selectedDayProvider.notifier).setSelectedDay(date);
      ref.read(focusedMonthProvider.notifier).setFocusedDay(date);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo copiar el turno: $error')),
      );
    }
  }

  Future<void> _swap(
    BuildContext context,
    WidgetRef ref,
    CuadranteDay shift,
    DateTime selectedDate,
  ) async {
    final targetDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.add(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      helpText: 'Selecciona el día con el que intercambiar',
      confirmText: 'Continuar',
    );
    if (targetDate == null || !context.mounted) return;
    if (targetDate.year == selectedDate.year &&
        targetDate.month == selectedDate.month &&
        targetDate.day == selectedDate.day) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige un día distinto para intercambiar.'),
        ),
      );
      return;
    }
    await ref.read(cuadranteMapProvider.notifier).reload();
    if (!context.mounted) return;
    final targetShifts = getTurnosOfDayFromMap(
      targetDate,
      ref.read(cuadranteMapProvider),
    );
    if (targetShifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ese día no tiene turnos para intercambiar.'),
        ),
      );
      return;
    }
    final selected = await showDialog<CuadranteDay>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('¿Con qué turno quieres intercambiar?'),
        children: [
          for (final option in targetShifts)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Text(
                '${option.description ?? option.title ?? 'Turno'} · ${option.startHour ?? '--:--'}–${option.endHour ?? '--:--'}',
              ),
            ),
          const AdBannerSlot(),
        ],
      ),
    );
    if (selected == null ||
        shift.id == null ||
        selected.id == null ||
        !context.mounted) {
      return;
    }

    final existing = ref
        .read(cuadranteMapProvider)
        .values
        .expand((items) => items)
        .where((item) => item.id != shift.id && item.id != selected.id)
        .toList();
    final firstMoved = _copyWithDate(shift, targetDate, keepId: true);
    final secondMoved = _copyWithDate(selected, selectedDate, keepId: true);
    final firstAllowed = await confirmShiftConflicts(
      context,
      candidate: firstMoved,
      existing: existing,
    );
    if (!firstAllowed || !context.mounted) return;
    final secondAllowed = await confirmShiftConflicts(
      context,
      candidate: secondMoved,
      existing: existing,
    );
    if (!secondAllowed || !context.mounted) return;
    try {
      await CalendarioDB.db.swapCuadranteItemDates(shift.id!, selected.id!);
      await _reload(ref, selectedDate);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron intercambiar los turnos: $error'),
        ),
      );
    }
  }

  Future<void> _repeat(
    BuildContext context,
    WidgetRef ref,
    CuadranteDay shift,
    DateTime selectedDate,
  ) async {
    final startDate = shift.dateTime ?? selectedDate;
    final endDate = await showDatePicker(
      context: context,
      initialDate: startDate.add(const Duration(days: 28)),
      firstDate: startDate.add(const Duration(days: 1)),
      lastDate: DateTime(2050),
      helpText: 'Repetir hasta qué fecha',
      confirmText: 'Siguiente',
    );
    if (endDate == null || !context.mounted) return;
    final interval = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Frecuencia de repetición'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(1),
            child: const Text('Todos los días'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(7),
            child: const Text('Cada semana'),
          ),
          const AdBannerSlot(),
        ],
      ),
    );
    if (interval == null || !context.mounted) return;

    final copies = <CuadranteDay>[];
    for (
      var date = startDate.add(Duration(days: interval));
      !date.isAfter(endDate);
      date = date.add(Duration(days: interval))
    ) {
      copies.add(_copyWithDate(shift, date, keepId: false));
      if (copies.length > 180) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La repetición supera el límite de 180 turnos. Elige una fecha final más cercana.',
            ),
          ),
        );
        return;
      }
    }
    if (copies.isEmpty) return;
    await ref.read(cuadranteMapProvider.notifier).reload();
    if (!context.mounted) return;
    final firstDate = copies.first.dateTime!;
    final lastDate = copies.last.dateTime!;
    final lowerBound = DateTime(
      firstDate.year,
      firstDate.month,
      firstDate.day,
    ).subtract(const Duration(days: 1));
    final upperBound = DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    ).add(const Duration(days: 1));
    final existing = ref
        .read(cuadranteMapProvider)
        .entries
        .where((entry) {
          final date = DateTime(entry.key.year, entry.key.month, entry.key.day);
          return !date.isBefore(lowerBound) && !date.isAfter(upperBound);
        })
        .expand((entry) => entry.value);
    final allowed = await confirmShiftBatchConflicts(
      context,
      candidates: copies,
      existing: existing,
    );
    if (!allowed || !context.mounted) return;
    try {
      await CalendarioDB.db.addCuadranteItems(copies);
      await _reload(ref, selectedDate);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copies.length == 1
                ? '1 repetición creada.'
                : '${copies.length} repeticiones creadas.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron crear las repeticiones: $error'),
        ),
      );
    }
  }

  CuadranteDay _copyWithDate(
    CuadranteDay shift,
    DateTime date, {
    required bool keepId,
  }) => CuadranteDay(
    id: keepId ? shift.id : null,
    cuadranteName: shift.cuadranteName,
    title: shift.title,
    description: shift.description,
    startHour: shift.startHour,
    endHour: shift.endHour,
    color: shift.color,
    dateTime: DateTime(date.year, date.month, date.day),
  );

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CuadranteDay shift,
    DateTime selectedDate,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar turno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Eliminar ${shift.description ?? shift.title ?? 'este turno'} de este día?',
            ),
            const AdBannerSlot(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true || shift.id == null || !context.mounted) return;
    try {
      await CalendarioDB.db.deleteItemID(shift.id!);
      await _reload(ref, selectedDate);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el turno: $error')),
      );
    }
  }

  Future<void> _addShift(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AddTurnostoCalendar(
                  selectedDate: date,
                  getCuadrante: ref
                      .read(cuadranteMapProvider.notifier)
                      .reload()
                      .then((_) => ref.read(cuadranteMapProvider)),
                ),
                const AdBannerSlot(),
              ],
            ),
          ),
        ),
      ),
    );
    await _reload(ref, date);
  }

  Future<void> _addNote(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    final noteKey = GlobalKey<CalendarAddNoteSheetState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .92,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 4.h),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Nueva nota',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => noteKey.currentState?.save(),
                        child: const Text('Añadir'),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: CalendarAddNoteSheet(key: noteKey, selectedDate: date),
                ),
                const AdBannerSlot(),
              ],
            ),
          ),
        ),
      ),
    );
    await ref.read(notasProvider.notifier).reload();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selectedDate =
        ref.watch(selectedDayProvider) ?? ref.watch(focusedMonthProvider);
    final shifts = getTurnosOfDayFromMap(
      selectedDate,
      ref.watch(cuadranteMapProvider),
    )..sort((a, b) => (a.startHour ?? '').compareTo(b.startHour ?? ''));
    final notes =
        ref.watch(notasProvider).where((note) {
          final timestamp = note.startTimeMilliseconds;
          if (timestamp == null) return false;
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
        }).toList()..sort(
          (a, b) => (a.startTimeMilliseconds ?? 0).compareTo(
            b.startTimeMilliseconds ?? 0,
          ),
        );
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEEE d MMMM y', 'es_ES').format(selectedDate);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 5.h, 14.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel[0].toUpperCase() + dateLabel.substring(1),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${shifts.length} ${shifts.length == 1 ? 'turno' : 'turnos'} · ${notes.length} ${notes.length == 1 ? 'nota' : 'notas'}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: .6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showAddActions) ...[
                FilledButton.tonalIcon(
                  onPressed: () => _addShift(context, ref, selectedDate),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Turno'),
                ),
                SizedBox(width: 6.w),
                FilledButton.tonalIcon(
                  onPressed: () => _addNote(context, ref, selectedDate),
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Nota'),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: shifts.isEmpty && notes.isEmpty
              ? ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24.w),
                  children: [
                    SizedBox(
                      height: 150.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 42.sp,
                            color: theme.colorScheme.primary.withValues(
                              alpha: .65,
                            ),
                          ),
                          SizedBox(height: 9.h),
                          Text(
                            'Día libre de eventos',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Añade un turno o selecciona otro día.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: .6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(12.w, 3.h, 12.w, 16.h),
                  children: [
                    if (shifts.isNotEmpty) ...[
                      _AgendaSectionHeader(
                        title: 'TURNOS',
                        count: shifts.length,
                        icon: Icons.work_history_rounded,
                      ),
                      SizedBox(height: 7.h),
                      for (final shift in shifts)
                        _ShiftAgendaCard(
                          shift: shift,
                          onEdit: () =>
                              _edit(context, ref, shift, selectedDate),
                          onMove: () =>
                              _move(context, ref, shift, selectedDate),
                          onDuplicate: () =>
                              _duplicate(context, ref, shift, selectedDate),
                          onSwap: () =>
                              _swap(context, ref, shift, selectedDate),
                          onRepeat: () =>
                              _repeat(context, ref, shift, selectedDate),
                          onDelete: () =>
                              _delete(context, ref, shift, selectedDate),
                        ),
                    ],
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: shifts.isEmpty ? 0 : 10.h),
                      _AgendaSectionHeader(
                        title: 'NOTAS Y RECORDATORIOS',
                        count: notes.length,
                        icon: Icons.sticky_note_2_rounded,
                      ),
                      SizedBox(height: 7.h),
                      for (final note in notes)
                        TaskCard(
                          noteData: note,
                          onTapAction: (Task item) => context.push(
                            '/notas-view',
                            extra: {'id': item.id!, 'noteData': item},
                          ),
                          routeToNotas: false,
                          selectedDay: selectedDate,
                          focusedDay: ref.watch(focusedMonthProvider),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _AgendaSectionHeader extends StatelessWidget {
  const _AgendaSectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: .62);
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: .55,
            color: color,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: PRIMARY_COLOR,
          ),
        ),
      ],
    );
  }
}

class _ShiftAgendaCard extends StatelessWidget {
  const _ShiftAgendaCard({
    required this.shift,
    required this.onEdit,
    required this.onMove,
    required this.onDuplicate,
    required this.onSwap,
    required this.onRepeat,
    required this.onDelete,
  });

  final CuadranteDay shift;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDuplicate;
  final VoidCallback onSwap;
  final VoidCallback onRepeat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = HexColor(shift.color ?? '#607D8B');
    final foreground = color.computeLuminance() > .52
        ? Colors.black87
        : Colors.white;
    final start = shift.startHour ?? '--:--';
    final end = shift.endHour ?? '--:--';
    final overnight = start.compareTo(end) > 0;
    return Container(
      margin: EdgeInsets.only(bottom: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: color.withValues(alpha: .55)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(11.w, 9.h, 5.w, 9.h),
        child: Row(
          children: [
            Container(
              width: 5.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 39.w,
              height: 39.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Text(
                (shift.title ?? 'T').toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.description ?? 'Turno',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13.sp,
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: .6),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$start – $end',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: .68),
                        ),
                      ),
                      if (overnight) ...[
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.nights_stay_outlined,
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          '+1 día',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Acciones del turno',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'move') onMove();
                if (value == 'copy') onDuplicate();
                if (value == 'swap') onSwap();
                if (value == 'repeat') onRepeat();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem(
                  value: 'move',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.drive_file_move_outline),
                    title: Text('Mover a otro día'),
                  ),
                ),
                PopupMenuItem(
                  value: 'copy',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.copy_all_outlined),
                    title: Text('Duplicar en otro día'),
                  ),
                ),
                PopupMenuItem(
                  value: 'swap',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.swap_horiz_rounded),
                    title: Text('Intercambiar con otro día'),
                  ),
                ),
                PopupMenuItem(
                  value: 'repeat',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.repeat_rounded),
                    title: Text('Repetir turno…'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
