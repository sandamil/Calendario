import 'dart:developer';
import 'dart:math';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/app/modules/home/controllers/home_controller.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widget/day_builder.dart';
import 'widget/marker_builder.dart';

class CalendarWidget extends StatelessWidget {
  final calendarController = Get.put(CalendarController());

  CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Obx(
            () {
              return calendarController.isReady.value
                  ? TableCalendar(
                  onDayLongPressed: calendarController.onDaySelectedLongPress,
                      headerVisible: false,
                      locale: 'es_ES',
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                      holidayPredicate: (day) {
                        // print('comprobar refactor' '${calendarController.hasEvent(day)}'
                        // );
                        return calendarController.hasEvent(day);
                      },
                      weekendDays: const [DateTime.saturday, DateTime.sunday],
                      // enabledDayPredicate: (date) {
                      //   return (date.weekday != DateTime.sunday &&
                      //       date.weekday != DateTime.saturday);
                      // },
                      rowHeight: 90.h,
                      firstDay: DateTime.now()
                          .subtract(const Duration(days: 200, hours: 23)),
                      lastDay: DateTime.now()
                          .add(const Duration(days: 600, hours: 23)),
                      focusedDay: calendarController.focusedDay.value,
                      // calendarFormat: controller.calendarFormat,
                      eventLoader: calendarController.getEventForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) {
                        return isSameDay(
                            calendarController.selectedDay.value, day);
                      },
                      onDaySelected: calendarController.onDaySelected,
                      // onFormatChanged: (format) {
                      //   if (controller.calendarFormat != format) {
                      //     controller.changeCalendarFormat(format);
                      //   }
                      // },
                      onCalendarCreated: (_) async {
                        await calendarController.update;
                      },
                      onPageChanged: calendarController.onPageChanged,
                      calendarBuilders: _calendarBuilders())
                  : const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  /// ===        Calendar builders     ========================================

  _calendarBuilders() => CalendarBuilders(
        /// =       markerBuilder:          =======================================

        markerBuilder: (context, day, List<Cuadrante> events) {
          final notas = calendarController.getEventsOfDay(day);
          return Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 20.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...events.map((turno) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 3.w),
                    child: Container(
                          decoration: BoxDecoration(
                            color: HexColor(turno.color!).withAlpha(600),
                            border:
                                Border.all(color: HexColor(turno.color!), width: 1),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          height: 14.h,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(turno.title!.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: HexColor(turno.color!),
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                  )),
                  SizedBox(height: 3.h,),
                  ...notas.map((nota) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 3.w),
                        child: GestureDetector(
                          onTap: () {
                            print('tap');
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: PRIMARY_COLOR_TRANSPARENTE,
                                border:
                                    Border.all(color: PRIMARY_COLOR, width: 1),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              height: 14.h,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  nota.title!.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              )),
                        ),
                      )),
                ],
              ),
            ),
          );
        },
        ///==      holidayBuilder:         ========================================
        holidayBuilder: (context, day, focusedDay) {
          return Padding(
            padding: EdgeInsets.all(2.h),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(width: 1.w, color: MyColors.borderCellColor),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        // fontFamily: 'FiraCode',
                        // color: MyColors.cellTextColor,
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
            padding: EdgeInsets.all(2.h),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(width: 1.w, color: MyColors.borderCellColor),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        // fontFamily: 'FiraCode',
                        // color: MyColors.cellTextColor,
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
            padding: EdgeInsets.all(2.h),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.cellSelectedColor,
                // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                border: Border.all(
                  color: PRIMARY_COLOR,
                  width: 0.05.w,
                ),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'FiraCode',
                    // color: MyColors.cellTextColor,
                  ),
                ),
              ),
            ),
          );
        },

        ///==      todayBuilder:         ========================================
        todayBuilder: (context, day, events) {
          return Padding(
            padding: EdgeInsets.all(2.h),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.cellColor,
                // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                border: Border.all(
                  color: PRIMARY_COLOR,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(5.r),
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
          if (day.weekday == DateTime.sunday ||
              day.weekday == DateTime.saturday) {
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
