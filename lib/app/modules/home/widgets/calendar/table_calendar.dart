import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:intl/intl.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/customAlertDialogDaySelected.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/cuadranteDay.dart';
import '../../../../data/model/taskModel.dart';
import 'turnos_notas_onHomeDialog.dart';

class TableCalendarWidget extends ConsumerStatefulWidget {
  TableCalendarWidget(
      {super.key, this.onDaySelected, this.onDayTap});
  void Function(DateTime, DateTime)? onDaySelected;
  void Function(DateTime, DateTime, Offset)? onDayTap;

  @override
  ConsumerState<TableCalendarWidget> createState() =>
      _TableCalendarWidgetState();
}

class _TableCalendarWidgetState extends ConsumerState<TableCalendarWidget> {
  Offset _lastTapPosition = Offset.zero;
  PageController? _calendarPageController;
  double _horizontalDragDistance = 0;
  bool _horizontalPageChangeTriggered = false;

  Map<DateTime, List<CuadranteDay>>? _cachedCuadranteSource;
  List<Task>? _cachedNotasSource;
  Map<DateTime, List<CuadranteDay>> _cachedTurnosPorDia = {};
  Map<DateTime, List<Task>> _cachedNotasPorDia = {};

  void _actualizarIndices(
    Map<DateTime, List<CuadranteDay>> cuadranteMap,
    List<Task> notas,
  ) {
    if (!identical(_cachedCuadranteSource, cuadranteMap)) {
      final turnosPorDia = <DateTime, List<CuadranteDay>>{};

      for (final entry in cuadranteMap.entries) {
        final fecha = DateTime(
          entry.key.year,
          entry.key.month,
          entry.key.day,
        );
        turnosPorDia.putIfAbsent(fecha, () => <CuadranteDay>[]);
        turnosPorDia[fecha]!.addAll(entry.value);
      }

      _cachedCuadranteSource = cuadranteMap;
      _cachedTurnosPorDia = turnosPorDia;
    }

    if (!identical(_cachedNotasSource, notas)) {
      final notasPorDia = <DateTime, List<Task>>{};

      for (final nota in notas) {
        final timestamp = nota.startTimeMilliseconds;
        if (timestamp == null) continue;

        final fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final dia = DateTime(fecha.year, fecha.month, fecha.day);
        notasPorDia.putIfAbsent(dia, () => <Task>[]);
        notasPorDia[dia]!.add(nota);
      }

      _cachedNotasSource = notas;
      _cachedNotasPorDia = notasPorDia;
    }
  }

  void _onVerticalSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    final pageController = _calendarPageController;

    if (!mounted ||
        velocity == null ||
        velocity.abs() < 100 ||
        pageController == null ||
        !pageController.hasClients) {
      return;
    }

    // Deslizar hacia arriba avanza; hacia abajo retrocede.
    final delta = velocity < 0 ? 1 : -1;
    final focused = ref.read(focusedMonthProvider);
    final nextMonth = DateTime(focused.year, focused.month + delta, 1);

    if (nextMonth.isBefore(DateTime(2000, 1, 1)) ||
        nextMonth.isAfter(DateTime(2050, 12, 1))) {
      return;
    }

    final currentPage = pageController.page;
    if (currentPage == null) return;

    pageController.animateToPage(
      currentPage.round() + delta,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  // Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {
  //   calendarController.cuadrante.value =
  //       await CalendarioDB.db.getCuadranteList();
  //
  //   setState(() {
  //     calendarController.cuadranteMap.clear();
  //     for (CuadranteDay turno in calendarController.cuadrante) {
  //       calendarController.cuadranteMap
  //           .putIfAbsent(turno.dateTime!, () => <CuadranteDay>[]);
  //       List<CuadranteDay>? turnoData =
  //           calendarController.cuadranteMap[turno.dateTime];
  //       turnoData!.add(turno);
  //       calendarController.cuadranteMap.update(turno.dateTime!, (data) {
  //         return turnoData;
  //       });
  //     }
  //     calendarController.isReady.value = true;
  //   });
  //   return calendarController.cuadranteMap;
  // }

  void _onHorizontalSwipeUpdate(DragUpdateDetails details) {
    if (_horizontalPageChangeTriggered) return;

    _horizontalDragDistance += details.delta.dx;
    if (_horizontalDragDistance.abs() < 10) return;

    final pageController = _calendarPageController;
    if (pageController == null || !pageController.hasClients) return;

    final delta = _horizontalDragDistance < 0 ? 1 : -1;
    final focused = ref.read(focusedMonthProvider);
    final nextMonth = DateTime(focused.year, focused.month + delta, 1);

    if (nextMonth.isBefore(DateTime(2000, 1, 1)) ||
        nextMonth.isAfter(DateTime(2050, 12, 1))) {
      _horizontalPageChangeTriggered = true;
      return;
    }

    final currentPage = pageController.page;
    if (currentPage == null) return;

    // Solo se inicia un cambio por gesto.
    _horizontalPageChangeTriggered = true;

    pageController.animateToPage(
      currentPage.round() + delta,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cuadranteMap = ref.watch(cuadranteMapProvider);
    final notas = ref.watch(notasProvider);
    final selectedDay =
        ref.watch(selectedDayProvider) ?? ref.watch(focusedMonthProvider);

    // Recalcular los índices solo cuando Riverpod publica nuevos datos.
    _actualizarIndices(cuadranteMap, notas);
    final turnosPorDia = _cachedTurnosPorDia;
    final notasPorDia = _cachedNotasPorDia;

    return Listener(
      // Listener recibe la posición global al bajar el dedo, sin depender
      // de qué GestureDetector gane después la arena de gestos.
      onPointerDown: (event) {
        _lastTapPosition = event.position;
      },
      child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: _onVerticalSwipeEnd,
      onHorizontalDragStart: (_) {
        _horizontalDragDistance = 0;
        _horizontalPageChangeTriggered = false;
      },
      onHorizontalDragUpdate: _onHorizontalSwipeUpdate,
      child: TableCalendar(
        locale: 'es_ES',
        daysOfWeekHeight: 25.h,
        rowHeight: 96.h,
        headerVisible: false,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        ),
        holidayPredicate: (day) {
          final fecha = DateTime(day.year, day.month, day.day);
          return notasPorDia[fecha]?.isNotEmpty ?? false;
        },
        firstDay: DateTime(2000),
        lastDay: DateTime(2050),
        focusedDay: ref.watch(focusedMonthProvider),
        // calendarFormat: controller.calendarFormat,
        eventLoader: (day) {
          final fecha = DateTime(day.year, day.month, day.day);
          return turnosPorDia[fecha] ?? const <CuadranteDay>[];
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        // El gesto vertical personalizado cambia de mes, no de formato.
        availableGestures: AvailableGestures.none,
        // selectedDayPredicate: (day) {
        //   return isSameDay(calendarController.selectedDayRx.value, day);
        // },
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),

        onDaySelected: (selectedDay, focusedDay) {
          widget.onDaySelected?.call(selectedDay, focusedDay);
          widget.onDayTap?.call(selectedDay, focusedDay, _lastTapPosition);
        },
        // onFormatChanged: (format) {
        //   if (controller.calendarFormat != format) {
        //     controller.changeCalendarFormat(format);
        //   }
        // },
        onCalendarCreated: (pageController) {
          _calendarPageController = pageController;
        },
        onPageChanged: (focusedDay) {
          ProviderScope.containerOf(context, listen: false)
              .read(focusedMonthProvider.notifier)
              .setFocusedDay(focusedDay);
        },
        calendarBuilders: _calendarBuilders(notasPorDia),
      ),
      ),
    );
  }

  _calendarBuilders(Map<DateTime, List<Task>> notasPorDia) => CalendarBuilders(
        /// =       markerBuilder:          =======================================

        markerBuilder: (context, day, List<CuadranteDay> events) {
          final fecha = DateTime(day.year, day.month, day.day);
          final notasDelDia = notasPorDia[fecha] ?? const <Task>[];
          return Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 25.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...events.map((turno) => Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.2.h, horizontal: 3.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor(turno.color!).withAlpha(42),
                            // border: Border.all(
                            //     color: HexColor(turno.color!), width: 1.h),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          height: 15.h,
                          child: Container(
                            alignment: Alignment.center,
                            height: 15,
                            width: double.maxFinite,
                            child: Text(
                              turno.title!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.2.h,
                                fontSize: 10.sp,
                                color: HexColor(turno.color!),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 3.h,
                  ),
                  ...notasDelDia.map((nota) => Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.5.h, horizontal: 1.w),
                        child: Container(
                            decoration: BoxDecoration(
                              color: MyColors.menuCardBackground,
                              // color: PRIMARY_COLOR_TRANSPARENTE,
                              // border: Border.all(
                              //     color: PRIMARY_COLOR_TRANSPARENTE, width: 1.h),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            height: 15.h,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                nota.title!.toUpperCase(),
                                maxLines: 1,
                                style: TextStyle(
                                    height: 1.h,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      )),
                ],
              ),
            ),
          );
        },

        ///==      holidayBuilder:         ========================================
        holidayBuilder: (context, day, focusedDay) {
          return Padding(
            padding: EdgeInsets.all(0.h),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.7.w,
                  color: MyColors.borderCellColor.withAlpha(150),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      day.day.toString(),
                      style: CustomTextStyle.numberCalendar.copyWith(
                        color: MyColors.cellTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },

        ///==      outsideBuilder:         ========================================
        // outsideBuilder: (context, date, events) =>
        //     DayBuilderWidget(date: date, dayType: 'outside'),

        ///==      defaultBuilder:         ========================================
        defaultBuilder: (context, day, focusedDay) {
          return Padding(
            padding: EdgeInsets.all(0.h),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: MyColors.cellColor,
                border: Border.all(
                  width: 0.7.w,
                  color: MyColors.borderCellColor.withAlpha(150),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      day.day.toString(),
                      style: CustomTextStyle.numberCalendar.copyWith(
                        color: MyColors.cellTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },

        ///==      selectedBuilder:         ========================================
        selectedBuilder: (context, day, focusedDay) {
          return Padding(
            padding: EdgeInsets.all(0.h),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.cellSelectedColor,
                // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                border: Border.all(
                  color: PRIMARY_COLOR,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  day.day.toString(),
                  style: CustomTextStyle.numberCalendar.copyWith(
                    fontSize: 15.sp,
                    color: MyColors.cellTextColor,
                  ),
                ),
              ),
            ),
          );
        },

        ///==      todayBuilder:         ========================================
        todayBuilder: (context, day, events) {
          return Padding(
            padding: EdgeInsets.all(0.h),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PRIMARY_COLOR.withAlpha(28),
                // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                border: Border.all(
                  color: PRIMARY_COLOR,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  day.day.toString(),
                  // textWidthBasis: TextWidthBasis.longestLine,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'FiraCode',
                    color: PRIMARY_COLOR,
                  ),
                ),
              ),
            ),
          );
        },

        ///==      dowBuilder:         ========================================
        dowBuilder: (context, day) {
          final text = DateFormat.E('es').format(day);
          if (day.weekday == DateTime.sunday
              // || day.weekday == DateTime.saturday
              ) {
            return Center(
              child: Text(
                text.toUpperCase(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return Center(
            child: Text(
              text.toUpperCase(),
              // style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );
}
