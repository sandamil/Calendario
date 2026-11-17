import 'package:flutter/foundation.dart';

import '../../data/local/recovery_service.dart';
import 'recovery_file_picker.dart';

typedef RecoveryPreviewAction = Future<BackupPreview> Function(Uint8List bytes);
typedef RecoveryRestoreAction = Future<RecoveryResult> Function(
  Uint8List bytes, {
  required bool preserveExisting,
});
typedef RecoveryPreserveAction = Future<PreservationReport> Function();
typedef RecoveryReadPreservedAction = Future<Uint8List> Function(String path);

enum RecoveryControllerStatus {
  idle,
  reading,
  previewReady,
  preserving,
  restoring,
  restored,
  cancelled,
  failed,
}

class RecoveryController extends ChangeNotifier {
  RecoveryController({
    required this.picker,
    required this.previewBackup,
    required this.restoreBackup,
    required this.preserveCurrentDatabases,
    required this.readPreservedBytes,
    required this.retryBootstrap,
  });

  final RecoveryBackupPicker picker;
  final RecoveryPreviewAction previewBackup;
  final RecoveryRestoreAction restoreBackup;
  final RecoveryPreserveAction preserveCurrentDatabases;
  final RecoveryReadPreservedAction readPreservedBytes;
  final Future<void> Function() retryBootstrap;

  Uint8List? selectedBackupBytes;
  BackupPreview? preview;
  PreservationReport? preservation;
  RecoveryControllerStatus status = RecoveryControllerStatus.idle;
  String? errorMessage;
  bool _disposed = false;

  bool get isBusy =>
      status == RecoveryControllerStatus.reading ||
      status == RecoveryControllerStatus.preserving ||
      status == RecoveryControllerStatus.restoring;

  Future<void> pickBackup() async {
    _set(status: RecoveryControllerStatus.reading, error: null);
    try {
      final bytes = await picker.pickBackupBytes();
      if (bytes == null) {
        _set(status: RecoveryControllerStatus.cancelled);
        return;
      }
      final nextPreview = await previewBackup(bytes);
      selectedBackupBytes = bytes;
      preview = nextPreview;
      _set(status: RecoveryControllerStatus.previewReady);
    } catch (error) {
      _set(status: RecoveryControllerStatus.failed, error: error.toString());
    }
  }

  Future<bool> restoreAfterConfirmation({
    required bool confirmed,
    required bool preserveExisting,
  }) async {
    if (!confirmed ||
        selectedBackupBytes == null ||
        preview == null ||
        isBusy) {
      return false;
    }
    _set(status: RecoveryControllerStatus.restoring, error: null);
    try {
      final result = await restoreBackup(
        selectedBackupBytes!,
        preserveExisting: preserveExisting,
      );
      if (!result.succeeded) {
        throw StateError('La restauración no terminó correctamente.');
      }
      preservation = result.preservation;
      _set(status: RecoveryControllerStatus.restored);
      try {
        await retryBootstrap();
      } catch (error) {
        _set(
          status: RecoveryControllerStatus.failed,
          error: 'Datos restaurados; no se pudo reintentar el arranque: $error',
        );
      }
      return true;
    } catch (error) {
      _set(status: RecoveryControllerStatus.failed, error: error.toString());
      return false;
    }
  }

  Future<PreservationReport?> preserveCurrent() async {
    if (isBusy) return null;
    _set(status: RecoveryControllerStatus.preserving, error: null);
    try {
      preservation = await preserveCurrentDatabases();
      _set(status: RecoveryControllerStatus.idle);
      return preservation;
    } catch (error) {
      _set(status: RecoveryControllerStatus.failed, error: error.toString());
      return null;
    }
  }

  Future<bool> exportSelectedBackup() async {
    final bytes = selectedBackupBytes;
    if (bytes == null) return false;
    try {
      return await picker.saveBytes(bytes, 'calendario2_backup.json');
    } catch (error) {
      _set(status: RecoveryControllerStatus.failed, error: error.toString());
      return false;
    }
  }

  Future<bool> exportPreservedCopy(String path, String suggestedName) async {
    try {
      final bytes = await readPreservedBytes(path);
      return await picker.saveBytes(bytes, suggestedName);
    } catch (error) {
      _set(status: RecoveryControllerStatus.failed, error: error.toString());
      return false;
    }
  }

  void _set({RecoveryControllerStatus? status, String? error}) {
    if (status != null) this.status = status;
    errorMessage = error;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
