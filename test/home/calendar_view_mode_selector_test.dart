import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/calendar_view_mode_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('permite cambiar entre mes, semana y agenda', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (_, child) => MaterialApp(home: Scaffold(body: child)),
              child: const CalendarViewModeSelector(),
            );
          },
        ),
      ),
    );

    expect(container.read(calendarViewModeProvider), CalendarViewMode.month);
    expect(find.byIcon(Icons.calendar_month_rounded), findsNothing);
    expect(find.byIcon(Icons.view_week_rounded), findsNothing);
    expect(find.byIcon(Icons.view_agenda_rounded), findsNothing);
    final toggle = find.byType(OutlinedButton);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(container.read(calendarViewModeProvider), CalendarViewMode.week);
    expect(find.text('Semana'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(container.read(calendarViewModeProvider), CalendarViewMode.agenda);
    expect(find.text('Agenda'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(container.read(calendarViewModeProvider), CalendarViewMode.month);
    expect(find.text('Mes'), findsOneWidget);
  });
}
