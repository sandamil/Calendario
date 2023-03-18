import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarkerBuilderWidget extends StatelessWidget {
  const MarkerBuilderWidget(
      {super.key, required this.day, required this.events,});

  final DateTime day;
  final List<Cuadrante> events;

  @override
  Widget build(BuildContext context) {
    CalendarController calendarController = CalendarController();
    // calendarController.selectedEvents.value = events;
print(events.length);
    return events.isNotEmpty
        ? ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: events.length,
        itemBuilder: (BuildContext context, int index) {
          return  Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 25.h),
              child: Container(
                // margin: const EdgeInsets.all(1.0),
                //   padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    color: events != null
                        ? HexColor(events[0].color!)
                        .withAlpha(600)
                        : Theme.of(context).highlightColor,
                    border: events != null
                        ? Border.all(
                        color: HexColor(events[0].color!),
                        width: 1)
                        : null,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  height: 18.h,
                  //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                  child: Container(
                    child: events[0].title != null
                        ? Stack(
                      children: <Widget>[
                        Positioned.fill(
                          bottom: 0.0,
                          child: Align(
                            alignment:
                            Alignment.center,
                            child: Text(
                                events[0]
                                    .title!
                                    .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: HexColor(
                                        events[0].color!),
                                    fontWeight:
                                    FontWeight.w900)),
                          ),
                        )
                      ],
                    )
                        : null,
                  )),
            ),
          );
        }
    )





        : Container();
  }
}
