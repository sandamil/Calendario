import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../providers/calendar_providers.dart';

class SelectedDayWidget extends ConsumerWidget {
  const SelectedDayWidget({super.key});

  DateTime _shiftMonth(DateTime date, int delta) {
    final first = DateTime(date.year, date.month + delta, 1);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(
      first.year,
      first.month,
      date.day.clamp(1, lastDay).toInt(),
    );
  }

  DateTime _navigate(DateTime date, CalendarViewMode mode, int delta) {
    return switch (mode) {
      CalendarViewMode.month => _shiftMonth(date, delta),
      CalendarViewMode.week => date.add(Duration(days: 7 * delta)),
      CalendarViewMode.agenda => date.add(Duration(days: delta)),
    };
  }

  void _select(WidgetRef ref, DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    ref.read(focusedMonthProvider.notifier).setFocusedDay(normalized);
    ref.read(selectedDayProvider.notifier).setSelectedDay(normalized);
    ref
        .read(selectedDayTurnosProvider.notifier)
        .setTurnos(
          getTurnosOfDayFromMap(normalized, ref.read(cuadranteMapProvider)),
        );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime focused,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedDayProvider) ?? focused,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050, 12, 31),
      helpText: 'Ir a una fecha',
      cancelText: 'Cancelar',
      confirmText: 'Ir',
    );
    if (selected != null) _select(ref, selected);
  }

  String _title(DateTime focused, DateTime selected, CalendarViewMode mode) {
    if (mode == CalendarViewMode.agenda) {
      return DateFormat('d MMM y', 'es').format(selected);
    }
    if (mode == CalendarViewMode.week) {
      final start = focused.subtract(Duration(days: focused.weekday - 1));
      final end = start.add(const Duration(days: 6));
      if (start.month == end.month && start.year == end.year) {
        return '${start.day}–${end.day} ${DateFormat('MMM y', 'es').format(end)}';
      }
      return '${DateFormat('d MMM', 'es').format(start)} – ${DateFormat('d MMM y', 'es').format(end)}';
    }
    final month = DateFormat.MMMM('es').format(focused);
    final monthName = month.isEmpty
        ? ''
        : '${month[0].toUpperCase()}${month.substring(1)}';
    return '$monthName ${focused.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focused = ref.watch(focusedMonthProvider);
    final selected = ref.watch(selectedDayProvider) ?? focused;
    final mode = ref.watch(calendarViewModeProvider);
    final title = _title(focused, selected, mode);
    final unit = switch (mode) {
      CalendarViewMode.month => 'Mes',
      CalendarViewMode.week => 'Semana',
      CalendarViewMode.agenda => 'Día',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '$unit anterior',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 24.w, height: 36.h),
          onPressed: () => _select(ref, _navigate(selected, mode, -1)),
          icon: Icon(Icons.chevron_left_rounded, size: 19.sp),
        ),
        Flexible(
          child: TextButton(
            onPressed: () => _pickDate(context, ref, focused),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              minimumSize: Size(0, 36.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '$unit siguiente',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 24.w, height: 36.h),
          onPressed: () => _select(ref, _navigate(selected, mode, 1)),
          icon: Icon(Icons.chevron_right_rounded, size: 19.sp),
        ),
      ],
    );
  }
}
