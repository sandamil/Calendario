import 'dart:collection';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/calendar/widget/customAlertDialogTurnoList.dart';
import '../widgets/calendar/widget/customAlertDialogDaySelected.dart';

class CalendarController extends GetxController {
  var logguer = Logger();
  Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;
  Rx<CalendarFormat> get calendarFormat => _calendarFormat;

  Rx<DateTime> _selectedDay = DateTime.now().obs;
  Rx<DateTime> _focusedDay = DateTime.now().obs;

  Rx<DateTime> get selectedDay => _selectedDay;
  Rx<DateTime> get focusedDay => _focusedDay;

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

  RxMap<DateTime, List<Task>> notasMap = <DateTime, List<Task>>{}.obs;

  RxList<Cuadrante> cuadrante = <Cuadrante>[].obs;

  RxList<TurnoType> turno = <TurnoType>[].obs;

  RxBool isReady = false.obs;


///////////////oninit
  /// ==

  void onInit() async {
    await fetchCuadrante();
    await fetchTurno();
    await getListEvent();
    print(listEvent.length);
    super.onInit();
  }

  onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(selectedDate, _selectedDay.value)) {
      _selectedDay.value = selectedDate;
      _focusedDay.value = focusedDate;
    }
    selectedEvents.value = getEventForDay(selectedDay.value);
    Get.dialog(CustomAlertDilogDaySelected(
        selectedDate: selectedDate, turno: turno.value));
  }

//TODO Comprobar rendimiento focusedday obs
  onPageChanged(focusedDay) {
    _focusedDay.value = focusedDay;
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
    cuadrante.value = await DBHelper.db.getItemModels();
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

  // getNotesFromDB() async {
  //   notasMap.value = await DbProvider.instance.getNotesFromDB();
  //   update();
  //   return notasMap.value;
  // }


  Future<List<TurnoType>> fetchTurno() async {
    turno.value = await DBHelper.db.getTypeModels();
    return turno;
  }

  showPopUp(context, selectedDate, turno) {
    return showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialogTurnoList(
            selectedDate: selectedDate, turno: turno);
      },
    );
  }

///////////////     Notas
/// ==



  RxList<Task> listEvent = <Task>[].obs;

   getListEvent() async {
    listEvent.value = await DbProvider.instance.getNotesFromDB();
  }

  bool hasEvent(DateTime day) {
    bool check = false;
    if (listEvent.isNotEmpty) {
      listEvent.value.forEach((event) {
        if (DataValidator.isSameDay(DateTime.fromMillisecondsSinceEpoch(event.startTimeMilliseconds!), day)) {
          check = true;
        }
      });
    }
    return check;
  }

  List<Task> getEventsOfDay(DateTime day) {
    List<Task> list = [];
    listEvent.value.forEach((event) {
      if (DataValidator.isSameDay(DateTime.fromMillisecondsSinceEpoch(event.startTimeMilliseconds!), day)) {
        list.add(event);
      }
    });
    return list;
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

