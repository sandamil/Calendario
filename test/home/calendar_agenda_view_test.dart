import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/calendar_agenda_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _CalendarMapNotifier extends CuadranteMapNotifier {
  @override
  Map<DateTime, List<CuadranteDay>> build() => {
    DateTime(2026, 11, 15): [
      CuadranteDay(
        id: 12,
        cuadranteName: 'Turnos sueltos',
        title: 'N',
        description: 'Turno noche',
        startHour: '22:00',
        endHour: '06:00',
        color: '#bd9648',
        dateTime: DateTime(2026, 11, 15),
      ),
    ],
  };
}

class _FocusedDayNotifier extends FocusedMonthNotifier {
  @override
  DateTime build() => DateTime(2026, 11, 15);
}

class _SampleNotesNotifier extends NotasNotifier {
  @override
  List<Task> build() => [
    Task(
      id: 45,
      title: 'Nota del día',
      notes: 'Recordatorio importante',
      startTimeMilliseconds: DateTime(2026, 11, 15, 9).millisecondsSinceEpoch,
      isImportant: true,
    ),
  ];
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  testWidgets(
    'la agenda muestra turnos nocturnos y marca que terminan al día siguiente',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cuadranteMapProvider.overrideWith(_CalendarMapNotifier.new),
            focusedMonthProvider.overrideWith(_FocusedDayNotifier.new),
            notasProvider.overrideWith(_SampleNotesNotifier.new),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, child) => MaterialApp(home: Scaffold(body: child)),
            child: const CalendarAgendaView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Turno noche'), findsOneWidget);
      expect(find.text('22:00 – 06:00'), findsOneWidget);
      expect(find.text('+1 día'), findsOneWidget);
      expect(find.text('1 turno · 1 nota'), findsOneWidget);
      expect(find.text('Nota del día'), findsOneWidget);
      expect(find.text('Turno'), findsOneWidget);
      expect(find.text('Nota'), findsOneWidget);
    },
  );

  testWidgets('el panel de mes muestra eventos sin duplicar botones de alta', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cuadranteMapProvider.overrideWith(_CalendarMapNotifier.new),
          focusedMonthProvider.overrideWith(_FocusedDayNotifier.new),
          notasProvider.overrideWith(_SampleNotesNotifier.new),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, child) => MaterialApp(home: Scaffold(body: child)),
          child: const CalendarAgendaView(showAddActions: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Turno noche'), findsOneWidget);
    expect(find.text('Nota del día'), findsOneWidget);
    expect(find.text('Turno'), findsNothing);
    expect(find.text('Nota'), findsNothing);
  });
}
