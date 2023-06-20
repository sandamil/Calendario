import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/customAlertDialogDaySelected.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/model/cuadranteDay.dart';
import '../../controllers/calendar_controller.dart';
import 'turnos_notas_onHomeDialog.dart';

class AddTurnostoCalendar extends StatefulWidget {
  AddTurnostoCalendar(
      {required this.selectedDate, required this.getCuadrante, super.key});
  DateTime selectedDate;
  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;

  @override
  State<AddTurnostoCalendar> createState() => _AddTurnostoCalendarState();
}

class _AddTurnostoCalendarState extends State<AddTurnostoCalendar> {
  final calendarController = Get.find<CalendarController>();

  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {
    calendarController.cuadrante.value =
        await CalendarioDB.db.getCuadranteList();

    setState(() {
      calendarController.cuadranteMap.clear();
      for (CuadranteDay turno in calendarController.cuadrante) {
        calendarController.cuadranteMap
            .putIfAbsent(turno.dateTime!, () => <CuadranteDay>[]);
        List<CuadranteDay>? turnoData =
            calendarController.cuadranteMap[turno.dateTime];
        turnoData!.add(turno);
        calendarController.cuadranteMap.update(turno.dateTime!, (data) {
          return turnoData;
        });
      }
      calendarController.isReady.value = true;
    });
    print('getCuadrante22222222');

    return calendarController.cuadranteMap;
  }

  @override
  Widget build(BuildContext context) {
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
                // color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.r),
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  // runSpacing: 1.h,
                  children: <Widget>[
                    ...calendarController.turno.map((m) {
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
                                  color: HexColor(m.color!).computeLuminance() >
                                          0.5
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ),
                          onPressed: () async {
                            await CalendarioDB.db.addCuadranteItem(
                              CuadranteDay(
                                cuadranteName: 'Turnos sueltos',
                                dateTime: DateTime.parse(widget.selectedDate
                                    .toString()
                                    .substring(0, 10)),
                                color: m.color,
                                description: m.description,
                                endHour: m.endHour,
                                startHour: m.startHour,
                                title: m.title,
                              ),
                            );
                            // await calendarController.getCuadrante();
                            // adcontroller.staticHomeAd.load();
                            await getCuadrante();
                            setState(() => calendarController.focusedDay.value =
                                widget.selectedDate);

                            Navigator.pop(context); // Get.offAllNamed('/home');
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

// final calendarController = Get.find<CalendarController>();
//
// Future<dynamic> showDialogOnLongPressCalendar(
//     context, DateTime selectedDate, currentY, currentX) {}
}
