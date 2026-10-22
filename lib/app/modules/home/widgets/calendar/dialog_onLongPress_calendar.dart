import 'package:calendario2/app/modules/home/widgets/calendar/calendar_add_note_sheet.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/customAlertDialogDaySelected.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'dialog_addTurnosTo_calendar.dart';
import 'turnos_notas_onHomeDialog.dart';

class OnLongPressDialog extends StatefulWidget {
  const OnLongPressDialog({
    required this.selectedDate,
    required this.getCuadrante,
    required this.tapPosition,
    super.key,
  });

  final DateTime selectedDate;
  final Offset tapPosition;
  final Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;

  @override
  State<OnLongPressDialog> createState() => _OnLongPressDialogState();
}

class _OnLongPressDialogState extends State<OnLongPressDialog> {
  Future<void> _openAddShift() async {
    Navigator.of(context).pop();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CalendarActionSheet(
          title: 'Añadir turno',
          icon: Icons.work_history_rounded,
          child: AddTurnostoCalendar(
            selectedDate: widget.selectedDate,
            getCuadrante: widget.getCuadrante,
          ),
        );
      },
    );
  }

  Future<void> _openAddNote() async {
    Navigator.of(context).pop();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _CalendarActionSheet extends StatelessWidget {
  const _CalendarActionSheet({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: PRIMARY_COLOR.withOpacity(.12),
                    child: Icon(icon, color: PRIMARY_COLOR, size: 21.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
