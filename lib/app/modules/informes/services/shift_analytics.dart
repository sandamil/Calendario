import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/cuadranteDay.dart';

class SalarySettings {
  const SalarySettings({
    this.hourlyRate = 0,
    this.nightExtraPerHour = 0,
    this.weekendExtraPerHour = 0,
  });

  final double hourlyRate;
  final double nightExtraPerHour;
  final double weekendExtraPerHour;

  double estimate(ShiftAnalyticsResult result) =>
      result.totalHours * hourlyRate +
      result.nightHours * nightExtraPerHour +
      result.weekendHours * weekendExtraPerHour;

  SalarySettings copyWith({
    double? hourlyRate,
    double? nightExtraPerHour,
    double? weekendExtraPerHour,
  }) => SalarySettings(
    hourlyRate: hourlyRate ?? this.hourlyRate,
    nightExtraPerHour: nightExtraPerHour ?? this.nightExtraPerHour,
    weekendExtraPerHour: weekendExtraPerHour ?? this.weekendExtraPerHour,
  );
}

class SalarySettingsStore {
  static const _hourlyRateKey = 'salary_hourly_rate';
  static const _nightExtraKey = 'salary_night_extra';
  static const _weekendExtraKey = 'salary_weekend_extra';

  Future<SalarySettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SalarySettings(
      hourlyRate: prefs.getDouble(_hourlyRateKey) ?? 0,
      nightExtraPerHour: prefs.getDouble(_nightExtraKey) ?? 0,
      weekendExtraPerHour: prefs.getDouble(_weekendExtraKey) ?? 0,
    );
  }

  Future<void> save(SalarySettings settings) async {
    _validateRate(settings.hourlyRate, 'tarifa por hora');
    _validateRate(settings.nightExtraPerHour, 'plus nocturno');
    _validateRate(settings.weekendExtraPerHour, 'plus de fin de semana');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_hourlyRateKey, settings.hourlyRate);
    await prefs.setDouble(_nightExtraKey, settings.nightExtraPerHour);
    await prefs.setDouble(_weekendExtraKey, settings.weekendExtraPerHour);
  }

  void _validateRate(double value, String label) {
    if (!value.isFinite || value < 0 || value > 10000) {
      throw ArgumentError('Valor no válido para $label.');
    }
  }
}

class ShiftAnalyticsResult {
  const ShiftAnalyticsResult({
    required this.totalHours,
    required this.nightHours,
    required this.weekendHours,
    required this.workedShifts,
    required this.freeDays,
    required this.weekendShifts,
    required this.invalidShifts,
    required this.distribution,
  });

  final double totalHours;
  final double nightHours;
  final double weekendHours;
  final int workedShifts;
  final int freeDays;
  final int weekendShifts;
  final int invalidShifts;
  final Map<String, int> distribution;
}

class ShiftAnalytics {
  static ShiftAnalyticsResult calculate(Iterable<CuadranteDay> source) {
    var totalMinutes = 0;
    var nightMinutes = 0;
    var weekendMinutes = 0;
    var worked = 0;
    var free = 0;
    var weekendShifts = 0;
    var invalid = 0;
    final distribution = <String, int>{};

    for (final row in source) {
      if (_isFree(row)) {
        free++;
        continue;
      }
      final date = row.dateTime;
      final startMinute = _parseMinutes(row.startHour);
      final endMinute = _parseMinutes(row.endHour);
      if (date == null || startMinute == null || endMinute == null) {
        invalid++;
        continue;
      }

      final start = DateTime(
        date.year,
        date.month,
        date.day,
        startMinute ~/ 60,
        startMinute % 60,
      );
      var end = DateTime(
        date.year,
        date.month,
        date.day,
        endMinute ~/ 60,
        endMinute % 60,
      );
      if (!end.isAfter(start)) end = end.add(const Duration(days: 1));
      final duration = end.difference(start).inMinutes;
      if (duration <= 0 || duration > 24 * 60) {
        invalid++;
        continue;
      }

      worked++;
      totalMinutes += duration;
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        weekendShifts++;
      }
      final label = (row.description?.trim().isNotEmpty ?? false)
          ? row.description!.trim()
          : ((row.title?.trim().isNotEmpty ?? false)
                ? row.title!.trim()
                : 'Sin nombre');
      distribution[label] = (distribution[label] ?? 0) + 1;

      nightMinutes += _nightOverlapMinutes(start, end);
      weekendMinutes += _weekendOverlapMinutes(start, end);
    }

    return ShiftAnalyticsResult(
      totalHours: totalMinutes / 60,
      nightHours: nightMinutes / 60,
      weekendHours: weekendMinutes / 60,
      workedShifts: worked,
      freeDays: free,
      weekendShifts: weekendShifts,
      invalidShifts: invalid,
      distribution: Map.unmodifiable(distribution),
    );
  }

  static bool _isFree(CuadranteDay row) {
    final title = row.title?.trim().toLowerCase();
    final description = row.description?.trim().toLowerCase();
    return title == 'l' || description == 'libre';
  }

  static int? _parseMinutes(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
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

  static int _overlapMinutes(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    final start = aStart.isAfter(bStart) ? aStart : bStart;
    final end = aEnd.isBefore(bEnd) ? aEnd : bEnd;
    return end.isAfter(start) ? end.difference(start).inMinutes : 0;
  }

  static int _nightOverlapMinutes(DateTime start, DateTime end) {
    var minutes = 0;
    var day = DateTime(
      start.year,
      start.month,
      start.day,
    ).subtract(const Duration(days: 1));
    final lastDay = DateTime(end.year, end.month, end.day);
    while (!day.isAfter(lastDay)) {
      final nightStart = DateTime(day.year, day.month, day.day, 22);
      final nightEnd = DateTime(
        day.year,
        day.month,
        day.day,
      ).add(const Duration(days: 1, hours: 6));
      minutes += _overlapMinutes(start, end, nightStart, nightEnd);
      day = day.add(const Duration(days: 1));
    }
    return minutes;
  }

  static int _weekendOverlapMinutes(DateTime start, DateTime end) {
    var minutes = 0;
    var day = DateTime(start.year, start.month, start.day);
    final lastDay = DateTime(end.year, end.month, end.day);
    while (!day.isAfter(lastDay)) {
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        final dayEnd = day.add(const Duration(days: 1));
        minutes += _overlapMinutes(start, end, day, dayEnd);
      }
      day = day.add(const Duration(days: 1));
    }
    return minutes;
  }
}
