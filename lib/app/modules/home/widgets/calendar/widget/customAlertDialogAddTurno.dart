import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'cuadrante_calendar_day.dart';

class CustomAlertDialogTurno extends StatelessWidget {

  CustomAlertDialogTurno({
    super.key,
    required this.dateTime,
    // required this.dayType
  });

  final DateTime dateTime;

  // final String dayType;
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
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: HexColor(m.color!),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 10.h,
                        width: 16.w,
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
                        logguer.i('onpressed');
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
                        await fetchCuadrante();

                        selectedEvents.value =
                            cuadranteMap[_selectedDay] ?? [];



                        update();
                        Get.offAllNamed('/home');                          },
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