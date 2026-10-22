import 'package:calendario2/app/modules/home/widgets/calendar/calendar_add_note_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'dialog_addTurnosTo_calendar.dart';
import 'turnos_notas_onHomeDialog.dart';

class CalendarDaySheet extends StatelessWidget {
  const CalendarDaySheet({
    required this.selectedDate,
    required this.getCuadrante,
    super.key,
  });

  final DateTime selectedDate;
  final Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;

  String _weekday(DateTime date) {
    const days = <String>[
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[date.weekday - 1];
  }

  String _month(DateTime date) {
    const months = <String>[
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[date.month - 1];
  }

  Future<void> _openAddShift(BuildContext context) async {
    Navigator.of(context).pop();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarSheetFrame(
        title: 'Añadir turno',
        icon: Icons.work_history_rounded,
        child: AddTurnostoCalendar(
          selectedDate: selectedDate,
          getCuadrante: getCuadrante,
        ),
      ),
    );
  }

  Future<void> _openAddNote(BuildContext context) async {
    Navigator.of(context).pop();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarAddNoteSheet(selectedDate: selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedDate.day} de ${_month(selectedDate)}',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${_weekday(selectedDate)} · ${selectedDate.year}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: onSurface.withOpacity(.58),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: const TurnosNotasOnHomeDialog(),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.add_rounded,
                      title: 'Añadir turno',
                      onTap: () => _openAddShift(context),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.note_add_outlined,
                      title: 'Añadir nota',
                      onTap: () => _openAddNote(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(.65),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 10.w),
          child: Column(
            children: [
              Icon(icon, color: PRIMARY_COLOR, size: 25.sp),
              SizedBox(height: 6.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarSheetFrame extends StatelessWidget {
  const _CalendarSheetFrame({
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
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
              SizedBox(height: 8.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
