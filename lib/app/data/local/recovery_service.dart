import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import 'backup_service.dart';
import 'calendarDatabase.dart';
import 'recovery_manifest.dart';
import 'recovery_manifest_store.dart';
import 'persistence_coordinator.dart';
import 'taskDatabase.dart';

class RecoveryDatabasePaths {
  const RecoveryDatabasePaths({
    required this.calendarTargetPath,
    required this.notesTargetPath,
  });

  final String calendarTargetPath;
  final String notesTargetPath;
}

typedef RecoveryDatabasePathResolver = Future<RecoveryDatabasePaths> Function();

abstract interface class RecoveryByteStore {
  Future<bool> exists(String path);
  Future<Uint8List> read(String path);
  Future<void> write(String path, Uint8List bytes);
  Future<void> delete(String path);
}

class SqfliteRecoveryByteStore implements RecoveryByteStore {
  const SqfliteRecoveryByteStore(this.databaseFactory);

  final DatabaseFactory databaseFactory;

  @override
  Future<bool> exists(String path) => databaseFactory.databaseExists(path);

  @override
  Future<Uint8List> read(String path) =>
      databaseFactory.readDatabaseBytes(path);

  @override
  Future<void> write(String path, Uint8List bytes) =>
      databaseFactory.writeDatabaseBytes(path, bytes);

  @override
  Future<void> delete(String path) => databaseFactory.deleteDatabase(path);
}

class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.cuadranteCount,
    required this.turnosCount,
    required this.themeCount,
    required this.notesCount,
  });

  final DateTime createdAt;
  final int cuadranteCount;
  final int turnosCount;
  final int themeCount;
  final int notesCount;
}

class StagedRecovery {
  const StagedRecovery({required this.manifest, required this.preview});

  final RecoveryManifest manifest;
  final BackupPreview preview;
}

class PreservedDatabaseCopy {
  const PreservedDatabaseCopy({required this.available, this.path, this.error});

  final bool available;
  final String? path;
  final Object? error;
}

class PreservationReport {
  const PreservationReport({required this.calendar, required this.notes});

  final PreservedDatabaseCopy calendar;
  final PreservedDatabaseCopy notes;

  bool get complete =>
      (calendar.available || calendar.error == null) &&
      (notes.available || notes.error == null);
}

class RecoveryResult {
  const RecoveryResult({required this.succeeded, this.preservation});

  final bool succeeded;
  final PreservationReport? preservation;
}

class DatabaseInspection {
  const DatabaseInspection({
    required this.bytesAvailable,
    required this.bytesReadable,
    required this.openSucceeded,
    required this.integrityStatus,
    this.detail,
  });

  final bool bytesAvailable;
  final bool bytesReadable;
  final bool openSucceeded;
  final String integrityStatus;
  final String? detail;
}

class RecoveryDiagnostics {
  const RecoveryDiagnostics({
    required this.calendar,
    required this.notes,
    required this.legacyJournalStatus,
    required this.externalManifestStatus,
    this.detail,
  });

  final DatabaseInspection calendar;
  final DatabaseInspection notes;
  final String legacyJournalStatus;
  final String externalManifestStatus;
  final String? detail;
}

class RecoveryService {
  RecoveryService({
    required this.databaseFactory,
    required this.pathResolver,
    required this.manifestStore,
    RecoveryByteStore? byteStore,
  }) : byteStore = byteStore ?? SqfliteRecoveryByteStore(databaseFactory);

  final DatabaseFactory databaseFactory;
  final RecoveryDatabasePathResolver pathResolver;
  final RecoveryManifestStore manifestStore;
  final RecoveryByteStore byteStore;
  final Map<String, Database> _webInspectionHandles = {};

  Future<void> closeInspectionDatabases() async {
    final handles = _webInspectionHandles.values.toSet().toList();
    _webInspectionHandles.clear();
    for (final database in handles) {
      try {
        await database.close();
      } catch (_) {
        // The normal singleton may already have closed this shared Web handle.
      }
    }
  }

  Future<Uint8List> readPreservedDatabaseBytes(String path) =>
      byteStore.read(path);

  Future<PreservationReport> preserveCurrentDatabasesForNewOperation() =>
      preserveCurrentDatabases(RecoveryManifest.generateOperationId());

  /// Reads file availability and SQLite integrity without invoking the normal
  /// repository open paths or allowing schema migrations.
  Future<RecoveryDiagnostics> inspect() async {
    final targets = await pathResolver();
    final calendar = await _inspectDatabase(targets.calendarTargetPath);
    final notes = await _inspectDatabase(targets.notesTargetPath);
    var journalStatus = 'unavailable';
    if (calendar.openSucceeded) {
      try {
        final db = await databaseFactory.openDatabase(
          targets.calendarTargetPath,
          options: OpenDatabaseOptions(readOnly: true, singleInstance: kIsWeb),
        );
        if (kIsWeb) _webInspectionHandles[targets.calendarTargetPath] = db;
        try {
          final journalTable = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'backup_restore_journal'",
          );
          if (journalTable.isEmpty) {
            journalStatus = 'none';
          } else {
            final rows = await db.query('backup_restore_journal');
            if (rows.isEmpty) {
              journalStatus = 'empty';
            } else {
              if (rows.length != 1) {
                throw StateError(
                  'El diario SQLite contiene varias operaciones.',
                );
              }
              final row = rows.single;
              final phase = row['phase'];
              if (phase != 'prepared' && phase != 'complete') {
                throw StateError('La fase del diario SQLite no es válida.');
              }
              final calendarSnapshot = jsonDecode(
                row['calendar_snapshot'] as String,
              );
              final notesSnapshot = jsonDecode(row['notes_snapshot'] as String);
              if (calendarSnapshot is! Map || notesSnapshot is! List) {
                throw StateError(
                  'El contenido del diario SQLite no es válido.',
                );
              }
              journalStatus = phase as String;
            }
          }
        } finally {
          if (!kIsWeb) await db.close();
        }
      } catch (error) {
        journalStatus = 'corrupt';
      }
    } else if (calendar.bytesAvailable) {
      journalStatus = 'unreadable';
    } else {
      journalStatus = 'none';
    }

    var manifestStatus = 'none';
    String? detail;
    try {
      final manifest = await manifestStore.read();
      if (manifest != null) manifestStatus = 'pending';
    } catch (error) {
      manifestStatus = 'invalid';
      detail = error.toString();
    }
    return RecoveryDiagnostics(
      calendar: calendar,
      notes: notes,
      legacyJournalStatus: journalStatus,
      externalManifestStatus: manifestStatus,
      detail: detail,
    );
  }

  Future<DatabaseInspection> _inspectDatabase(String path) async {
    var available = false;
    var readable = false;
    var opened = false;
    var integrity = 'unavailable';
    String? detail;
    try {
      available = await byteStore.exists(path);
      if (!available) {
        return const DatabaseInspection(
          bytesAvailable: false,
          bytesReadable: false,
          openSucceeded: false,
          integrityStatus: 'missing',
        );
      }
      await byteStore.read(path);
      readable = true;
      final database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: kIsWeb),
      );
      opened = true;
      if (kIsWeb) _webInspectionHandles[path] = database;
      try {
        await _requireHealthyDatabase(database, path);
        integrity = 'ok';
      } catch (error) {
        integrity = 'corrupt';
        detail = error.toString();
      } finally {
        if (!kIsWeb) await database.close();
      }
    } catch (error) {
      detail = error.toString();
      integrity = opened ? 'corrupt' : 'unopenable';
    }
    return DatabaseInspection(
      bytesAvailable: available,
      bytesReadable: readable,
      openSucceeded: opened,
      integrityStatus: integrity,
      detail: detail,
    );
  }

  /// Copies each currently existing database to a new, operation-specific
  /// path. Existing copies are never overwritten and copies are never cleaned
  /// up automatically.
  Future<PreservationReport> preserveCurrentDatabases(
    String operationId,
  ) async {
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(operationId)) {
      throw const FormatException('Identificador de operación inválido.');
    }
    final targets = await pathResolver();
    final calendar = await _preserveOne(
      targets.calendarTargetPath,
      'calendar',
      operationId,
    );
    final notes = await _preserveOne(
      targets.notesTargetPath,
      'notes',
      operationId,
    );
    return PreservationReport(calendar: calendar, notes: notes);
  }

  Future<PreservedDatabaseCopy> _preserveOne(
    String target,
    String label,
    String operationId,
  ) async {
    try {
      if (!await byteStore.exists(target)) {
        return const PreservedDatabaseCopy(available: false);
      }
      final parent = target.substring(0, target.lastIndexOf('/') + 1);
      final base = target.substring(target.lastIndexOf('/') + 1);
      for (var attempt = 0; attempt < 10; attempt++) {
        final suffix = attempt == 0 ? '' : '-$attempt';
        final path =
            '$parent.$base.recovery-$operationId-$label$suffix.preserve';
        if (await byteStore.exists(path)) continue;
        final original = await byteStore.read(target);
        await byteStore.write(path, original);
        final copy = await byteStore.read(path);
        if (sha256.convert(copy) != sha256.convert(original)) {
          throw StateError('La copia preservada no coincide: $path');
        }
        return PreservedDatabaseCopy(available: true, path: path);
      }
      throw StateError('No se encontró una ruta libre para preservar $label.');
    } catch (error) {
      return PreservedDatabaseCopy(available: false, error: error);
    }
  }

  Future<RecoveryResult> restoreBackup(
    Uint8List backupBytes, {
    required bool preserveExisting,
  }) => PersistenceCoordinator.runExclusiveRecovery(
    () => _restoreBackup(backupBytes, preserveExisting: preserveExisting),
  );

  Future<RecoveryResult> _restoreBackup(
    Uint8List backupBytes, {
    required bool preserveExisting,
  }) async {
    if (await manifestStore.read() != null) {
      throw StateError('Hay una recuperación pendiente; reinténtala primero.');
    }
    PreservationReport? preservation;
    if (preserveExisting) {
      preservation = await preserveCurrentDatabases(
        RecoveryManifest.generateOperationId(),
      );
      if (!preservation.complete) {
        throw StateError(
          'No se pudieron preservar todas las bases existentes: '
          '${preservation.calendar.error ?? preservation.notes.error}',
        );
      }
    }
    final staged = await stageBackup(backupBytes);
    await manifestStore.create(staged.manifest);
    await _replayPendingManifest();
    return RecoveryResult(succeeded: true, preservation: preservation);
  }

  /// Replays an interrupted pair replacement. The manifest remains durable
  /// until both final databases pass integrity and schema checks.
  Future<void> replayPendingManifest() =>
      PersistenceCoordinator.runExclusiveRecovery(_replayPendingManifest);

  Future<void> _replayPendingManifest() async {
    final manifest = await manifestStore.read();
    if (manifest == null) return;
    final targets = await pathResolver();
    final policy = RecoveryManifestPathPolicy(
      calendarTargetPath: targets.calendarTargetPath,
      notesTargetPath: targets.notesTargetPath,
    );
    manifest.validatePaths(policy);

    final calendarBytes = await byteStore.read(manifest.calendarStagePath);
    final notesBytes = await byteStore.read(manifest.notesStagePath);
    if (sha256.convert(calendarBytes).toString() != manifest.calendarSha256 ||
        sha256.convert(notesBytes).toString() != manifest.notesSha256) {
      throw const FormatException('El checksum del staging no coincide.');
    }
    await _validateDatabaseFile(manifest.calendarStagePath, isCalendar: true);
    await _validateDatabaseFile(manifest.notesStagePath, isCalendar: false);

    // Close app handles before replacing their files. Recovery constructors
    // never open these canonical paths and have no notification side effects.
    await CalendarioDB.db.closeDb();
    await NotasDB.instance.close();
    await byteStore.write(manifest.calendarTargetPath, calendarBytes);
    await byteStore.write(manifest.notesTargetPath, notesBytes);

    await _validateDatabaseFile(manifest.calendarTargetPath, isCalendar: true);
    await _validateDatabaseFile(manifest.notesTargetPath, isCalendar: false);
    await manifestStore.clear(manifest.operationId);
  }

  Future<void> _validateDatabaseFile(
    String path, {
    required bool isCalendar,
  }) async {
    final database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    try {
      await _requireHealthyDatabase(database, path);
      final tables = (await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name']).toSet();
      final expectedColumns = isCalendar
          ? {
              'Cuadrante': {'id', 'datetime', 'startHour', 'endHour'},
              'Turnos': {'id', 'title', 'startHour', 'endHour'},
              'theme': {'id'},
            }
          : {
              'Notas': {
                'id',
                'title',
                'startTimeMilliseconds',
                'endTimeMilliseconds',
              },
            };
      if (!tables.containsAll(expectedColumns.keys)) {
        throw FormatException('La base $path no tiene el esquema esperado.');
      }
      for (final entry in expectedColumns.entries) {
        final columns = (await database.rawQuery(
          'PRAGMA table_info(${entry.key})',
        )).map((row) => row['name']).toSet();
        if (!columns.containsAll(entry.value)) {
          throw FormatException(
            'La tabla ${entry.key} no tiene las columnas necesarias.',
          );
        }
      }
    } finally {
      await database.close();
    }
  }

  Future<BackupPreview> previewBackup(Uint8List backupBytes) async {
    return _previewFromBackup(_decodeBackup(backupBytes));
  }

  BackupPreview _previewFromBackup(Map<String, dynamic> backup) {
    final data = backup['data'] as Map<String, dynamic>;
    final calendar = Map<String, dynamic>.from(data['calendar'] as Map);
    final notes = Map<String, dynamic>.from(data['notes'] as Map);
    return BackupPreview(
      createdAt: DateTime.parse(backup['createdAt'] as String),
      cuadranteCount: (calendar['Cuadrante'] as List).length,
      turnosCount: (calendar['Turnos'] as List).length,
      themeCount: (calendar['theme'] as List).length,
      notesCount: (notes['Notas'] as List).length,
    );
  }

  /// Creates and validates a current-schema pair without opening the targets.
  /// It returns an in-memory manifest but does not persist it or replace either
  /// target; that commit boundary is implemented by pair replay in Task 4.
  Future<StagedRecovery> stageBackup(Uint8List backupBytes) async {
    final preview = _previewFromBackup(_decodeBackup(backupBytes));
    final backupJson = utf8.decode(backupBytes, allowMalformed: false);
    final targets = await pathResolver();
    if (targets.calendarTargetPath == targets.notesTargetPath) {
      throw StateError('Las rutas canónicas de las bases deben ser distintas.');
    }

    final policy = RecoveryManifestPathPolicy(
      calendarTargetPath: targets.calendarTargetPath,
      notesTargetPath: targets.notesTargetPath,
    );
    final manifest = await _createManifestForUnusedStages(policy);
    final calendar = CalendarioDB.forRecovery(
      factory: databaseFactory,
      path: manifest.calendarStagePath,
    );
    final notes = NotasDB.forRecovery(
      factory: databaseFactory,
      path: manifest.notesStagePath,
    );

    Database? calendarDatabase;
    Database? notesDatabase;
    try {
      calendarDatabase = await calendar.database;
      if (calendarDatabase == null) {
        throw StateError('No se pudo crear el staging del calendario.');
      }
      notesDatabase = await notes.db;

      await AppBackupService.restoreBackupJson(
        backupJson,
        calendarDatabase: calendarDatabase,
        notesDatabase: notesDatabase,
      );
      await _requireHealthyDatabase(calendarDatabase, 'calendario staged');
      await _requireHealthyDatabase(notesDatabase, 'notas staged');

      await calendar.closeDb();
      calendarDatabase = null;
      await notes.close();
      notesDatabase = null;

      final calendarBytes = await byteStore.read(manifest.calendarStagePath);
      final notesBytes = await byteStore.read(manifest.notesStagePath);
      final completedManifest = RecoveryManifest(
        version: RecoveryManifest.currentVersion,
        operationId: manifest.operationId,
        calendarTargetPath: manifest.calendarTargetPath,
        notesTargetPath: manifest.notesTargetPath,
        calendarStagePath: manifest.calendarStagePath,
        notesStagePath: manifest.notesStagePath,
        calendarSha256: sha256.convert(calendarBytes).toString(),
        notesSha256: sha256.convert(notesBytes).toString(),
      );
      completedManifest.validatePaths(policy);
      return StagedRecovery(manifest: completedManifest, preview: preview);
    } catch (error, stackTrace) {
      await _closeStageDatabases(calendar, notes);
      await _deleteUncommittedStages(manifest);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Map<String, dynamic> _decodeBackup(Uint8List backupBytes) {
    final String source;
    try {
      source = utf8.decode(backupBytes, allowMalformed: false);
    } on FormatException {
      throw const FormatException('El backup no contiene UTF-8 válido.');
    }
    return AppBackupService.decodeAndValidateBackup(source);
  }

  Future<RecoveryManifest> _createManifestForUnusedStages(
    RecoveryManifestPathPolicy policy,
  ) async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final operationId = RecoveryManifest.generateOperationId();
      final manifest = RecoveryManifest(
        version: RecoveryManifest.currentVersion,
        operationId: operationId,
        calendarTargetPath: policy.calendarTargetPath,
        notesTargetPath: policy.notesTargetPath,
        calendarStagePath: policy.calendarStagePath(operationId),
        notesStagePath: policy.notesStagePath(operationId),
        // A staging-only placeholder. Final checksums are set after close.
        calendarSha256: List<String>.filled(64, '0').join(),
        notesSha256: List<String>.filled(64, '0').join(),
      );
      if (!await byteStore.exists(manifest.calendarStagePath) &&
          !await byteStore.exists(manifest.notesStagePath)) {
        manifest.validatePaths(policy);
        return manifest;
      }
    }
    throw StateError('No se pudieron reservar rutas temporales únicas.');
  }

  Future<void> _requireHealthyDatabase(Database database, String label) async {
    final result = await database.rawQuery('PRAGMA integrity_check');
    if (result.length != 1 || result.single.values.single != 'ok') {
      throw StateError('La base $label no superó integrity_check.');
    }
  }

  Future<void> _closeStageDatabases(
    CalendarioDB calendar,
    NotasDB notes,
  ) async {
    try {
      await calendar.closeDb();
    } catch (_) {
      // Retain the original staging failure.
    }
    try {
      await notes.close();
    } catch (_) {
      // Retain the original staging failure.
    }
  }

  Future<void> _deleteUncommittedStages(RecoveryManifest manifest) async {
    for (final path in [manifest.calendarStagePath, manifest.notesStagePath]) {
      try {
        if (await byteStore.exists(path)) {
          await byteStore.delete(path);
        }
      } catch (_) {
        // An orphan is safer than masking the original staging error.
      }
    }
  }
}
