import 'dart:collection';

import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/calendar/widget/customAlertDialogTurnoList.dart';
import '../widgets/calendar/widget/customAlertDialogDaySelected.dart';

class CalendarController extends GetxController {
  final adcontroller = Get.find<AdsController>();

  // final Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;

  // var currentX = 0.0;
  // var currentY = 0.0;

  // Rx<CalendarFormat> get calendarFormat => _calendarFormat;

  ///============================
//============================= Todo Rendimiento de app con obs =============================
//
  final focusDayRx = DateTime.now().obs;
  final selectedDayRx = DateTime.now().toLocal().obs;
//   // Rx<DateTime> get selectedDay => _selectedDay;
//   Rx<DateTime> selectedDay = DateTime.now().obs;
//   // DateTime _selectedDay = DateTime.now();
// //   get selectedDay => _selectedDay;
// //
//
//   final Rx<DateTime> _focusedDay = DateTime.now().obs;
//   Rx<DateTime> get focusedDay => _focusedDay;
//   setFocusedDay(DateTime day) => _focusedDay;
// //   DateTime _focusedDay = DateTime.now();
// //   var focusedDay = DateTime.now();

  final selectedDayTurnos = <CuadranteDay>[].obs;
  RxList<Task> selectedDayNotas = <Task>[].obs;
  // get selectedEvents => _selectedEvents;

  RxMap<DateTime, List<CuadranteDay>> cuadranteMap =
      <DateTime, List<CuadranteDay>>{}.obs;

  RxMap<DateTime, List<Task>> notasMap = <DateTime, List<Task>>{}.obs;

  RxList<CuadranteDay> cuadrante = <CuadranteDay>[].obs;

  List<TurnoType> turno = <TurnoType>[];

  RxBool isReady = false.obs;

///////////////oninit
  /// ==

  @override
  void onInit() async {
    // getCuadrante();
    //  getListEvent();
    super.onInit();
  }

  @override
  void onReady() async {
     fetchTurno();
    super.onReady();
  }


  // onTapDown(TapDownDetails details) {
  //   currentX = details.globalPosition.dx;
  //   currentY = details.globalPosition.dy;
  //   print(currentX);
  //   print(currentY);
  // }

  // onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
  //   if (!isSameDay(selectedDate, selectedDayRx.value)) {
  //     selectedDayRx.value = selectedDate;
  //     focusDayRx = focusedDate;
  //     selectedDayTurnos.value = getTurnosOfDay(selectedDate);
  //     selectedDayNotas.value = getNotasOfDay(selectedDate);
  //     update();
  //   }
  //   // else {
  //   //   selectedDay.value = selectedDate;
  //   //   _focusedDay.value = focusedDate;
  //   //   // Get.dialog(CustomAlertDilogDaySelected(
  //   //   //     x: currentX, y: currentY, selectedDate: selectedDate, turno: turno));
  //   // }
  //   // selectedEvents.value = getEventForDay(selectedDay.value);
  //   // selectedNotas.value = getEventsOfDay(selectedDay.value);
  //   // // Get.dialog(CustomAlertDilogDaySelected(
  //   // //     x: currentX, y: currentY, selectedDate: selectedDate, turno: turno));
  // }

  // onDaySelectedLongPress(DateTime selectedDate, DateTime focusedDate) async {
  //   if (!isSameDay(selectedDate, selectedDayRx.value)) {
  //     selectedDayRx.value = selectedDate;
  //     // focusDayRx.value = focusedDate;
  //   }
  //   selectedDayTurnos.value = getTurnosOfDay(selectedDate);
  //   selectedDayNotas.value = getNotasOfDay(selectedDate);
  //
  //   Get.dialog(CustomAlertDilogDaySelected(
  //       x: currentX, y: currentY, selectedDate: selectedDayRx.value, turno: turno));
  // }

  // onPageChanged(focusedDay) {
  //   focusDayRx.value = focusedDay;
  //
  //   // change the selected day to the first day of current month.
  //   selectedDayRx.value = DateTime(focusedDay.year, focusedDay.month, 1);
  //
  //   // change the selected events to the first day of current month.
  //   selectedDayNotas.value = getNotasOfDay(selectedDayRx.value);
  //
  //   update();
  // }

  // onFormatChanged(CalendarFormat format) {
  //   if (_calendarFormat.value != format) {
  //     _calendarFormat.value = format;
  //   }
  // }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<CuadranteDay> getTurnosOfDay(DateTime day) {
    final events = LinkedHashMap<DateTime, List<CuadranteDay>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(cuadranteMap);
    return events[day] ?? [];
  }

  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {

    cuadrante.value = await CalendarioDB.db.getCuadranteList();
    cuadranteMap.clear();
    for (CuadranteDay turno in cuadrante) {
      cuadranteMap.putIfAbsent(turno.dateTime!, () => <CuadranteDay>[]);
      List<CuadranteDay>? turnoData = cuadranteMap[turno.dateTime];
      turnoData!.add(turno);
      cuadranteMap.update(turno.dateTime!, (data) {
        return turnoData;
      });
    }
    isReady.value = true;

    print('get cuadrante =============');
    return cuadranteMap;
  }

  // getNotesFromDB() async {
  //   notasMap.value = await DbProvider.instance.getNotesFromDB();
  //   update();
  //   return notasMap.value;
  // }

  Future<List<TurnoType>> fetchTurno() async {
    turno = await CalendarioDB.db.getTypeModels();
    return turno;
  }

  showPopUp(context, selectedDate, turno) {
    return showDialog(
      context: context,
      builder: (context) {
        // adcontroller.staticHomeAd.dispose();

        return CustomAlertDialogTurnoList(
            selectedDate: selectedDate, turno: turno);
      },
    );
  }

///////////////     Notas
  /// ==

  RxList<Task> listEvent = <Task>[].obs;
  // RxList<Task> listEvent2 = <Task>[].obs;

  getListEvent() async {
    listEvent.value = await NotasDB.instance.getNotesFromDB();
  }

  bool hasEvent(DateTime day) {
    bool check = false;
    if (listEvent.isNotEmpty) {
      for (var event in listEvent) {
        if (DataValidator.isSameDay(
            DateTime.fromMillisecondsSinceEpoch(event.startTimeMilliseconds!),
            day)) {
          check = true;
        }
      }
    }
    return check;
  }

  List<Task> getNotasOfDay(DateTime day) {
    List<Task> list = [];
    for (var event in listEvent) {
      if (DataValidator.isSameDay(
          DateTime.fromMillisecondsSinceEpoch(event.startTimeMilliseconds!),
          day)) {
        list.add(event);
      }
    }
    return list;
  }

  deleteTurnoCuadrante(id) {
    adcontroller.staticHomeAd.load();

    CalendarioDB.db.deleteItemID(id);
    Get.offAllNamed('/home');
  }
}

class DataValidator {
  static bool isSameDay(DateTime first, DateTime second) {
    if (first.year == second.year &&
        first.month == second.month &&
        first.day == second.day) {
      return true;
    }
    return false;
  }
}
