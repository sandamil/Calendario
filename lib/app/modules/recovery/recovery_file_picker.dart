import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract interface class RecoveryBackupPicker {
  Future<Uint8List?> pickBackupBytes();
  Future<bool> saveBytes(Uint8List bytes, String suggestedName);
}

class PlatformRecoveryBackupPicker implements RecoveryBackupPicker {
  const PlatformRecoveryBackupPicker();

  @override
  Future<Uint8List?> pickBackupBytes() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    return file.readAsBytes();
  }

  @override
  Future<bool> saveBytes(Uint8List bytes, String suggestedName) async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Guardar copia de recuperación',
      fileName: suggestedName,
      bytes: bytes,
      mimeType: 'application/octet-stream',
    );
    return path != null;
  }
}
