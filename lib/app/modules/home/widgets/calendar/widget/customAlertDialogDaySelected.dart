import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'cuadrante_calendar_day.dart';

class CustomAlertDilogDaySelected extends StatelessWidget {
   CustomAlertDilogDaySelected({
    super.key, required this.selectedDate,
     required this.turno
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
                  Radius.circular(10.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  getContent(theme),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: turnoBtn(context, selectedDate),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: eventoBtn(),
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
      child: const CuadranteCalendarDay(),
    );
  }

  Widget turnoBtn(context, selectedDate) {
    return ElevatedButton(
      onPressed: () async {
        await calendarController.fetchTurno();
        Navigator.pop(context);

        calendarController.showPopUp(Get.context!, selectedDate, turno);

      },
      child: const Text("+ Turno"),
    );
  }

  Widget eventoBtn() {
    return ElevatedButton(
      onPressed: () {},
      child: const Text("+ Evento"),
    );
  }
}
