import 'dart:async';
import 'dart:typed_data';

import 'package:calendario2/app/data/local/recovery_service.dart';
import 'package:calendario2/app/modules/recovery/recovery_controller.dart';
import 'package:calendario2/app/modules/recovery/recovery_file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

class _Picker implements RecoveryBackupPicker {
  Uint8List? picked;
  Object? readError;
  int saveCalls = 0;
  Uint8List? savedBytes;
  String? savedName;
  bool saveResult = true;

  @override
  Future<Uint8List?> pickBackupBytes() async {
    if (readError case final error?) throw error;
    return picked;
  }

  @override
  Future<bool> saveBytes(Uint8List bytes, String suggestedName) async {
    saveCalls++;
    savedBytes = bytes;
    savedName = suggestedName;
    return saveResult;
  }
}

BackupPreview _preview() => BackupPreview(
  createdAt: DateTime.utc(2026, 11, 14),
  cuadranteCount: 3,
  turnosCount: 2,
  themeCount: 1,
  notesCount: 4,
);

PreservationReport _preservation() => const PreservationReport(
  calendar: PreservedDatabaseCopy(available: true, path: '/safe/calendar.db'),
  notes: PreservedDatabaseCopy(available: true, path: '/safe/notes.db'),
);

void main() {
  late _Picker picker;
  late int previewCalls;
  late int restoreCalls;
  late int retryCalls;
  late int preserveCalls;
  late bool? preserveArgument;
  late RecoveryController controller;

  setUp(() {
    picker = _Picker();
    previewCalls = 0;
    restoreCalls = 0;
    retryCalls = 0;
    preserveCalls = 0;
    preserveArgument = null;
    controller = RecoveryController(
      picker: picker,
      previewBackup: (bytes) async {
        previewCalls++;
        if (bytes.isEmpty) throw const FormatException('invalid backup JSON');
        if (bytes.first == 2) {
          throw const FormatException('unsupported backup version');
        }
        return _preview();
      },
      restoreBackup: (bytes, {required preserveExisting}) async {
        restoreCalls++;
        preserveArgument = preserveExisting;
        return const RecoveryResult(succeeded: true);
      },
      preserveCurrentDatabases: () async {
        preserveCalls++;
        return _preservation();
      },
      readPreservedBytes: (path) async => Uint8List.fromList([8, 9]),
      retryBootstrap: () async {
        retryCalls++;
      },
    );
  });

  test('cancelled_picker_does_not_write', () async {
    await controller.pickBackup();
    expect(controller.status, RecoveryControllerStatus.cancelled);
    expect(controller.selectedBackupBytes, isNull);
    expect(previewCalls, 0);
    expect(restoreCalls, 0);
    expect(picker.saveCalls, 0);
  });

  test('read_failure_does_not_write', () async {
    picker.readError = StateError('file unreadable');
    await controller.pickBackup();
    expect(controller.selectedBackupBytes, isNull);
    expect(controller.errorMessage, contains('file unreadable'));
    expect(restoreCalls, 0);
    expect(picker.saveCalls, 0);
  });

  test('invalid_json_shows_error_without_staging', () async {
    picker.picked = Uint8List(0);
    await controller.pickBackup();
    expect(controller.preview, isNull);
    expect(controller.selectedBackupBytes, isNull);
    expect(controller.errorMessage, contains('invalid backup JSON'));
    expect(restoreCalls, 0);
  });

  test('incompatible_v1_shows_error_without_staging', () async {
    picker.picked = Uint8List.fromList([2]);
    await controller.pickBackup();
    expect(controller.preview, isNull);
    expect(controller.selectedBackupBytes, isNull);
    expect(controller.errorMessage, contains('unsupported backup version'));
    expect(restoreCalls, 0);
  });

  test('preview_reports_created_at_and_all_four_row_counts', () async {
    picker.picked = Uint8List.fromList([1]);
    await controller.pickBackup();
    expect(controller.preview?.createdAt, DateTime.utc(2026, 11, 14));
    expect(controller.preview?.cuadranteCount, 3);
    expect(controller.preview?.turnosCount, 2);
    expect(controller.preview?.themeCount, 1);
    expect(controller.preview?.notesCount, 4);
  });

  test('restore_runs_only_after_confirmed_action', () async {
    picker.picked = Uint8List.fromList([1]);
    await controller.pickBackup();
    await controller.restoreAfterConfirmation(
      confirmed: false,
      preserveExisting: true,
    );
    expect(restoreCalls, 0);
    await controller.restoreAfterConfirmation(
      confirmed: true,
      preserveExisting: true,
    );
    expect(restoreCalls, 1);
    expect(preserveArgument, isTrue);
    expect(retryCalls, 1);
    expect(controller.status, RecoveryControllerStatus.restored);
  });

  test(
    'restore_can_skip_optional_preservation_only_when_user_unchecks_it',
    () async {
      picker.picked = Uint8List.fromList([1]);
      await controller.pickBackup();
      await controller.restoreAfterConfirmation(
        confirmed: true,
        preserveExisting: false,
      );
      expect(restoreCalls, 1);
      expect(preserveArgument, isFalse);
    },
  );

  test('restore_error_keeps_recovery_inputs', () async {
    picker.picked = Uint8List.fromList([1]);
    await controller.pickBackup();
    final selected = controller.selectedBackupBytes;
    controller = RecoveryController(
      picker: picker,
      previewBackup: (_) async => _preview(),
      restoreBackup: (_, {required preserveExisting}) async =>
          throw StateError('replacement failed'),
      preserveCurrentDatabases: () async => _preservation(),
      readPreservedBytes: (_) async => Uint8List(0),
      retryBootstrap: () async {},
    );
    await controller.pickBackup();
    final selectedAfterPreview = controller.selectedBackupBytes;
    await controller.restoreAfterConfirmation(
      confirmed: true,
      preserveExisting: false,
    );
    expect(selectedAfterPreview, isNotNull);
    expect(controller.selectedBackupBytes, same(selectedAfterPreview));
    expect(controller.preview, isNotNull);
    expect(controller.errorMessage, contains('replacement failed'));
    expect(controller.status, RecoveryControllerStatus.failed);
    expect(selected, isNotNull);
  });

  test(
    'selected_backup_can_be_exported_if_local_database_storage_is_unavailable',
    () async {
      final selected = Uint8List.fromList([1, 3, 5]);
      picker.picked = selected;
      await controller.pickBackup();
      expect(await controller.exportSelectedBackup(), isTrue);
      expect(picker.saveCalls, 1);
      expect(picker.savedBytes, selected);
      expect(picker.savedName, 'calendario2_backup.json');
    },
  );

  test(
    'preserved_database_can_be_exported_to_user_chosen_destination',
    () async {
      final report = await controller.preserveCurrent();
      expect(preserveCalls, 1);
      expect(report?.complete, isTrue);
      expect(
        await controller.exportPreservedCopy(
          report!.calendar.path!,
          'calendario_preservado.db',
        ),
        isTrue,
      );
      expect(picker.savedName, 'calendario_preservado.db');
      expect(picker.savedBytes, [8, 9]);
    },
  );

  test('successful_restore_retries_bootstrap', () async {
    picker.picked = Uint8List.fromList([1]);
    await controller.pickBackup();
    final restored = await controller.restoreAfterConfirmation(
      confirmed: true,
      preserveExisting: true,
    );
    expect(restored, isTrue);
    expect(retryCalls, 1);
  });

  test(
    'bootstrap_retry_failure_is_reported_without_losing_restored_state',
    () async {
      picker.picked = Uint8List.fromList([1]);
      await controller.pickBackup();
      controller = RecoveryController(
        picker: picker,
        previewBackup: (_) async => _preview(),
        restoreBackup: (_, {required preserveExisting}) async =>
            const RecoveryResult(succeeded: true),
        preserveCurrentDatabases: () async => _preservation(),
        readPreservedBytes: (_) async => Uint8List(0),
        retryBootstrap: () async => throw StateError('startup still fails'),
      );
      await controller.pickBackup();
      expect(
        await controller.restoreAfterConfirmation(
          confirmed: true,
          preserveExisting: false,
        ),
        isTrue,
      );
      expect(controller.status, RecoveryControllerStatus.failed);
      expect(controller.errorMessage, contains('Datos restaurados'));
      expect(controller.errorMessage, contains('startup still fails'));
    },
  );

  test('busy_controller_rejects_second_restore', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    controller = RecoveryController(
      picker: picker,
      previewBackup: (_) async => _preview(),
      restoreBackup: (_, {required preserveExisting}) async {
        entered.complete();
        await release.future;
        return const RecoveryResult(succeeded: true);
      },
      preserveCurrentDatabases: () async => _preservation(),
      readPreservedBytes: (_) async => Uint8List(0),
      retryBootstrap: () async {},
    );
    picker.picked = Uint8List.fromList([1]);
    await controller.pickBackup();
    final first = controller.restoreAfterConfirmation(
      confirmed: true,
      preserveExisting: false,
    );
    await entered.future;
    expect(controller.isBusy, isTrue);
    expect(
      await controller.restoreAfterConfirmation(
        confirmed: true,
        preserveExisting: false,
      ),
      isFalse,
    );
    release.complete();
    await first;
    expect(restoreCalls, 0);
  });
}
