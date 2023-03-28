import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarkerBuilderWidget extends StatelessWidget {
  const MarkerBuilderWidget({
    super.key,
    required this.day,
    required this.events,
  });

  final DateTime day;
  final  events;

  @override
  Widget build(BuildContext context) {
    CalendarController calendarController = CalendarController();
    // calendarController.selectedEvents.value = events;
    return events.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(top: 12.h),
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: events.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Container(
                        // margin: const EdgeInsets.all(1.0),
                        //   padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: events[index].color != null
                              ? HexColor(events[index].color!).withAlpha(600)
                              : Theme.of(context).highlightColor,
                          border:  events[index].color != null
                              ? Border.all(
                                  color: HexColor(events[index].color), width: 1)
                              : Border.all(
                              color: Theme.of(context).highlightColor, width: 1),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        height: 18.h,
                        //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                        child: Container(
                          child: events[index].title != null
                              ? Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      bottom: 0.0,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            events[index].title!.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: events[index].color != null
                                                    ? HexColor(events[index].color!)
                                                :Theme.of(context).highlightColor,
                                                fontWeight: FontWeight.w900)),
                                      ),
                                    )
                                  ],
                                )
                              : null,
                        )),
                  );
                }),
          )
        : Container();
  }
}
