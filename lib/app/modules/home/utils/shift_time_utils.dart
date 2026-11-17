import '../../../data/model/cuadranteDay.dart';

class ShiftOverlap {
  const ShiftOverlap(this.first, this.second);

  final CuadranteDay first;
  final CuadranteDay second;
}

class ShiftTimeUtils {
  static int? _minutes(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  static int? durationMinutes(String? start, String? end) {
    final startMinutes = _minutes(start);
    final endMinutes = _minutes(end);
    if (startMinutes == null ||
        endMinutes == null ||
        startMinutes == endMinutes) {
      return null;
    }
    return endMinutes > startMinutes
        ? endMinutes - startMinutes
        : (24 * 60 - startMinutes) + endMinutes;
  }

  static DateTime? _start(CuadranteDay item) {
    final date = item.dateTime;
    final minute = _minutes(item.startHour);
    if (date == null || minute == null) {
      return null;
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(minutes: minute));
  }

  static DateTime? _end(CuadranteDay item) {
    final start = _start(item);
    final duration = durationMinutes(item.startHour, item.endHour);
    if (start == null || duration == null) return null;
    return start.add(Duration(minutes: duration));
  }

  static bool _isAllDayOff(CuadranteDay item) {
    final label = '${item.title ?? ''} ${item.description ?? ''}'.toLowerCase();
    return label.contains('libre') ||
        (item.startHour == '00:00' && item.endHour == '23:59');
  }

  static List<ShiftOverlap> findOverlaps(List<CuadranteDay> items) {
    final valid = items.where((item) => !_isAllDayOff(item)).toList()
      ..sort(
        (a, b) => (_start(a) ?? DateTime(1900)).compareTo(
          _start(b) ?? DateTime(1900),
        ),
      );
    final conflicts = <ShiftOverlap>[];
    for (var i = 0; i < valid.length; i++) {
      final firstStart = _start(valid[i]);
      final firstEnd = _end(valid[i]);
      if (firstStart == null || firstEnd == null) continue;
      for (var j = i + 1; j < valid.length; j++) {
        final secondStart = _start(valid[j]);
        final secondEnd = _end(valid[j]);
        if (secondStart == null || secondEnd == null) continue;
        if (!secondStart.isBefore(firstEnd)) break;
        if (firstStart.isBefore(secondEnd) && secondStart.isBefore(firstEnd)) {
          conflicts.add(ShiftOverlap(valid[i], valid[j]));
        }
      }
    }
    return conflicts;
  }
}
