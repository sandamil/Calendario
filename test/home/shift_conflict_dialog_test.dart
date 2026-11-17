import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/modules/home/utils/shift_conflict_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CuadranteDay _shift(int id, String start, String end) => CuadranteDay(
  id: id,
  cuadranteName: 'Turnos sueltos',
  title: 'T',
  description: 'Turno $id',
  startHour: start,
  endHour: end,
  color: '#4287f5',
  dateTime: DateTime(2026, 11, 15),
);

void main() {
  testWidgets('pide confirmación y permite cancelar un turno solapado', (
    tester,
  ) async {
    var result = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await confirmShiftConflicts(
                  context,
                  candidate: _shift(2, '23:00', '02:00'),
                  existing: [_shift(1, '22:00', '06:00')],
                );
              },
              child: const Text('Comprobar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Comprobar'));
    await tester.pumpAndSettle();
    expect(find.text('Posible solapamiento'), findsOneWidget);
    expect(find.textContaining('Turno 1 (22:00–06:00)'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets(
    'permite guardar aunque exista un solapamiento si el usuario confirma',
    (tester) async {
      var result = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await confirmShiftConflicts(
                    context,
                    candidate: _shift(2, '23:00', '02:00'),
                    existing: [_shift(1, '22:00', '06:00')],
                  );
                },
                child: const Text('Comprobar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Comprobar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar igualmente'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    },
  );
}
