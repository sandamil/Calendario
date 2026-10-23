import 'package:calendario2/app/modules/home/widgets/calendar/calendar_add_note_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'dialog_addTurnosTo_calendar.dart';
import 'turnos_notas_onHomeDialog.dart';

class CalendarDaySheet extends StatelessWidget {
  const CalendarDaySheet({
    required this.selectedDate,
    required this.getCuadrante,
    required this.arrowX,
    required this.pointerOnTop,
    super.key,
  });

  final DateTime selectedDate;
  final Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;
  final double arrowX;
  final bool pointerOnTop;

  String _weekday(DateTime date) {
    const days = <String>['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[date.weekday - 1];
  }

  String _month(DateTime date) {
    const months = <String>['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
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
        child: AddTurnostoCalendar(selectedDate: selectedDate, getCuadrante: getCuadrante),
      ),
    );
  }

  Future<void> _openAddNote(BuildContext context) async {
    Navigator.of(context).pop();
    final noteKey = GlobalKey<CalendarAddNoteSheetState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarSheetFrame(
        title: 'Nueva nota',
        centerTitle: true,
        leading: TextButton(
          onPressed: () => noteKey.currentState?.save(),
          style: TextButton.styleFrom(
            foregroundColor: PRIMARY_COLOR,
            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            minimumSize: Size(0, 34.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: const Text('Añadir'),
        ),
        child: CalendarAddNoteSheet(
          key: noteKey,
          selectedDate: selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    const pointerHeight = 10.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: widgetPointerTop(pointerOnTop, pointerHeight),
            bottom: widgetPointerTop(!pointerOnTop, pointerHeight),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Material(
              color: theme.scaffoldBackgroundColor,
              elevation: 18,
              shadowColor: Colors.black.withOpacity(.25),
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(24.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 390.w,
                  maxHeight: MediaQuery.sizeOf(context).height * .68,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42.w,
                              height: 42.w,
                              decoration: BoxDecoration(color: PRIMARY_COLOR.withOpacity(.11), borderRadius: BorderRadius.circular(13.r)),
                              alignment: Alignment.center,
                              child: Text('${selectedDate.day}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: PRIMARY_COLOR)),
                            ),
                            SizedBox(width: 11.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${selectedDate.day} de ${_month(selectedDate)}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: onSurface)),
                                  SizedBox(height: 1.h),
                                  Text('${_weekday(selectedDate)} · ${selectedDate.year}', style: TextStyle(fontSize: 12.sp, color: onSurface.withOpacity(.58))),
                                ],
                              ),
                            ),
                            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded), tooltip: 'Cerrar'),
                          ],
                        ),
                        SizedBox(height: 9.h),
                        ClipRRect(borderRadius: BorderRadius.circular(14.r), child: const TurnosNotasOnHomeDialog()),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(child: _ActionTile(icon: Icons.add_rounded, title: 'Añadir turno', onTap: () => _openAddShift(context))),
                            SizedBox(width: 8.w),
                            Expanded(child: _ActionTile(icon: Icons.note_add_outlined, title: 'Añadir nota', onTap: () => _openAddNote(context))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: arrowX - 11.w,
          top: pointerOnTop ? 0 : null,
          bottom: pointerOnTop ? null : 0,
          child: CustomPaint(
            size: Size(22.w, pointerHeight.h),
            painter: _BubblePointerPainter(color: theme.scaffoldBackgroundColor, pointDown: !pointerOnTop),
          ),
        ),
      ],
    );
  }
}

double widgetPointerTop(bool include, double height) => include ? height.h : 0;

class _BubblePointerPainter extends CustomPainter {
  const _BubblePointerPainter({required this.color, required this.pointDown});

  final Color color;
  final bool pointDown;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointDown) {
      path..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close();
    } else {
      path..moveTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width / 2, 0)..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubblePointerPainter oldDelegate) => oldDelegate.color != color || oldDelegate.pointDown != pointDown;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(.65),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Column(
            children: [
              Icon(icon, color: PRIMARY_COLOR, size: 24.sp),
              SizedBox(height: 5.h),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
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
    required this.child,
    this.icon,
    this.leading,
    this.centerTitle = false,
  });

  final String title;
  final IconData? icon;
  final Widget? leading;
  final bool centerTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * .92;
    return Material(
      color: theme.scaffoldBackgroundColor,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(.2), borderRadius: BorderRadius.circular(20.r)),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 42.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: leading ??
                              (icon == null
                                  ? const SizedBox.shrink()
                                  : CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: PRIMARY_COLOR.withOpacity(.12),
                                      child: Icon(icon, color: PRIMARY_COLOR, size: 21.sp),
                                    )),
                        ),
                        Center(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Cerrar',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
