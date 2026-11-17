import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets(
    'los controles anterior y siguiente cambian el mes y el día seleccionado',
    (tester) async {
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (_, child) => MaterialApp(
                  home: Scaffold(appBar: AppBar(title: child)),
                ),
                child: const SelectedDayWidget(),
              );
            },
          ),
        ),
      );

      final initial = container.read(focusedMonthProvider);
      await tester.tap(find.byTooltip('Mes siguiente'));
      await tester.pumpAndSettle();
      final next = container.read(focusedMonthProvider);
      expect(next.year, DateTime(initial.year, initial.month + 1).year);
      expect(next.month, DateTime(initial.year, initial.month + 1).month);
      expect(container.read(selectedDayProvider), next);

      await tester.tap(find.byTooltip('Mes anterior'));
      await tester.pumpAndSettle();
      expect(container.read(focusedMonthProvider).year, initial.year);
      expect(container.read(focusedMonthProvider).month, initial.month);

      container
          .read(calendarViewModeProvider.notifier)
          .setMode(CalendarViewMode.week);
      await tester.pumpAndSettle();
      final weekStart = container.read(selectedDayProvider)!;
      await tester.tap(find.byTooltip('Semana siguiente'));
      await tester.pumpAndSettle();
      expect(
        container.read(selectedDayProvider),
        weekStart.add(const Duration(days: 7)),
      );

      container
          .read(calendarViewModeProvider.notifier)
          .setMode(CalendarViewMode.agenda);
      await tester.pumpAndSettle();
      final agendaDay = container.read(selectedDayProvider)!;
      await tester.tap(find.byTooltip('Día siguiente'));
      await tester.pumpAndSettle();
      expect(
        container.read(selectedDayProvider),
        agendaDay.add(const Duration(days: 1)),
      );
    },
  );
}
