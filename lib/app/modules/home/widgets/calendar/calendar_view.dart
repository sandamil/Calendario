import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar_sandamil/table_calendar_sandamil.dart';
import 'package:intl/intl.dart';

import '../../../../../config/util/hexColor.dart';
import 'calendar_logic.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<CalendarLogic>();
    var theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(top: 6),
      child: TableCalendar(
        locale: 'es_ES',
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 75.h,
        marks: logic.events,
        events: logic.visibleEvents,
        availableCalendarFormats: const {
          CalendarFormat.month: 'MES',
          CalendarFormat.week: 'SEMANA',
        },
        onVisibleDaysChanged: logic.onVisibleDaysChanged,
        calendarController: logic.calendarController,
        onDaySelected: logic.onDaySelected,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextBuilder: (date, locale) =>
              DateFormat.E(locale).format(date)[0].toUpperCase(),
          weekdayStyle: TextStyle().copyWith(
              fontSize: 15.sp,
              color: Theme.of(context).textTheme.headlineMedium!.color),
          weekendStyle:
              TextStyle().copyWith(fontSize: 15.sp, color: Colors.red[700]),
        ),
        headerStyle: HeaderStyle(
          headerPadding: EdgeInsets.only(bottom: 20.h),
          titleTextBuilder: (date, locale) =>
              DateFormat.MMMM(locale).format(date).toUpperCase(),
          centerHeaderTitle: true,
          titleTextStyle:
              TextStyle(fontSize: 16.0, color: Theme.of(context).primaryColor),
          leftChevronIcon: Icon(
            Icons.arrow_back_ios,
            size: 25.h,
            color: Theme.of(context).primaryColorDark,
          ),
          rightChevronIcon: Icon(Icons.arrow_forward_ios,
              size: 25.h, color: Theme.of(context).primaryColorDark),
          formatButtonTextStyle: TextStyle().copyWith(
            color: Theme.of(context).textTheme.labelLarge?.color,
            fontSize: 10.sp,
          ),
          formatButtonDecoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        // key: keyButton8,
        headerVisible: true,
        builders: CalendarBuilders(
            todayDayBuilder: (context, date, events, marks) => Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(600),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5.h, left: 5.w),
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 14.sp),
                    ),
                  ),
                )),

            ///markersBuilder////////////////////////////////////////////////////

            markersBuilder: (context, date, events, marks, holidays) {
              final children = <Widget>[];

              if (events.isNotEmpty &&
                  logic.cuadranteMap[date]![0].title!.isNotEmpty) {
                children.add(
                  GestureDetector(
                    onLongPress: () async {
                      await logic.fetchTurno();
                      // await showPopUp(context, date);
                    },
                    child: Container(
                        //  bottom: 3,
                        // child: _buildEventsMarker(date, events),
                        ),
                  ),
                );
              }
              if (marks.isNotEmpty) {
                // children.add(
                // Positioned(
                //   right: 3,
                //   top: 3,
                //   // child: _buildMarksMarker(date, marks),
                // ),
                // );
              }
              return children;
            },

            ///selectedDayBuilder////////////////////////////////////////////////////

            selectedDayBuilder: (context, date, event, mark) {
              return Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(
                          fontSize: 7.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await logic.fetchTurno();
                      // await showPopUp(context, date);
                    },
                    child: DateFormat.yMd().format(date) !=
                            DateFormat.yMd().format(DateTime.now())
                        ? Container(
                            decoration: BoxDecoration(
                                color: event == {}
                                    ? HexColor(event[0].color).withAlpha(300)
                                    : Theme.of(context)
                                        .highlightColor
                                        .withAlpha(300),
                                border: event == {}
                                    ? Border.all(
                                        color: HexColor(event[0].color),
                                        width: 2)
                                    : null,
                                borderRadius: BorderRadius.circular(15)),
                            width: 100,
                            height: 100,
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .highlightColor
                                    .withAlpha(300),
                                border: event != null
                                    ? Border.all(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        width: 4)
                                    : null,
                                borderRadius: BorderRadius.circular(15)),
                            width: 100,
                            height: 100,
                          ),
                  ),
                ],
              );
            },

            ///dayBuilder////////////////////////////////////////////////////

            dayBuilder: (context, date, event, mark) {
              return Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      border: DateFormat.yMd().format(date) !=
                              DateFormat.yMd().format(DateTime.now())
                          ? Border.all(
                              color: Theme.of(context).highlightColor, width: 2)
                          : Border.all(
                              color: Theme.of(context).primaryColorDark,
                              width: 5),
                      borderRadius: DateFormat.yMd().format(date) !=
                              DateFormat.yMd().format(DateTime.now())
                          ? BorderRadius.circular(15)
                          : BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.h, left: 5.w),
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(fontSize: 14.sp),
                      ),
                    ),
                  ));
            }),
      ),
    );
  }
}
