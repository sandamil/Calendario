import 'dart:developer';
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
                          .subtract(Duration(days: 200, hours: 23)),
                      lastDay: DateTime.now()
                          .add(const Duration(days: 600, hours: 23)),
                      focusedDay: calendarController.focusedDay,
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

                      ///=======================================================Calendar builders
                      ///

                      calendarBuilders: CalendarBuilders(
                        holidayBuilder: (context, day, focusDay) {
                          final events = calendarController.getEventsOfDay(day);
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                border: Border.all(
                                    width: 1, color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  children: [
                                    Text(
                                      day.day.toString(),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: events
                                              .map(
                                                (event) => GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 5),
                                                    height: 20,
                                                    width: double.maxFinite,
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Align(
                                                      child: Text(
                                                        event.title!,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        defaultBuilder: (context, day, focusedDay) =>
                            DayBuilderWidget(date: day, dayType: ''),
                        selectedBuilder: (context, day, focusedDay) =>
                            DayBuilderWidget(date: day, dayType: 'selected'),
                        todayBuilder: (context, day, events) =>
                            DayBuilderWidget(date: day, dayType: 'today'),
                        // holidayBuilder: (context, day, events) =>
                        //     DayBuilderWidget(date: day, dayType: 'holiday'),
                        outsideBuilder: (context, date, events) =>
                            DayBuilderWidget(date: date, dayType: 'outside'),
                        markerBuilder: (context, day, events) =>
                            MarkerBuilderWidget(
                          day: day,
                          events: events,
                        ),
                        dowBuilder: (context, day) {
                          if (day.weekday == DateTime.sunday ||
                              day.weekday == DateTime.saturday) {
                            final text = DateFormat.E('es').format(day);
                            return Center(
                              child: Text(
                                text.toUpperCase(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else {
                            final text = DateFormat.E('es').format(day);
                            return Center(
                              child: Text(
                                text.toUpperCase(),
                                style:
                                    const TextStyle(color: Colors.orangeAccent),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  : const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}
