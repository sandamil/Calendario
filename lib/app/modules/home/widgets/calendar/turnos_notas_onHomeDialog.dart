import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../components/custom_dialog.dart';
import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';

class TurnosNotasOnHomeDialog extends ConsumerStatefulWidget {
  const TurnosNotasOnHomeDialog({super.key});

  @override
  ConsumerState<TurnosNotasOnHomeDialog> createState() =>
      _TurnosNotasOnHomeDialogState();
}

class _TurnosNotasOnHomeDialogState
    extends ConsumerState<TurnosNotasOnHomeDialog> {
  Future<void> _reloadCuadrante(DateTime selectedDate) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(cuadranteMapProvider.notifier).reload();
    container
        .read(focusedMonthProvider.notifier)
        .setFocusedDay(selectedDate);
  }

  Future<void> _deleteTurno(int? id, DateTime? selectedDate) async {
    if (id == null || selectedDate == null) return;
    await CalendarioDB.db.deleteItemID(id);
    await _reloadCuadrante(selectedDate);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final turnos = ref.watch(selectedDayTurnosProvider);
    final notas = ref.watch(notasProvider);
    final selectedDate = ref.watch(selectedDayProvider);
    final selectedDayNotas = selectedDate == null
        ? const []
        : ref.read(notasProvider.notifier).getNotasOfDay(selectedDate);
    final surface = theme.colorScheme.surfaceContainerHighest.withValues(alpha: .48);
    final textColor = theme.colorScheme.onSurface;

    if (turnos.isEmpty && selectedDayNotas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Icon(Icons.event_available_rounded,
                size: 28.sp, color: PRIMARY_COLOR.withValues(alpha: .8)),
            SizedBox(height: 6.h),
            Text(
              'No hay turnos ni notas para este día',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: textColor.withValues(alpha: .65),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 210.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (turnos.isNotEmpty) ...[
              _SectionLabel(
                icon: Icons.work_history_outlined,
                title: 'Turnos',
                count: turnos.length,
              ),
              SizedBox(height: 5.h),
              ...turnos.map((turno) {
                final turnoColor = HexColor(turno.color ?? '#607D8B');
                final foreground =
                    turnoColor.computeLuminance() > .52 ? Colors.black87 : Colors.white;
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Slidable(
                    key: ValueKey('turno-${turno.id}'),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: .28,
                      children: [
                        SlidableAction(
                          label: 'Eliminar',
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          icon: Icons.delete_outline_rounded,
                          onPressed: (_) => _deleteTurno(turno.id, selectedDate),
                        ),
                      ],
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: turnoColor.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: turnoColor.withValues(alpha: .6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 34.h,
                            decoration: BoxDecoration(
                              color: turnoColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          SizedBox(width: 9.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  turno.description ?? turno.title ?? 'Turno',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (turno.startHour != null && turno.endHour != null) ...[
                                  SizedBox(height: 3.h),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded,
                                          size: 13.sp,
                                          color: textColor.withValues(alpha: .65)),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${turno.startHour} – ${turno.endHour}',
                                        style: TextStyle(
                                          color: textColor.withValues(alpha: .7),
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.drag_indicator_rounded,
                              size: 18.sp, color: foreground.withValues(alpha: .65)),
                          Icon(Icons.chevron_left_rounded,
                              size: 18.sp, color: textColor.withValues(alpha: .5)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            if (selectedDayNotas.isNotEmpty) ...[
              if (turnos.isNotEmpty) SizedBox(height: 4.h),
              _SectionLabel(
                icon: Icons.sticky_note_2_outlined,
                title: 'Notas',
                count: selectedDayNotas.length,
              ),
              SizedBox(height: 5.h),
              ...selectedDayNotas.map((nota) {
                final start = nota.startTimeMilliseconds == null
                    ? null
                    : DateTime.fromMillisecondsSinceEpoch(
                        nota.startTimeMilliseconds!);
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Material(
                    color: surface,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => MyCustomDialog.mostrarTask(nota, context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34.w,
                              height: 34.w,
                              decoration: BoxDecoration(
                                color: PRIMARY_COLOR.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                nota.isImportant == true
                                    ? Icons.star_rounded
                                    : Icons.notes_rounded,
                                color: PRIMARY_COLOR,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 9.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nota.title?.trim().isNotEmpty == true
                                        ? nota.title!
                                        : 'Nota sin título',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  if ((nota.notes ?? '').trim().isNotEmpty) ...[
                                    SizedBox(height: 3.h),
                                    Text(
                                      nota.notes!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: textColor.withValues(alpha: .66),
                                      ),
                                    ),
                                  ],
                                  if (start != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      start.formatDateTime24H,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: PRIMARY_COLOR,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: textColor.withValues(alpha: .45)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: .65);
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
        SizedBox(width: 5.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: PRIMARY_COLOR.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 10.sp,
              color: PRIMARY_COLOR,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
