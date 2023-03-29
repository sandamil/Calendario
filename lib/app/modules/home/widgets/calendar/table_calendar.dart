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
                          .subtract(const Duration(days: 200, hours: 23)),
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

                      /// ===        Calendar builders     ========================================
                      calendarBuilders: CalendarBuilders(
                        /// =       markerBuilder:          =======================================
                        markerBuilder: (context, day, List<Cuadrante> events) {
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                // color: OLD_LACE_COLOR,
                                border: Border.all(width: 1, color: GREY_COLOR),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                  child: Column(
                                    children: [
                                      const Text(
                                       '',
                                        // style: AppTextStyle.defaultTextStyle(),
                                      ),

                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: events.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:  EdgeInsets.all(0.5.w),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: HexColor(events[index].color!)
                                                          .withAlpha(600),
                                                      border: Border.all(
                                                          color: HexColor(events[index].color!),
                                                          width: 1),
                                                      borderRadius: BorderRadius.circular(5.r),
                                                    ),
                                                    height: 18.h,
                                                    child: Align(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                          events[index].title!.toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: HexColor(
                                                                  events[index].color!),
                                                              fontWeight: FontWeight.w900)),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          // if (events.isEmpty) return SizedBox();
                          // return Container(
                          //   margin: EdgeInsets.only(top: 20.h,bottom: 40.h),
                          //   child: ListView.builder(
                          //       shrinkWrap: true,
                          //       itemCount: events.length,
                          //       itemBuilder: (context, index) {
                          //         return Container(
                          //           decoration: BoxDecoration(
                          //             color: HexColor(events[index].color!)
                          //                 .withAlpha(600),
                          //             border: Border.all(
                          //                 color: HexColor(events[index].color!),
                          //                 width: 1),
                          //             borderRadius: BorderRadius.circular(5.r),
                          //           ),
                          //           height: 18.h,
                          //           child: Align(
                          //             alignment: Alignment.center,
                          //             child: Text(
                          //                 events[index].title!.toUpperCase(),
                          //                 style: TextStyle(
                          //                     fontSize: 14.sp,
                          //                     color: HexColor(
                          //                         events[index].color!),
                          //                     fontWeight: FontWeight.w900)),
                          //           ),
                          //         );
                          //       }),
                          // );
                        },
                        ///==      holidayBuilder:         ========================================

                        holidayBuilder: (context, day, focusDay) {
                          final events = calendarController.getEventsOfDay(day);

                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                color: OLD_LACE_COLOR,
                                border: Border.all(width: 1, color: GREY_COLOR),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Column(
                                  children: [
                                    Text(
                                      day.day.toString(),
                                      // style: AppTextStyle.defaultTextStyle(),
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: events.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:  EdgeInsets.all(1.w),
                                                child: GestureDetector(
                                                  onTap: () {
                                                   print('tap');
                                                    },

                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        color: theme.primaryColor,
                                                        border: Border.all(
                                                            color: theme.primaryColor, width: 1),
                                                        borderRadius: BorderRadius.circular(5.r),
                                                      ),
                                                      height: 14.h,
                                                      child: Align(
                                                        alignment: Alignment.bottomCenter,
                                                        child: Text(
                                                          events[index].title!.toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 11.sp,
                                                              fontWeight: FontWeight.w700),
                                                        ),
                                                      )),
                                                ),
                                              );
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );


                          // final events = calendarController.getEventsOfDay(day);
                          //
                          // return Container(
                          //   margin: EdgeInsets.only(top: 60.h,),
                          //   child: ListView.builder(
                          //       shrinkWrap: true,
                          //       itemCount: events.length,
                          //       itemBuilder: (context, index) {
                          //         return Container(
                          //             decoration: BoxDecoration(
                          //               color: theme.primaryColor,
                          //               border: Border.all(
                          //                   color: theme.primaryColor, width: 1),
                          //               borderRadius: BorderRadius.circular(5.r),
                          //             ),
                          //             height: 18.h,
                          //             child: Align(
                          //               alignment: Alignment.bottomCenter,
                          //               child: Text(
                          //                 events[index].title!.toUpperCase(),
                          //                 style: TextStyle(
                          //                     fontSize: 14.sp,
                          //                     fontWeight: FontWeight.w900),
                          //               ),
                          //             ));
                          //       }),
                          // );
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: GREY_COLOR),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: Column(
                                  children: [
                                    Text(
                                      day.day.toString(),
                                      // style: AppTextStyle.defaultTextStyle(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          // return Padding(
                          //   padding: EdgeInsets.all(1.h),
                          //   child: Container(
                          //     alignment: Alignment.center,
                          //     decoration: BoxDecoration(
                          //       color: MyColors.cellColor,
                          //       // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                          //       border: Border.all(
                          //         color: PRIMARY_COLOR,
                          //         width: 0.05.w,
                          //       ),
                          //       borderRadius: BorderRadius.circular(5.r),
                          //     ),
                          //     child: Align(
                          //       alignment: Alignment.topCenter,
                          //       child: Text(
                          //         day.day.toString(),
                          //         // textWidthBasis: TextWidthBasis.longestLine,
                          //         style: TextStyle(
                          //           fontSize: 15.sp,
                          //           // fontFamily: 'FiraCode',
                          //           // color: MyColors.cellTextColor,
                          //         ),
                          //       ),
                          //     ),
                          //
                          //   ),
                          // );
                        },

                        selectedBuilder: (context, day, focusedDay) {
                          return Padding(
                            padding: EdgeInsets.all(1.h),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: MyColors.cellColor,
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
                                  // textWidthBasis: TextWidthBasis.longestLine,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    // fontFamily: 'FiraCode',
                                    // color: MyColors.cellTextColor,
                                  ),
                                ),
                              ),

                            ),
                          );
                        },

                        todayBuilder: (context, day, events) {
                          return Padding(
                            padding: EdgeInsets.all(1.h),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: MyColors.cellColor,
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
                                  // textWidthBasis: TextWidthBasis.longestLine,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    // fontFamily: 'FiraCode',
                                    // color: MyColors.cellTextColor,
                                  ),
                                ),
                              ),

                            ),
                          );
                        },

                        // // holidayBuilder: (context, day, events) =>
                        // //     DayBuilderWidget(date: day, dayType: 'holiday'),
                        //
                        // outsideBuilder: (context, date, events) =>
                        //     DayBuilderWidget(date: date, dayType: 'outside'),

                        dowBuilder: (context, day) {
                        //   if (day.weekday == DateTime.sunday ||
                        //       day.weekday == DateTime.saturday) {
                            final text = DateFormat.E('es').format(day);
                            return Center(
                              child: Text(
                                text.toUpperCase(),
                        //         style: const TextStyle(color: Colors.red),
                              ),
                            );
                        //   } else {
                        //     final text = DateFormat.E('es').format(day);
                        //     return Center(
                        //       child: Text(
                        //         text.toUpperCase(),
                        //         style:
                        //             const TextStyle(color: Colors.orangeAccent),
                        //       ),
                        //     );
                        //   }
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
