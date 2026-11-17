import 'dart:async';
import 'dart:typed_data';

import 'package:calendario2/app/bootstrap/bootstrap_root.dart';
import 'package:calendario2/app/data/local/recovery_service.dart';
import 'package:calendario2/app/modules/recovery/recovery_controller.dart';
import 'package:calendario2/app/modules/recovery/recovery_file_picker.dart';
import 'package:calendario2/app/modules/recovery/recovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Picker implements RecoveryBackupPicker {
  Uint8List? bytes;
  int saveCalls = 0;
  String? savedName;

  @override
  Future<Uint8List?> pickBackupBytes() async => bytes;

  @override
  Future<bool> saveBytes(Uint8List bytes, String suggestedName) async {
    saveCalls++;
    savedName = suggestedName;
    return true;
  }
}

void main() {
  late _Picker picker;
  late int restores;
  late RecoveryController controller;
  final failure = BootstrapFailure(
    phase: 'persistencia',
    error: StateError('DB damaged'),
    stackTrace: StackTrace.current,
    referenceId: 'REC-1234',
  );

  setUp(() {
    picker = _Picker()..bytes = Uint8List.fromList([1]);
    restores = 0;
    controller = RecoveryController(
      picker: picker,
      previewBackup: (_) async => BackupPreview(
        createdAt: DateTime.utc(2026, 11, 14),
        cuadranteCount: 1,
        turnosCount: 2,
        themeCount: 3,
        notesCount: 4,
      ),
      restoreBackup: (_, {required preserveExisting}) async {
        restores++;
        return const RecoveryResult(succeeded: true);
      },
      preserveCurrentDatabases: () async => const PreservationReport(
        calendar: PreservedDatabaseCopy(available: false),
        notes: PreservedDatabaseCopy(available: false),
      ),
      readPreservedBytes: (_) async => Uint8List(0),
      retryBootstrap: () async {},
    );
  });

  testWidgets('shows_reference_and_expandable_error_without_provider_scope', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: false,
              integrityStatus: 'unopenable',
            ),
            notes: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: true,
              integrityStatus: 'ok',
            ),
            legacyJournalStatus: 'unavailable',
            externalManifestStatus: 'none',
          ),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('REC-1234'), findsOneWidget);
    expect(find.textContaining('Calendario'), findsWidgets);
    expect(find.byType(RecoveryScreen), findsOneWidget);
    expect(find.text('DB damaged'), findsNothing);
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    expect(find.textContaining('DB damaged'), findsOneWidget);
    expect(find.byType(ProviderScope), findsNothing);
  });

  testWidgets('preview_requires_confirmation_and_cancel_does_not_restore', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            notes: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            legacyJournalStatus: 'none',
            externalManifestStatus: 'none',
          ),
          onRetry: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar backup'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Turnos: 2'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Restaurar backup'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelar'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(restores, 0);
  });

  testWidgets('shows_progress_and_disables_duplicate_restore', (tester) async {
    final entered = Completer<void>();
    final release = Completer<void>();
    controller = RecoveryController(
      picker: picker,
      previewBackup: (_) async => BackupPreview(
        createdAt: DateTime.utc(2026, 11, 14),
        cuadranteCount: 1,
        turnosCount: 2,
        themeCount: 3,
        notesCount: 4,
      ),
      restoreBackup: (_, {required preserveExisting}) async {
        restores++;
        entered.complete();
        await release.future;
        return const RecoveryResult(succeeded: true);
      },
      preserveCurrentDatabases: () async => const PreservationReport(
        calendar: PreservedDatabaseCopy(available: false),
        notes: PreservedDatabaseCopy(available: false),
      ),
      readPreservedBytes: (_) async => Uint8List(0),
      retryBootstrap: () async {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: false,
              integrityStatus: 'unopenable',
            ),
            notes: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: false,
              integrityStatus: 'unopenable',
            ),
            legacyJournalStatus: 'unreadable',
            externalManifestStatus: 'none',
          ),
          onRetry: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar backup'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Restaurar backup'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await entered.future;
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Operación en curso…'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Operación en curso…'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Restaurar backup'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final restoreButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Restaurar backup'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(restoreButton.onPressed, isNull);
    release.complete();
    await tester.pumpAndSettle();
    expect(restores, 1);
  });

  testWidgets('retry_is_only_rendered_when_callback_exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            notes: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            legacyJournalStatus: 'none',
            externalManifestStatus: 'none',
          ),
          onRetry: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reintentar arranque'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            notes: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            legacyJournalStatus: 'none',
            externalManifestStatus: 'none',
          ),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reintentar arranque'), findsOneWidget);
  });

  testWidgets('renders_separate_database_and_journal_diagnostics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: false,
              integrityStatus: 'corrupt',
            ),
            notes: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            legacyJournalStatus: 'corrupt',
            externalManifestStatus: 'pending',
          ),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'Bytes: disponibles y legibles; apertura: fallida; integridad: corrupt',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('integridad: missing'), findsOneWidget);
    expect(find.text('Diario SQLite anterior: corrupt'), findsOneWidget);
    expect(find.text('Manifiesto de recuperación: pending'), findsOneWidget);
  });

  testWidgets('shows_verified_result_after_successful_restore', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: false,
              integrityStatus: 'unopenable',
            ),
            notes: DatabaseInspection(
              bytesAvailable: true,
              bytesReadable: true,
              openSucceeded: false,
              integrityStatus: 'unopenable',
            ),
            legacyJournalStatus: 'none',
            externalManifestStatus: 'none',
          ),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar backup'));
    await tester.pumpAndSettle();
    await controller.restoreAfterConfirmation(
      confirmed: true,
      preserveExisting: true,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Las dos bases se restauraron y verificaron.'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Las dos bases se restauraron y verificaron.'),
      findsOneWidget,
    );
  });

  testWidgets('offers_backup_export_when_storage_is_unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecoveryScreen(
          controller: controller,
          failure: failure,
          diagnose: () async => const RecoveryDiagnostics(
            calendar: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            notes: DatabaseInspection(
              bytesAvailable: false,
              bytesReadable: false,
              openSucceeded: false,
              integrityStatus: 'missing',
            ),
            legacyJournalStatus: 'none',
            externalManifestStatus: 'unavailable',
          ),
          onRetry: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar backup'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Exportar backup seleccionado'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Exportar backup seleccionado'));
    await tester.pumpAndSettle();
    expect(picker.saveCalls, 1);
    expect(picker.savedName, 'calendario2_backup.json');
  });

  testWidgets('rescue_screen_handles_narrow_and_wide_viewports', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in [const Size(320, 640), const Size(1280, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: RecoveryScreen(
            controller: controller,
            failure: failure,
            diagnose: () async => const RecoveryDiagnostics(
              calendar: DatabaseInspection(
                bytesAvailable: false,
                bytesReadable: false,
                openSucceeded: false,
                integrityStatus: 'missing',
              ),
              notes: DatabaseInspection(
                bytesAvailable: false,
                bytesReadable: false,
                openSucceeded: false,
                integrityStatus: 'missing',
              ),
              legacyJournalStatus: 'none',
              externalManifestStatus: 'none',
            ),
            onRetry: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
