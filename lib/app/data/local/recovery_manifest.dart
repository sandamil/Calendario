import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart' as p;

/// Describes a durable, replayable replacement of the two application DBs.
class RecoveryManifest {
  RecoveryManifest({
    required this.version,
    required this.operationId,
    required this.calendarTargetPath,
    required this.notesTargetPath,
    required this.calendarStagePath,
    required this.notesStagePath,
    required this.calendarSha256,
    required this.notesSha256,
  }) {
    _validateFields();
  }

  final int version;
  final String operationId;
  final String calendarTargetPath;
  final String notesTargetPath;
  final String calendarStagePath;
  final String notesStagePath;
  final String calendarSha256;
  final String notesSha256;

  static const int currentVersion = 1;
  static const Set<String> _keys = {
    'version',
    'operationId',
    'calendarTargetPath',
    'notesTargetPath',
    'calendarStagePath',
    'notesStagePath',
    'calendarSha256',
    'notesSha256',
  };
  static final RegExp _operationIdPattern = RegExp(r'^[0-9a-f]{32}$');
  static final RegExp _sha256Pattern = RegExp(r'^[0-9a-fA-F]{64}$');
  static final RegExp _controlCharacterPattern = RegExp(r'[\u0000-\u001F]');

  factory RecoveryManifest.fromJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('El manifiesto no es JSON válido: $error', source);
    }
    if (decoded is! Map) {
      throw FormatException('El manifiesto debe ser un objeto JSON.', source);
    }
    try {
      return RecoveryManifest.fromMap(Map<String, Object?>.from(decoded));
    } on FormatException {
      rethrow;
    } on TypeError catch (error) {
      throw FormatException('El manifiesto contiene tipos inválidos: $error');
    }
  }

  factory RecoveryManifest.fromMap(Map<String, Object?> map) {
    if (map.length != _keys.length || !map.keys.toSet().containsAll(_keys)) {
      throw const FormatException(
        'El manifiesto tiene campos ausentes o extra.',
      );
    }
    final version = map['version'];
    if (version is! int) {
      throw const FormatException('La versión del manifiesto debe ser entera.');
    }
    final operationId = map['operationId'];
    final calendarTargetPath = map['calendarTargetPath'];
    final notesTargetPath = map['notesTargetPath'];
    final calendarStagePath = map['calendarStagePath'];
    final notesStagePath = map['notesStagePath'];
    final calendarSha256 = map['calendarSha256'];
    final notesSha256 = map['notesSha256'];
    if (operationId is! String ||
        calendarTargetPath is! String ||
        notesTargetPath is! String ||
        calendarStagePath is! String ||
        notesStagePath is! String ||
        calendarSha256 is! String ||
        notesSha256 is! String) {
      throw const FormatException('El manifiesto contiene tipos inválidos.');
    }
    return RecoveryManifest(
      version: version,
      operationId: operationId,
      calendarTargetPath: calendarTargetPath,
      notesTargetPath: notesTargetPath,
      calendarStagePath: calendarStagePath,
      notesStagePath: notesStagePath,
      calendarSha256: calendarSha256,
      notesSha256: notesSha256,
    );
  }

  static String generateOperationId() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  Map<String, Object?> toJson() => {
    'version': version,
    'operationId': operationId,
    'calendarTargetPath': calendarTargetPath,
    'notesTargetPath': notesTargetPath,
    'calendarStagePath': calendarStagePath,
    'notesStagePath': notesStagePath,
    'calendarSha256': calendarSha256,
    'notesSha256': notesSha256,
  };

  String toJsonString() => jsonEncode(toJson());

  void validatePaths(RecoveryManifestPathPolicy policy) {
    if (calendarTargetPath != policy.calendarTargetPath ||
        notesTargetPath != policy.notesTargetPath ||
        calendarStagePath != policy.calendarStagePath(operationId) ||
        notesStagePath != policy.notesStagePath(operationId)) {
      throw const FormatException(
        'Las rutas del manifiesto no corresponden a esta operación.',
      );
    }
    final allPaths = {
      calendarTargetPath,
      notesTargetPath,
      calendarStagePath,
      notesStagePath,
    };
    if (allPaths.length != 4) {
      throw const FormatException('El manifiesto reutiliza una ruta de base.');
    }
  }

  void _validateFields() {
    if (version != currentVersion) {
      throw FormatException('Versión de manifiesto no compatible: $version.');
    }
    if (!_operationIdPattern.hasMatch(operationId)) {
      throw const FormatException('Identificador de operación inválido.');
    }
    for (final path in [
      calendarTargetPath,
      notesTargetPath,
      calendarStagePath,
      notesStagePath,
    ]) {
      if (path.isEmpty || _controlCharacterPattern.hasMatch(path)) {
        throw const FormatException('Ruta vacía o con caracteres inválidos.');
      }
    }
    if (!_sha256Pattern.hasMatch(calendarSha256) ||
        !_sha256Pattern.hasMatch(notesSha256)) {
      throw const FormatException('Checksum SHA-256 inválido.');
    }
  }
}

/// Resolves the only target and stage paths a manifest may name.
class RecoveryManifestPathPolicy {
  const RecoveryManifestPathPolicy({
    required this.calendarTargetPath,
    required this.notesTargetPath,
  });

  final String calendarTargetPath;
  final String notesTargetPath;

  String calendarStagePath(String operationId) =>
      _stagePath(calendarTargetPath, operationId);

  String notesStagePath(String operationId) =>
      _stagePath(notesTargetPath, operationId);

  String _stagePath(String targetPath, String operationId) {
    final stageName = '.${p.basename(targetPath)}.recovery-$operationId.stage';
    final parent = p.dirname(targetPath);
    return parent == '.' ? stageName : p.join(parent, stageName);
  }
}
