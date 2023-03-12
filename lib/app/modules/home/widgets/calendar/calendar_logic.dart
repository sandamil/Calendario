import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:table_calendar_sandamil/table_calendar_sandamil.dart';

import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/turnoCalendar.dart';
import '../../../../data/model/turnoType.dart';

class CalendarLogic extends GetxController  with GetSingleTickerProviderStateMixin {
  // final CalendarController calendarController = CalendarController();

  RxMap<DateTime, List<dynamic>> events = <DateTime, List<dynamic>>{}.obs;
  RxMap<DateTime, List<Cuadrante>> visibleEvents = Map<DateTime, List<Cuadrante>>().obs;
  RxMap<DateTime, List<Cuadrante>> cuadranteMap = Map<DateTime, List<Cuadrante>>().obs;

  RxList<Cuadrante> cuadrante = <Cuadrante>[].obs;

  DateTime focusedDay = DateTime.now();

  late List selectedEvents;
  RxList<dynamic> selectedTurnos = <dynamic>[].obs;

  DateTime selectedDay= DateTime.now();

  RxList<TurnoType> turno = <TurnoType>[].obs;

   RxString turnoDay = ''.obs;

  var turnito;



  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  void onInit() async {
    await fetchCuadrante();


    fetchTurno();
    events.value = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(cuadranteMap);

    selectedTurnos.value = cuadranteMap.value[selectedDay] ?? [];
    // _selectedTurnos = cuadranteMap[DateTime(
    //     _selectedDay.year, _selectedDay.month, _selectedDay.day)] ??
    //     [];


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

  // void onDaySelected(DateTime day, List events, List marks, List holidays) {
  //   print('CALLBACK: _onDaySelected');
  //     selectedEvents = marks;
  //     selectedTurnos.value = events;
  //   update();
  // }



  Future<List<TurnoType>> fetchTurno() async {
    turno.value = await TurnoDbProvider.instance.getTypeModels();
    return turno;
  }

  Future<Map<DateTime, List<Cuadrante>>> fetchCuadrante() async {
    cuadrante.value = await TurnoDbProvider.instance.getItemModels();
    for (Cuadrante turno in cuadrante) {
      print(turno.dateTime);
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
    return cuadranteMap.value;
  }



}
