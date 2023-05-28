import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomAlertDialogTurnoList extends StatelessWidget {
  CustomAlertDialogTurnoList(
      {super.key, required this.selectedDate, required this.turno});

  final DateTime selectedDate;

  final List turno;

  CalendarController calendarController = CalendarController();
  //
  @override
  Widget build(BuildContext context) {
    final adcontroller = Get.find<AdsController>();

    var theme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                border: Border.all(color: PRIMARY_COLOR),
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.r),
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  // runSpacing: 1.h,
                  children: <Widget>[
                    ...turno.map((m) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(

                              side: BorderSide(width: 0.8.r),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            backgroundColor: HexColor(m.color!),
                          ),
                          child: Container(

                            alignment: Alignment.center,
                            height: 20.h,
                            width: 75.w,
                            child: Text(
                              m.description!,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor(m.color!).computeLuminance() > 0.5 ? Colors.black : Colors.white
                              ),
                            ),
                          ),
                          onPressed: () async {

                            await CalendarioDB.db.addItem(
                              CuadranteDay(
                                dateTime: DateTime.parse(selectedDate.toString().substring(0, 10)),
                                color: m.color,
                                description: m.description,
                                endHour: m.endHour,
                                startHour: m.startHour,
                                title: m.title,
                              ),
                            );
                            await calendarController.getCuadrante();
                            adcontroller.staticHomeAd.load();

                            Get.offAllNamed('/home');
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
