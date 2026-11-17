import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendario2/app/modules/sync/views/sync_view.dart';

void main() {
  testWidgets(
    'la pantalla de sincronización mantiene el modo local si Supabase no está disponible',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SyncView()));
      await tester.pumpAndSettle();
      expect(find.text('Servicios en la nube no disponibles'), findsOneWidget);
      expect(find.textContaining('modo local'), findsOneWidget);
    },
  );
}
