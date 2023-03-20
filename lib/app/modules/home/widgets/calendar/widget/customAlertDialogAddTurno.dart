import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';


class CustomAlertDialogTurno extends StatelessWidget {

  CustomAlertDialogTurno({
    super.key,
    required this.selectedDate,
    required this.turno
  });

  final DateTime selectedDate;

  final List turno;

  CalendarController calendarController = CalendarController();
  //
  @override
  Widget build(BuildContext context) {
    var logguer = Logger();
    logguer.i(calendarController.turno);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: AlertDialog(
        title: Text('Cambia Tipo de día'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                runSpacing: 10,
                children: <Widget>[
                  ...turno.map((m) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
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
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .backgroundColor),
                          ),
                        ),
                        onPressed: () async {
                          print('showPopUp onPressed   selectedDate ====' '${selectedDate}');
                          logguer.i(' 666666666    onpressed');
                          await TurnoDbProvider.instance.addItemModel(
                            Cuadrante(
                              dateTime: selectedDate,
                              color: m.color,
                              description: m.description,
                              endHour: m.endHour,
                              startHour: m.startHour,
                              title: m.title,
                            ),
                          );
                          await calendarController.fetchCuadrante();
                          logguer.i('77777777 nnonpressed');
                          //
                          // calendarController.selectedEvents.value =
                          //     calendarController.cuadranteMap[calendarController.selectedDay] ?? [];
                          //
                          // logguer.i('888888888   onpressed');
                          //
                          //
                          // calendarController.update();
                          logguer.i('99999999onpressed');

                          Get.offAllNamed('/home');

                          logguer.i('---------------onpressed');
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                padding:
                EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
                elevation: 5.0,
              ),
              child: Text(
                "Calendario",
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
              ),
              onPressed: () {
                Get.offAllNamed('/home');
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) =>
                //           // AddTaskPage(__selectedDay, _events),
                //     )
                // );
              },
            ),
          ],
        ),
      ),
    );
  }

}