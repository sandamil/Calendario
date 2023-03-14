import 'dart:collection';

import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/turnoCalendar.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxMap<DateTime, List<Cuadrante>> cuadranteMap =
      <DateTime, List<Cuadrante>>{}.obs;

  RxList<Cuadrante> cuadrante = <Cuadrante>[].obs;

  RxBool isReady = false.obs;

  // DateTime focusedDay = DateTime.now();
  // DateTime selectedDay = DateTime.now();
  var selectedDay = DateTime.now();
  var focusedDay = DateTime.now();
  // RxList<TurnoType> turno = <TurnoType>[].obs;
  // RxString turnoDay = ''.obs;
  // final CalendarController calendarController = CalendarController();
  // RxMap<DateTime, List<dynamic>> events = <DateTime, List<dynamic>>{}.obs;
  // RxMap<DateTime, List<Cuadrante>> visibleEvents = Map<DateTime, List<Cuadrante>>().obs;
  late ValueNotifier<List<Cuadrante>> selectedEvents;
  // RxList<dynamic> selectedTurnos = <dynamic>[].obs;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }



  void onInit() async {
    await fetchCuadrante();
    super.onInit();
  }




  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  List<Cuadrante> getEventForDay(DateTime day) {
    final events = LinkedHashMap<DateTime, List<Cuadrante>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(cuadranteMap);
    return events[day] ?? [];
  }

  // void onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
  //   print('CALLBACK: onVisibleDaysChanged');
  //
  //
  // }

  void onDaySelected(DateTime newSelectedDay, DateTime newFocusDay) {
    if (!isSameDay(selectedDay, newSelectedDay)) {
      // update
      selectedDay = newSelectedDay;
      focusedDay = newFocusDay;

      selectedEvents.value = getEventForDay(newSelectedDay);
    }
    update();
  }

  // Future<List<TurnoType>> fetchTurno() async {
  //   turno.value = await TurnoDbProvider.instance.getTypeModels();
  //   return turno;
  // }

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
