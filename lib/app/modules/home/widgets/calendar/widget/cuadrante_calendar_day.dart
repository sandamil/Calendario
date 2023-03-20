import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CuadranteCalendarDay extends StatelessWidget {
  const CuadranteCalendarDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<CalendarController>(
        init: CalendarController(),
        builder: (c) {
          return c.selectedEvents.value.isEmpty
              ? Container()
              : Wrap(
                alignment: WrapAlignment.start,
                runSpacing: 10,
                children: <Widget>[
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: c.selectedEvents.value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 30,
                          padding:
                              EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: HexColor(c.selectedEvents.value[index].color!),
                            border: Border.all(width: 0.8),
                            borderRadius: BorderRadius.circular(5.r),
                            // boxShadow: const <BoxShadow>[
                            //   BoxShadow(
                            //       color: Colors.black45,
                            //       offset: Offset(0, 1),
                            //       blurRadius: 3),
                            // ],
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FittedBox(
                                child: Text(
                                  '${c.selectedEvents.value[index].dateTime.toString().substring(8, 10)}-${c.selectedEvents.value[index].dateTime.toString().substring(5, 7)}-${c.selectedEvents.value[index].dateTime.toString().substring(0, 4)}',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .titleLarge!
                                          .color),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              FittedBox(
                                child: Text(
                                  c.selectedEvents.value[index].description!,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .titleLarge!
                                          .color),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              c.selectedEvents.value[index].startHour != null &&
                                      c.selectedEvents.value[index].endHour != null
                                  ? FittedBox(
                                      child: Text(
                                        '${c.selectedEvents.value[index].startHour.toString()} a ${c.selectedEvents.value[index].endHour.toString()}',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Theme.of(context)
                                                .primaryTextTheme
                                                .titleLarge!
                                                .color),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.only(right: 20),
                                    )
                            ],
                          ),
                        );
                      }),
                ],
              );

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: c.selectedEvents.value
                .map(
                  (turno) => Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: HexColor(turno.color!),
                      border: Border.all(width: 0.8),
                      borderRadius: BorderRadius.circular(5.r),
                      // boxShadow: const <BoxShadow>[
                      //   BoxShadow(
                      //       color: Colors.black45,
                      //       offset: Offset(0, 1),
                      //       blurRadius: 3),
                      // ],
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FittedBox(
                          child: Text(
                            '${turno.dateTime.toString().substring(8, 10)}-${turno.dateTime.toString().substring(5, 7)}-${turno.dateTime.toString().substring(0, 4)}',
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .color),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        FittedBox(
                          child: Text(
                            turno.description!,
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .color),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        turno.startHour != null && turno.endHour != null
                            ? FittedBox(
                                child: Text(
                                  '${turno.startHour.toString()} a ${turno.endHour.toString()}',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .titleLarge!
                                          .color),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.only(right: 20),
                              )
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
