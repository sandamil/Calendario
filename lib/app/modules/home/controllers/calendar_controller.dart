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

  final Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;

  var currentX = 0.0;
  var currentY = 0.0;

  Rx<CalendarFormat> get calendarFormat => _calendarFormat;

  ///============================
//============================= Todo Rendimiento de app con obs =============================
//

  // Rx<DateTime> get selectedDay => _selectedDay;
  Rx<DateTime> selectedDay = DateTime.now().obs;
  // DateTime _selectedDay = DateTime.now();
//   get selectedDay => _selectedDay;
//

  final Rx<DateTime> _focusedDay = DateTime.now().obs;
  Rx<DateTime> get focusedDay => _focusedDay;
  setFocusedDay(DateTime day) => _focusedDay;
//   DateTime _focusedDay = DateTime.now();
//   var focusedDay = DateTime.now();

  RxList<CuadranteDay> selectedEvents = <CuadranteDay>[].obs;
  RxList<Task> selectedNotas = <Task>[].obs;
  // get selectedEvents => _selectedEvents;

  RxMap<DateTime, List<CuadranteDay>> cuadranteMap =
      <DateTime, List<CuadranteDay>>{}.obs;

  RxMap<DateTime, List<Task>> notasMap = <DateTime, List<Task>>{}.obs;

  RxList<CuadranteDay> cuadrante = <CuadranteDay>[].obs;

  RxList<TurnoType> turno = <TurnoType>[].obs;

  RxBool isReady = false.obs;

///////////////oninit
  /// ==

  @override
  void onInit() async {
    await fetchCuadrante();
    await fetchTurno();
    await getListEvent();
    super.onInit();
  }

  onTapDown(TapDownDetails details) {
    currentX = details.globalPosition.dx;
    currentY = details.globalPosition.dy;
  }

  onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
    if (!isSameDay(selectedDate, selectedDay.value)) {
      selectedDay.value = selectedDate;
      _focusedDay.value = focusedDate;
    }
    else {
      selectedDay.value = selectedDate;
      _focusedDay.value = focusedDate;
      // Get.dialog(CustomAlertDilogDaySelected(
      //     x: currentX, y: currentY, selectedDate: selectedDate, turno: turno));
    }
    selectedEvents.value = getEventForDay(selectedDay.value);
    selectedNotas.value = getEventsOfDay(selectedDay.value);
    // Get.dialog(CustomAlertDilogDaySelected(
    //     x: currentX, y: currentY, selectedDate: selectedDate, turno: turno));
  }

  onDaySelectedLongPress(DateTime selectedDate, DateTime focusedDate) async {
    if (!isSameDay(selectedDate, selectedDay.value)) {
      selectedDay.value = selectedDate;
      _focusedDay.value = focusedDate;
    }
    selectedEvents.value = getEventForDay(selectedDay.value);
    selectedNotas.value = getEventsOfDay(selectedDay.value);

    Get.dialog(CustomAlertDilogDaySelected(
        x: currentX, y: currentY, selectedDate: selectedDate, turno: turno));
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

  List<CuadranteDay> getEventForDay(DateTime day) {
    final events = LinkedHashMap<DateTime, List<CuadranteDay>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(cuadranteMap);
    return events[day] ?? [];
  }

  Future<Map<DateTime, List<CuadranteDay>>> fetchCuadrante() async {
    cuadrante.value = await DBHelper.db.getItemModels();
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
    return cuadranteMap;
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
  RxList<Task> listEvent2 = <Task>[].obs;

  getListEvent() async {
    listEvent.value = await DbProvider.instance.getNotesFromDB();
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

  List<Task> getEventsOfDay(DateTime day) {
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

    DBHelper.db.deleteItemID(id);
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
