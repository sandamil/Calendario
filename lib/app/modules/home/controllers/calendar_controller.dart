import 'dart:collection';

import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {

  RxMap<DateTime, List<Cuadrante>> cuadranteMap =
      <DateTime, List<Cuadrante>>{}.obs;


 DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;

  Rx<CalendarFormat> get calendarFormat => _calendarFormat;
 get selectedDay => _selectedDay;
  var focusedDay = DateTime.now();

  setFocusedDay(DateTime day) => _focusedDay;

  onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(selectedDate, _selectedDay)) {
      _selectedDay = selectedDate;
      _focusedDay = focusedDate;
      update();
    }
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
}
