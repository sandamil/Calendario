import 'dart:developer';
import 'dart:math';
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
    var theme = Theme.of(context);

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
                        ///======holidayBuilder:============== ============== ============== ==============
                        ///

                        markerBuilder: (context, day, List<Cuadrante> events)
                        {
                          // if (events.isEmpty) return SizedBox();
                          return Container(
                            margin: EdgeInsets.only(top: 20.h),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: HexColor(events[index].color!).withAlpha(600),
                                      border: Border.all(
                                          color: HexColor(events[index].color!), width: 1),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    height: 18.h,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(events[index].title!.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: HexColor(events[index].color!),

                                              fontWeight: FontWeight.w900)),
                                    ),
                                  );
                                }),
                          );
                        },
                        // {
                        //   return Padding(
                        //     padding: const EdgeInsets.all(2),
                        //     child: Column(
                        //       children: [
                        //         SizedBox(
                        //           height: 15.h,
                        //         ),
                        //         Expanded(
                        //           child: SingleChildScrollView(
                        //             child: Column(
                        //               children: events
                        //                   .map((event) => Padding(
                        //                         padding:
                        //                             EdgeInsets.only(top: 2.h),
                        //                         child: Container(
                        //                             // margin: const EdgeInsets.all(1.0),
                        //                             //   padding: const EdgeInsets.all(1.0),
                        //                             decoration: BoxDecoration(
                        //                               color: event.color != null
                        //                                   ? HexColor(
                        //                                           event.color!)
                        //                                       .withAlpha(600)
                        //                                   : Theme.of(context)
                        //                                       .highlightColor,
                        //                               border: event.color !=
                        //                                       null
                        //                                   ? Border.all(
                        //                                       color: HexColor(
                        //                                           event.color!),
                        //                                       width: 1)
                        //                                   : Border.all(
                        //                                       color: Theme.of(
                        //                                               context)
                        //                                           .highlightColor,
                        //                                       width: 1),
                        //                               borderRadius:
                        //                                   BorderRadius.circular(
                        //                                       5.r),
                        //                             ),
                        //                             height: 18.h,
                        //                             //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                        //                             child: Container(
                        //                               child: event.title != null
                        //                                   ? Stack(
                        //                                       children: <
                        //                                           Widget>[
                        //                                         Positioned.fill(
                        //                                           bottom: 0.0,
                        //                                           child: Align(
                        //                                             alignment:
                        //                                                 Alignment
                        //                                                     .center,
                        //                                             child: Text(
                        //                                                 event
                        //                                                     .title!
                        //                                                     .toUpperCase(),
                        //                                                 style: TextStyle(
                        //                                                     fontSize: 14
                        //                                                         .sp,
                        //                                                     color: event.color != null
                        //                                                         ? HexColor(event.color!)
                        //                                                         : Theme.of(context).highlightColor,
                        //                                                     fontWeight: FontWeight.w900)),
                        //                                           ),
                        //                                         )
                        //                                       ],
                        //                                     )
                        //                                   : null,
                        //                             )),
                        //                       ))
                        //                   .toList(),
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   );
                        // },

                        // =>
                        //     MarkerBuilderWidget(
                        //       key: UniqueKey(),
                        //       day: day,
                        //       events: events,
                        //     ),

                        ///========== holidayBuilder:========================================
                        ///

                        holidayBuilder: (context, day, focusDay) {
                          final events = calendarController.getEventsOfDay(day);
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    border: Border.all(
                                        color: theme.primaryColor, width: 1),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  height: 18.h,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(events[index].title!.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 14.sp,


                                            fontWeight: FontWeight.w900),
                                  ),
                                ));
                              });
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
