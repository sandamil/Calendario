import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';

class AddTurnostoCalendar extends ConsumerStatefulWidget {
  const AddTurnostoCalendar({
    required this.selectedDate,
    required this.getCuadrante,
    super.key,
  });

  final DateTime selectedDate;
  final Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;

  @override
  ConsumerState<AddTurnostoCalendar> createState() =>
      _AddTurnostoCalendarState();
}

class _AddTurnostoCalendarState extends ConsumerState<AddTurnostoCalendar> {
  bool _adding = false;

  Future<void> _addTurno(dynamic turno) async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await CalendarioDB.db.addCuadranteItem(
        CuadranteDay(
          cuadranteName: 'Turnos sueltos',
          dateTime: DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
          ),
          color: turno.color,
          description: turno.description,
          endHour: turno.endHour,
          startHour: turno.startHour,
          title: turno.title,
        ),
      );

      final container = ProviderScope.containerOf(context, listen: false);
      await container.read(cuadranteMapProvider.notifier).reload();
      container
          .read(focusedMonthProvider.notifier)
          .setFocusedDay(widget.selectedDate);

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo añadir el turno: $error')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final turnosAsync = ref.watch(turnoTypesProvider);
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elige un tipo de turno',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Se añadirá al día seleccionado del calendario.',
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor.withValues(alpha: .58),
            ),
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 270.h),
            child: turnosAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    const Text('No se pudieron cargar los tipos de turno.'),
                    TextButton(
                      onPressed: () => ref.invalidate(turnoTypesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (turnos) {
                if (turnos.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Text(
                      'Todavía no has creado tipos de turno. Pulsa «Crear turno» para empezar.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: turnos.length,
                  separatorBuilder: (_, __) => SizedBox(height: 7.h),
                  itemBuilder: (context, index) {
                    final turno = turnos[index];
                    final color = HexColor(turno.color ?? '#607D8B');
                    final foreground =
                        color.computeLuminance() > .52 ? Colors.black87 : Colors.white;

                    return Material(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: _adding ? null : () => _addTurno(turno),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (turno.title ?? '').toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              SizedBox(width: 11.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      turno.description ?? 'Turno',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule_rounded,
                                            size: 13.sp,
                                            color: textColor.withValues(alpha: .6)),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${turno.startHour ?? '--:--'} – ${turno.endHour ?? '--:--'}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: textColor.withValues(alpha: .68),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.add_circle_rounded,
                                  color: PRIMARY_COLOR, size: 23.sp),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/add-turno'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear turno'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PRIMARY_COLOR,
                side: BorderSide(color: PRIMARY_COLOR.withValues(alpha: .55)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
