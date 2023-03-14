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


class CalendarBoxWidget extends StatefulWidget {
  const CalendarBoxWidget({super.key, });
  // final Map<DateTime, List<dynamic>> periods;

  @override
  State<CalendarBoxWidget> createState() => _CalendarBoxWidgetState();
}

class _CalendarBoxWidgetState extends State<CalendarBoxWidget> {
  Map<String, List> mySelectedEvents = {};

  @override
  Widget build(BuildContext context) {
    final calendarController = Get.put(CalendarController());
    final homeController = Get.put(HomeController());
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Obx(() {
          return homeController.isReady.value
              ? TableCalendar(
            // pageJumpingEnabled: true,
            // pageAnimationEnabled: false,
            locale: 'es_ES',
            weekendDays: const [DateTime.saturday, DateTime.sunday],
            // enabledDayPredicate: (date) {
            //   return (date.weekday != DateTime.sunday &&
            //       date.weekday != DateTime.saturday);
            // },
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 600, hours: 23)),
            focusedDay: calendarController.focusedDay,
            // calendarFormat: controller.calendarFormat,
            eventLoader: calendarController.getEventForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(calendarController.selectedDay, day);
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
            onPageChanged: (focusedDay) {
              calendarController.focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              markersAlignment: Alignment.bottomRight,
              outsideDaysVisible: false,
              canMarkersOverflow: true,
              todayTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
                // color: HelperTheme.primary
              ),
              selectedTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                // color: HelperTheme.white
              ),
            ),
            headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  // color: HelperTheme.black
                )),

            ///=======================================================Calendar builders
            ///

            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    // color: HelperTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    // style: const TextStyle(
                    //     color: HelperTheme.black
                    // ),
                  )),
              todayBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    // color: HelperTheme.warning,
                      shape: BoxShape.circle),
                  child: Text(
                    date.day.toString(),
                    // style: const TextStyle(
                    //     color: HelperTheme.black
                    // ),
                  )),

              ///=======================================================   markerBuilder
              ///
              markerBuilder: (context, day, List<Cuadrante> events) {
                return events.isNotEmpty
                    ? Container(
                    margin: const EdgeInsets.all(1.0),
                    //   padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: events != null
                          ? HexColor(events[0].color!).withAlpha(600)
                          : Theme.of(context).highlightColor,
                      border: events != null
                          ? Border.all(
                          color: HexColor(events[0].color!),
                          width: 1)
                          : null,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    width: 100,
                    height: 100,
                    //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                    child: Container(
                      child: events[0].title != null
                          ? Stack(
                        children: <Widget>[
                          Positioned.fill(
                            bottom: 0.0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                  events[0]
                                      .title!
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: HexColor(
                                          events[0].color!),
                                      fontWeight:
                                      FontWeight.w700)),
                            ),
                          )
                        ],
                      )
                          : null,
                    ))
                    : Container();
              },

              dowBuilder: (context, day) {
                if (day.weekday == DateTime.sunday ||
                    day.weekday == DateTime.saturday) {
                  final text = DateFormat.E('es').format(day);
                  return Center(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return null;
              },
            ),
          )




              : Center(child: CircularProgressIndicator());



        },),
      ),
    );
  }
}
