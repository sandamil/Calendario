import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/modules/informes/services/shift_analytics.dart';

CuadranteDay shift(
  DateTime date,
  String start,
  String end, {
  String title = 'N',
  String description = 'Noche',
}) => CuadranteDay(
  dateTime: date,
  startHour: start,
  endHour: end,
  title: title,
  description: description,
);

void main() {
  group('ShiftAnalytics', () {
    test('calculates a daytime shift and excludes a free day', () {
      final result = ShiftAnalytics.calculate([
        shift(
          DateTime(2026, 11, 16),
          '07:00',
          '15:00',
          title: 'M',
          description: 'Mañana',
        ),
        shift(
          DateTime(2026, 11, 17),
          '00:00',
          '23:59',
          title: 'L',
          description: 'Libre',
        ),
      ]);
      expect(result.totalHours, 8);
      expect(result.workedShifts, 1);
      expect(result.freeDays, 1);
      expect(result.nightHours, 0);
    });

    test('calculates overnight duration and night premium hours', () {
      final result = ShiftAnalytics.calculate([
        shift(DateTime(2026, 11, 16), '22:00', '07:00'),
      ]);
      expect(result.totalHours, 9);
      expect(result.nightHours, 8);
    });

    test('splits weekend hours at midnight for a Friday night shift', () {
      final result = ShiftAnalytics.calculate([
        shift(DateTime(2026, 11, 20), '22:00', '06:00'),
      ]);
      expect(result.totalHours, 8);
      expect(result.weekendHours, 6);
      expect(result.nightHours, 8);
      expect(result.weekendShifts, 0);
    });

    test('calculates a Saturday day shift as weekend work', () {
      final result = ShiftAnalytics.calculate([
        shift(DateTime(2026, 11, 21), '08:00', '16:00'),
      ]);
      expect(result.weekendHours, 8);
      expect(result.weekendShifts, 1);
    });

    test('rejects malformed and longer-than-24-hour entries', () {
      final result = ShiftAnalytics.calculate([
        shift(DateTime(2026, 11, 16), '99:00', '07:00'),
        shift(DateTime(2026, 11, 16), '08:00', '09:00'),
      ]);
      expect(result.invalidShifts, 1);
      expect(result.totalHours, 1);
    });

    test('estimates gross pay from configured base and premiums', () {
      final result = ShiftAnalytics.calculate([
        shift(DateTime(2026, 11, 16), '22:00', '06:00'),
      ]);
      const settings = SalarySettings(hourlyRate: 12, nightExtraPerHour: 3);
      expect(settings.estimate(result), 120);
    });

    test(
      'persists salary settings locally and rejects negative rates',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = SalarySettingsStore();
        const settings = SalarySettings(
          hourlyRate: 14.5,
          nightExtraPerHour: 2.25,
          weekendExtraPerHour: 1.5,
        );
        await store.save(settings);
        final loaded = await store.load();
        expect(loaded.hourlyRate, 14.5);
        expect(loaded.nightExtraPerHour, 2.25);
        expect(loaded.weekendExtraPerHour, 1.5);
        expect(
          () => store.save(const SalarySettings(hourlyRate: -1)),
          throwsArgumentError,
        );
      },
    );
  });
}
