import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SelectedDayWidget extends ConsumerWidget {
  const SelectedDayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedMonth = ref.watch(focusedMonthProvider);
    final monthLabel = DateFormat.MMMM('es').format(focusedMonth);
    final title = monthLabel.isEmpty
        ? DateFormat.y('es').format(focusedMonth)
        : '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)} ${focusedMonth.year}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 21.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
