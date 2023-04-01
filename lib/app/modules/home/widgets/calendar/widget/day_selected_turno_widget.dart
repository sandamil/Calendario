import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class DaySelecetedTurnoWidget extends StatelessWidget {
  const DaySelecetedTurnoWidget({super.key});

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GetX<CalendarController>(
        init: CalendarController(),
        builder: (c) {

          return c.selectedEvents.value.isEmpty
              ? Container()
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            border: Border.all(width: 0.8.r),
                            borderRadius: BorderRadius.circular(5.r),
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
                                      color: HexColor(c.selectedEvents.value[index]
                                                      .color!)
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white),
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
                                      color: HexColor(c.selectedEvents.value[index]
                                                      .color!)
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white),
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
                                            color: HexColor(c.selectedEvents.value[index]
                                                .color!)
                                                .computeLuminance() >
                                                0.5
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.only(right: 20),
                                    )
                            ],
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 3.h,),
                  ...c.selectedNotas.value.map((nota) => Padding(
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
              );
        },
      ),
    );
  }
}
