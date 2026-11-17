import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/recovery_manifest.dart';
import 'package:calendario2/app/data/local/recovery_manifest_store.dart';
import 'package:calendario2/app/data/local/recovery_service.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, Object?> _backup(String title) => {
  'format': 'calendario2.backup',
  'version': 1,
  'createdAt': '2026-11-14T12:00:00.000Z',
  'data': {
    'calendar': {
      'Cuadrante': [
        {
          'id': 1,
          'cuadranteName': 'A',
          'title': title,
          'datetime': '2026-11-14',
          'startHour': '07:00',
          'endHour': '15:00',
          'description': '',
          'color': 'fff',
        },
      ],
      'Turnos': [],
      'theme': [],
    },
    'notes': {
      'Notas': [
        {
          'id': 2,
          'title': title,
          'site': '',
          'notes': '',
          'startTimeMilliseconds': 1,
          'endTimeMilliseconds': 2,
          'time': '00:00',
          'isImportant': 0,
          'idAlarma': 0,
          'alarmaActivadaString': 'false',
          'isAlarmaCreated': 0,
        },
      ],
    },
  },
};

class _ManifestStore implements RecoveryManifestStore {
  RecoveryManifest? value;
  bool failCreate = false;
  bool failClear = false;

  @override
  Future<RecoveryManifest?> read() async => value;

  @override
  Future<void> create(RecoveryManifest manifest) async {
    if (failCreate) throw const FileSystemException('manifest write failed');
    if (value != null) throw StateError('manifest already exists');
    value = manifest;
  }

  @override
  Future<void> clear(String operationId) async {
    if (failClear) throw const FileSystemException('manifest clear failed');
    if (value?.operationId == operationId) value = null;
  }
}

class _FailingByteStore implements RecoveryByteStore {
  _FailingByteStore(this.delegate);
  final RecoveryByteStore delegate;
  String? failWritePath;
  bool failNextWrite = false;
  String? corruptWritePath;

  @override
  Future<bool> exists(String path) => delegate.exists(path);

  @override
  Future<Uint8List> read(String path) => delegate.read(path);

  @override
  Future<void> write(String path, Uint8List bytes) async {
    if (failNextWrite || path == failWritePath) {
      failNextWrite = false;
      throw FileSystemException('injected write failure', path);
    }
    await delegate.write(
      path,
      path == corruptWritePath ? Uint8List.fromList([1, 2, 3]) : bytes,
    );
  }

  @override
  Future<void> delete(String path) => delegate.delete(path);
}

void main() {
  late Directory dir;
  late String calendarPath;
  late String notesPath;
  late _ManifestStore manifests;
  late RecoveryService service;
  late _FailingByteStore bytes;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('recovery-replay-');
    calendarPath = '${dir.path}/calendar.db';
    notesPath = '${dir.path}/notes.db';
    final calendar = CalendarioDB.forTesting(
      factory: databaseFactoryFfi,
      path: calendarPath,
    );
    await calendar.database;
    await calendar.closeDb();
    final notes = NotasDB.forTesting(
      factory: databaseFactoryFfi,
      path: notesPath,
    );
    await notes.db;
    await notes.close();
    manifests = _ManifestStore();
    bytes = _FailingByteStore(SqfliteRecoveryByteStore(databaseFactoryFfi));
    service = RecoveryService(
      databaseFactory: databaseFactoryFfi,
      pathResolver: () async => RecoveryDatabasePaths(
        calendarTargetPath: calendarPath,
        notesTargetPath: notesPath,
      ),
      manifestStore: manifests,
      byteStore: bytes,
    );
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Uint8List backup(String label) =>
      Uint8List.fromList(utf8.encode(jsonEncode(_backup(label))));

  test('restore_replaces_both_files_and_replay_is_idempotent', () async {
    final result = await service.restoreBackup(
      backup('Recovered'),
      preserveExisting: false,
    );
    expect(result.succeeded, isTrue);
    expect(manifests.value, isNull);
    await service.replayPendingManifest();
    final calendar = await databaseFactoryFfi.openDatabase(
      calendarPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final notes = await databaseFactoryFfi.openDatabase(
      notesPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    expect((await calendar.query('Cuadrante')).single['title'], 'Recovered');
    expect((await notes.query('Notas')).single['title'], 'Recovered');
    await calendar.close();
    await notes.close();
  });

  test('manifest_write_failure_keeps_canonical_pair_unchanged', () async {
    final calendarBefore = await bytes.read(calendarPath);
    final notesBefore = await bytes.read(notesPath);
    manifests.failCreate = true;
    await expectLater(
      service.restoreBackup(backup('Recovered'), preserveExisting: false),
      throwsA(isA<FileSystemException>()),
    );
    expect(await bytes.read(calendarPath), calendarBefore);
    expect(await bytes.read(notesPath), notesBefore);
    expect(manifests.value, isNull);
  });

  test(
    'restore_without_preservation_does_not_create_hidden_database_copies',
    () async {
      await service.restoreBackup(backup('Recovered'), preserveExisting: false);
      expect(
        dir.listSync().where((entry) => entry.path.endsWith('.preserve')),
        isEmpty,
      );
    },
  );

  test('notes_copy_failure_retains_manifest_and_retry_replays_pair', () async {
    final staged = await service.stageBackup(backup('Recovered'));
    manifests.value = staged.manifest;
    bytes.failWritePath = notesPath;
    await expectLater(
      service.replayPendingManifest(),
      throwsA(isA<FileSystemException>()),
    );
    expect(manifests.value, isNotNull);
    bytes.failWritePath = null;
    await service.replayPendingManifest();
    expect(manifests.value, isNull);
  });

  test(
    'restart_after_manifest_before_first_copy_replays_both_databases',
    () async {
      final staged = await service.stageBackup(backup('Recovered'));
      manifests.value = staged.manifest;
      service = RecoveryService(
        databaseFactory: databaseFactoryFfi,
        pathResolver: () async => RecoveryDatabasePaths(
          calendarTargetPath: calendarPath,
          notesTargetPath: notesPath,
        ),
        manifestStore: manifests,
      );
      await service.replayPendingManifest();
      expect(manifests.value, isNull);
      final calendar = await databaseFactoryFfi.openDatabase(
        calendarPath,
        options: OpenDatabaseOptions(readOnly: true),
      );
      final notes = await databaseFactoryFfi.openDatabase(
        notesPath,
        options: OpenDatabaseOptions(readOnly: true),
      );
      expect((await calendar.query('Cuadrante')).single['title'], 'Recovered');
      expect((await notes.query('Notas')).single['title'], 'Recovered');
      await calendar.close();
      await notes.close();
    },
  );

  test('restart_after_calendar_copy_replays_both_databases', () async {
    final staged = await service.stageBackup(backup('Recovered'));
    manifests.value = staged.manifest;
    bytes.failWritePath = notesPath;
    await expectLater(
      service.replayPendingManifest(),
      throwsA(isA<FileSystemException>()),
    );
    bytes = _FailingByteStore(SqfliteRecoveryByteStore(databaseFactoryFfi));
    service = RecoveryService(
      databaseFactory: databaseFactoryFfi,
      pathResolver: () async => RecoveryDatabasePaths(
        calendarTargetPath: calendarPath,
        notesTargetPath: notesPath,
      ),
      manifestStore: manifests,
      byteStore: bytes,
    );
    await service.replayPendingManifest();
    expect(manifests.value, isNull);
    final calendar = await databaseFactoryFfi.openDatabase(
      calendarPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final notes = await databaseFactoryFfi.openDatabase(
      notesPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    expect((await calendar.query('Cuadrante')).single['title'], 'Recovered');
    expect((await notes.query('Notas')).single['title'], 'Recovered');
    await calendar.close();
    await notes.close();
  });

  test(
    'requested_preservation_failure_aborts_before_manifest_or_replacement',
    () async {
      final before = await bytes.read(calendarPath);
      bytes.failNextWrite = true;
      await expectLater(
        service.restoreBackup(backup('Recovered'), preserveExisting: true),
        throwsA(anything),
      );
      expect(manifests.value, isNull);
      expect(await bytes.read(calendarPath), before);
    },
  );

  test('preserves_current_pair_without_overwriting_previous_copies', () async {
    const operation = '0123456789abcdef0123456789abcdef';
    final first = await service.preserveCurrentDatabases(operation);
    expect(first.complete, isTrue);
    expect(first.calendar.available, isTrue);
    expect(first.notes.available, isTrue);
    final firstCalendar = first.calendar.path!;
    final originalCopy = await bytes.read(firstCalendar);
    final second = await service.preserveCurrentDatabases(operation);
    expect(second.calendar.path, isNot(firstCalendar));
    expect(await bytes.read(firstCalendar), originalCopy);
  });

  test(
    'manifest_clear_failure_can_be_retried_after_both_files_were_written',
    () async {
      final staged = await service.stageBackup(backup('Recovered'));
      manifests.value = staged.manifest;
      manifests.failClear = true;
      await expectLater(
        service.replayPendingManifest(),
        throwsA(isA<FileSystemException>()),
      );
      expect(manifests.value, isNotNull);
      manifests.failClear = false;
      await service.replayPendingManifest();
      expect(manifests.value, isNull);
    },
  );

  test(
    'restart_after_both_copies_before_integrity_is_safe_to_replay',
    () async {
      final staged = await service.stageBackup(backup('Recovered'));
      manifests.value = staged.manifest;
      bytes.corruptWritePath = notesPath;
      await expectLater(service.replayPendingManifest(), throwsA(anything));
      expect(manifests.value, isNotNull);
      bytes = _FailingByteStore(SqfliteRecoveryByteStore(databaseFactoryFfi));
      service = RecoveryService(
        databaseFactory: databaseFactoryFfi,
        pathResolver: () async => RecoveryDatabasePaths(
          calendarTargetPath: calendarPath,
          notesTargetPath: notesPath,
        ),
        manifestStore: manifests,
        byteStore: bytes,
      );
      await service.replayPendingManifest();
      expect(manifests.value, isNull);
      final finalNotes = await databaseFactoryFfi.openDatabase(
        notesPath,
        options: OpenDatabaseOptions(readOnly: true),
      );
      expect((await finalNotes.query('Notas')).single['title'], 'Recovered');
      await finalNotes.close();
    },
  );

  test('checksum_mismatch_never_replaces_either_canonical_file', () async {
    final beforeCalendar = await bytes.read(calendarPath);
    final beforeNotes = await bytes.read(notesPath);
    final staged = await service.stageBackup(backup('Recovered'));
    manifests.value = staged.manifest;
    await bytes.write(
      staged.manifest.calendarStagePath,
      Uint8List.fromList([1, 2, 3]),
    );
    await expectLater(
      service.replayPendingManifest(),
      throwsA(isA<FormatException>()),
    );
    expect(await bytes.read(calendarPath), beforeCalendar);
    expect(await bytes.read(notesPath), beforeNotes);
    expect(manifests.value, isNotNull);
  });

  test('missing_stage_never_replaces_either_canonical_file', () async {
    final beforeCalendar = await bytes.read(calendarPath);
    final beforeNotes = await bytes.read(notesPath);
    final staged = await service.stageBackup(backup('Recovered'));
    manifests.value = staged.manifest;
    await bytes.delete(staged.manifest.notesStagePath);
    await expectLater(service.replayPendingManifest(), throwsA(anything));
    expect(await bytes.read(calendarPath), beforeCalendar);
    expect(await bytes.read(notesPath), beforeNotes);
    expect(manifests.value, isNotNull);
  });

  test(
    'missing_original_database_is_reported_but_is_not_a_preservation_error',
    () async {
      await databaseFactoryFfi.deleteDatabase(calendarPath);
      final report = await service.preserveCurrentDatabases(
        'fedcba9876543210fedcba9876543210',
      );
      expect(report.calendar.available, isFalse);
      expect(report.calendar.error, isNull);
      expect(report.notes.available, isTrue);
      expect(report.complete, isTrue);
    },
  );
}
