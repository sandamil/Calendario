import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/calendar_providers.dart';

class CalendarViewModeSelector extends ConsumerWidget {
  const CalendarViewModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(calendarViewModeProvider);
    final theme = Theme.of(context);
    final next = switch (mode) {
      CalendarViewMode.month => CalendarViewMode.week,
      CalendarViewMode.week => CalendarViewMode.agenda,
      CalendarViewMode.agenda => CalendarViewMode.month,
    };
    final label = switch (mode) {
      CalendarViewMode.month => 'Mes',
      CalendarViewMode.week => 'Semana',
      CalendarViewMode.agenda => 'Agenda',
    };
    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 2.w),
      child: Tooltip(
        message: 'Cambiar vista (ahora: $label)',
        child: OutlinedButton(
          onPressed: () =>
              ref.read(calendarViewModeProvider.notifier).setMode(next),
          child: Text(label, maxLines: 1),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: .10),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: .45),
              width: 1,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            minimumSize: Size(0, 34.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ),
    );
  }
}
