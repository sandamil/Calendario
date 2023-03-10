import 'package:get/get.dart';
import 'package:table_calendar_sandamil/table_calendar_sandamil.dart';

import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/turnoCalendar.dart';
import '../../../../data/model/turnoType.dart';

class CalendarLogic extends GetxController  with GetSingleTickerProviderStateMixin {
  final CalendarController calendarController = CalendarController();

  RxMap<DateTime, List<dynamic>> events = <DateTime, List<dynamic>>{}.obs;
  RxMap<DateTime, List> visibleEvents = <DateTime, List<dynamic>>{}.obs;
  RxMap<DateTime, List<Cuadrante>> cuadranteMap = Map<DateTime, List<Cuadrante>>().obs;

  RxList<Cuadrante> cuadrante = <Cuadrante>[].obs;


  late List selectedEvents;
  late List selectedTurnos;

  RxList<TurnoType> turno = <TurnoType>[].obs;



  void onInit() {
    if (events == null) {
      events = RxMap();
    }
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


  void onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
      visibleEvents.value = Map.fromEntries(
        cuadranteMap.entries.where(
              (entry) =>
          entry.key.isAfter(first.subtract(const Duration(days: 1))) &&
              entry.key.isBefore(last.add(const Duration(days: 1))),
        ),
      );

  }

  void onDaySelected(DateTime day, List events, List marks, List holidays) {
    print('CALLBACK: _onDaySelected');
      selectedEvents = marks;
      selectedTurnos = events;
    update();
  }

  Future<List<TurnoType>> fetchTurno() async {
    turno.value = await TurnoDbProvider.instance.getTypeModels();
    return turno;
  }

  Future<Map<DateTime, List<Cuadrante>>> fetchCuadrante() async {
    cuadrante.value = await TurnoDbProvider.instance.getItemModels();
    for (Cuadrante turno in cuadrante) {
      print(turno.dateTime);
    }
    cuadranteMap.clear();
    for (var turno in cuadrante) {
      cuadranteMap.putIfAbsent(turno.dateTime!, () => <Cuadrante>[]);
      List<Cuadrante>? turnoData = cuadranteMap[turno.dateTime];
      turnoData!.add(turno);
      cuadranteMap.update(turno.dateTime!, (data) {
        return turnoData;
      });
    }
    return cuadranteMap;
  }

}
