import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/model/cuadranteDay.dart';
import '../../../../data/model/taskModel.dart';

calendarBuilders() => CalendarBuilders(
      /// =       markerBuilder:          =======================================

      markerBuilder: (context, day, List<CuadranteDay> events) {
        // List<Task> notas = calendarController.getNotasOfDay(day);
        return Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(top: 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...events.map((turno) => Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 0.5.h, horizontal: 3.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: HexColor(turno.color!).withAlpha(600),
                          // border: Border.all(
                          //     color: HexColor(turno.color!), width: 1.h),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        height: 15.h,
                        child: Container(
                          alignment: Alignment.center,
                          height: 15,
                          width: double.maxFinite,
                          child: Text(turno.title!.toUpperCase(),
                              style: TextStyle(
                                  height: 1.2.h,
                                  fontSize: 12.sp,
                                  color: HexColor(turno.color!),
                                  fontWeight: FontWeight.w900)),
                        ),
                      ),
                    )),
                SizedBox(
                  height: 3.h,
                ),
                ...events.map((nota) => Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 0.5.h, horizontal: 1.w),
                      child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.menuCardBackground,
                            // color: PRIMARY_COLOR_TRANSPARENTE,
                            // border: Border.all(
                            //     color: PRIMARY_COLOR_TRANSPARENTE, width: 1.h),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          height: 15.h,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              nota.title!.toUpperCase(),
                              maxLines: 1,
                              style: TextStyle(
                                  height: 1.h,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                    )),
              ],
            ),
          ),
        );
      },

      ///==      holidayBuilder:         ========================================
      holidayBuilder: (context, day, focusedDay) {
        return Padding(
          padding: EdgeInsets.all(0.h),
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              border: Border.all(width: 1.w, color: MyColors.borderCellColor),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Column(
                children: [
                  Text(
                    day.day.toString(),
                    style: CustomTextStyle.numberCalendar.copyWith(
                      color: MyColors.cellTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      ///==      outsideBuilder:         ========================================
      // outsideBuilder: (context, date, events) =>
      //     DayBuilderWidget(date: date, dayType: 'outside'),

      ///==      defaultBuilder:         ========================================
      defaultBuilder: (context, day, focusedDay) {
        return Padding(
          padding: EdgeInsets.all(0.h),
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: MyColors.cellColor,
              border: Border.all(width: 1.w, color: MyColors.borderCellColor),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Column(
                children: [
                  Text(
                    day.day.toString(),
                    style: CustomTextStyle.numberCalendar.copyWith(
                      color: MyColors.cellTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      ///==      selectedBuilder:         ========================================
      selectedBuilder: (context, day, focusedDay) {
        return Padding(
          padding: EdgeInsets.all(0.h),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MyColors.cellSelectedColor,
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
                style: CustomTextStyle.numberCalendar.copyWith(
                  fontSize: 15.sp,
                  color: MyColors.cellTextColor,
                ),
              ),
            ),
          ),
        );
      },

      ///==      todayBuilder:         ========================================
      todayBuilder: (context, day, events) {
        return Padding(
          padding: EdgeInsets.all(0.h),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MyColors.cellTodayColor,
              // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
              border: Border.all(
                color: PRIMARY_COLOR,
                width: 1.w,
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
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'FiraCode',
                  color: PRIMARY_COLOR,
                ),
              ),
            ),
          ),
        );
      },

      ///==      dowBuilder:         ========================================
      dowBuilder: (context, day) {
        final text = DateFormat.E('es').format(day);
        if (day.weekday == DateTime.sunday
            // || day.weekday == DateTime.saturday
            ) {
          return Center(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return Center(
          child: Text(
            text.toUpperCase(),
            // style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
