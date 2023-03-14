import 'dart:collection';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
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

  RxList<Cuadrante> cuadrante = <Cuadrante>[].obs;

  RxBool isReady = false.obs;

  void onInit() async {
    await fetchCuadrante();
    super.onInit();
  }

  onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(selectedDate, _selectedDay.value)) {
      _selectedDay.value = selectedDate;
      _focusedDay.value = focusedDate;
      update();
    }
    selectedEvents.value = getEventForDay(selectedDay.value);
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
}
