import 'dart:collection';

import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../../config/util/hexColor.dart';
import 'calendar_logic.dart';

class CalendarPage extends GetView<CalendarLogic> {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarLogic>(
        init: CalendarLogic(),
        initState: (controller) {},
        builder: (controller) {
          return Scaffold(
              // backgroundColor: HelperTheme.white,
              // appBar: AppBar(
              // leading: IconButton(icon: Icon(Icons.connected_tv_sharp) , onPressed: () { _onChangeDate; },),
              //   // backgroundColor: HelperTheme.primary,
              // ),
              body: Column(children: [
            TableCalendar(
              locale: 'es_PE',
              weekendDays: const [DateTime.saturday, DateTime.sunday],
              // enabledDayPredicate: (date) {
              //   return (date.weekday != DateTime.sunday &&
              //       date.weekday != DateTime.saturday);
              // },
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 600, hours: 23)),
              focusedDay: controller.focusedDay,
              // calendarFormat: controller.calendarFormat,
              eventLoader: controller.getEventForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(controller.selectedDay, day);
              },
              // onDaySelected: controller.onDaySelected,
              // onFormatChanged: (format) {
              //   if (controller.calendarFormat != format) {
              //     controller.changeCalendarFormat(format);
              //   }
              // },
              onPageChanged: (focusedDay) {
                controller.focusedDay = focusedDay;
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
                markerBuilder: (context, day, List<Cuadrante> events) => events.isNotEmpty
                    ? Container(
                        width: 17.0,
                        height: 17.0,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            // color: HelperTheme.success,
                            ),
                        child: Text(
                          events.first.title.toString(),
                          style: TextStyle(
                              color: HexColor(events.first.color!),
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
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
          ]));
        });
  }
}
