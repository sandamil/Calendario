import 'dart:collection';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/cuadrante_calendar_day.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/calendar/widget/customAlertDialogDaySelected.dart';

class CalendarController extends GetxController {
  var logguer = Logger();
  Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;
  Rx<CalendarFormat> get calendarFormat => _calendarFormat;

  Rx<DateTime> _selectedDay = DateTime.now().obs;
  DateTime _focusedDay = DateTime.now();

  Rx<DateTime> get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;

  setFocusedDay(DateTime day) => _focusedDay;

  RxList<Cuadrante> selectedEvents = <Cuadrante>[].obs;
  // get selectedEvents => _selectedEvents;

  ///============================
//============================= Todo Rendimiento de app con obs =============================
  // DateTime _selectedDay = DateTime.now();
  // DateTime _focusedDay = DateTime.now();
  // get selectedDay => _selectedDay;
  // var focusedDay = DateTime.now();

  RxMap<DateTime, List<Cuadrante>> cuadranteMap =
      <DateTime, List<Cuadrante>>{}.obs;

  RxList<Cuadrante> cuadrante = <Cuadrante>[].obs;

  List<TurnoType> turno = [];

  RxBool isReady = false.obs;

  void onInit() async {
    await fetchCuadrante();
    super.onInit();
  }

  onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    print('onDaySelected1selectedDate' '${selectedDate}');
    print('onDaySelected1selectedDate' '${focusedDate}');
    print('onDaySelected1selectedDate' '${_selectedDay.value}');
    if (!isSameDay(selectedDate, _selectedDay.value)) {
      _selectedDay.value = selectedDate;
      _focusedDay = focusedDate;


      print('onDaySelected2selectedDate' '${selectedDate}');
      print('onDaySelected2selectedDate' '${focusedDate}');
      print('onDaySelected2selectedDate' '${_selectedDay.value}');
    }
    selectedEvents.value = getEventForDay(selectedDay.value);
    update();
    print('onDaySelected3selectedDate' '${selectedDate}');
    print('onDaySelected3selectedDate' '${focusedDate}');
    print('onDaySelected3selectedDate' '${_selectedDay.value}');
    Get.dialog(CustomAlertDilogDaySelected( selectedDate: selectedDate));
  }

  onPageChanged(focusedDay) {
    _focusedDay = focusedDay;
    update();
  }

  onFormatChanged(CalendarFormat format) {
    if (_calendarFormat.value != format) {
      _calendarFormat.value = format;
    }
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<Cuadrante> getEventForDay(DateTime day) {
    final events = LinkedHashMap<DateTime, List<Cuadrante>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(cuadranteMap);
    return events[day] ?? [];
  }

  Future<Map<DateTime, List<Cuadrante>>> fetchCuadrante() async {
    cuadrante.value = await TurnoDbProvider.instance.getItemModels();
    for (Cuadrante turno in cuadrante) {
      // print(turno.dateTime);
    }
    cuadranteMap.value.clear();
    for (var turno in cuadrante) {
      cuadranteMap.value.putIfAbsent(turno.dateTime!, () => <Cuadrante>[]);
      List<Cuadrante>? turnoData = cuadranteMap.value[turno.dateTime];
      turnoData!.add(turno);
      cuadranteMap.value.update(turno.dateTime!, (data) {
        return turnoData;
      });
    }
    isReady.value = true;

    return cuadranteMap.value;
  }

  Future<List<TurnoType>> fetchTurno() async {
    turno = await TurnoDbProvider.instance.getTypeModels();
    return turno;
  }

  Future<void> showPopUp(BuildContext context, selectedDate) {

    print('showPopUp   selectedDate ====' '${selectedDate}');
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
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
      },
    );
  }
}
