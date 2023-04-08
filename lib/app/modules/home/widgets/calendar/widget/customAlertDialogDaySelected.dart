import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'day_selected_turno_widget.dart';

class CustomAlertDilogDaySelected extends StatelessWidget {
  CustomAlertDilogDaySelected(
      {super.key, required this.selectedDate, required this.turno
      // required this.dayType
      });

  final DateTime selectedDate;
  final List turno;

  CalendarController calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  getContent(theme),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: turnoBtn(context, selectedDate),
                      ),
                       SizedBox(width: 4.w),
                      Container(
                        width: 75.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2.w, color: PRIMARY_COLOR),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(selectedDate.formatDateD,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.sp)
                              ),
                            ),
                            Container(
                              child: Text(selectedDate.formatDateMMM,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.sp)
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 4.w),
                      Expanded(
                        child: eventoBtn(context, selectedDate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContent(theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      height: 150,
      child: const DaySelecetedTurnoWidget(),
    );
  }

  Widget turnoBtn(context, selectedDate) {
    return Padding(
      padding:  EdgeInsets.all(2.h),
      child: ElevatedButton(
        onPressed: () async {
          await calendarController.fetchTurno();
          Navigator.pop(context);
          calendarController.showPopUp(Get.context!, selectedDate, turno);
        },
        child: const Text("+ Turno"),
      ),
    );
  }

  Widget eventoBtn(context, selectedDate) {
    return Padding(
      padding:  EdgeInsets.all(2.h),
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed('/add-notas', arguments: selectedDate);
        },
        child: const Text("+ Evento"),
      ),
    );
  }
}
