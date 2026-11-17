import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendario2/app/bootstrap/startup_sequence.dart';
import 'package:calendario2/app/data/local/backup_service.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/recovery_manifest.dart';
import 'package:calendario2/app/data/local/recovery_manifest_store.dart';
import 'package:calendario2/app/data/local/recovery_service.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _ManifestStore implements RecoveryManifestStore {
  RecoveryManifest? value;

  @override
  Future<RecoveryManifest?> read() async => value;

  @override
  Future<void> create(RecoveryManifest manifest) async {
    if (value != null) throw StateError('pending manifest');
    value = manifest;
  }

  @override
  Future<void> clear(String operationId) async {
    if (value?.operationId != operationId) {
      throw StateError('wrong recovery operation');
    }
    value = null;
  }
}

Map<String, Object?> _backup(String title) => {
  'format': 'calendario2.backup',
  'version': 1,
  'createdAt': '2026-11-14T12:00:00.000Z',
  'data': {
    'calendar': {
      'Cuadrante': [
        {
          'id': 10,
          'cuadranteName': 'A',
          'title': title,
          'datetime': '2026-11-14',
          'startHour': '07:00',
          'endHour': '15:00',
          'description': 'turno',
          'color': 'fff',
        },
      ],
      'Turnos': [
        {
          'id': 11,
          'description': 'Guardia',
          'title': 'Noche',
          'startHour': '22:00',
          'endHour': '06:00',
          'color': 'abc',
          'status': null,
          'reminderEnabled': 1,
          'reminderMinutesBefore': 30,
          'reminderMode': 'alarma',
        },
      ],
      'theme': [
        {'id': 1},
      ],
    },
    'notes': {
      'Notas': [
        {
          'id': 12,
          'title': title,
          'site': 'Casa',
          'notes': 'nota',
          'startTimeMilliseconds': 1000,
          'endTimeMilliseconds': 2000,
          'time': '00:00',
          'isImportant': 0,
          'idAlarma': 0,
          'alarmaHora': null,
          'alarmaTimestamp': null,
          'alarmaActivadaString': 'false',
          'isAlarmaCreated': 0,
          'notificationMode': 'notificacion',
        },
      ],
    },
  },
};

void main() {
  late Directory directory;
  late String calendarPath;
  late String notesPath;
  late _ManifestStore manifests;
  late RecoveryService service;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bootstrap-recovery-');
    calendarPath = '${directory.path}/CalendarioAjatsoft.db';
    notesPath = '${directory.path}/notas_database.db';
    manifests = _ManifestStore();
    service = RecoveryService(
      databaseFactory: databaseFactoryFfi,
      pathResolver: () async => RecoveryDatabasePaths(
        calendarTargetPath: calendarPath,
        notesTargetPath: notesPath,
      ),
      manifestStore: manifests,
    );
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<(CalendarioDB, NotasDB)> createDatabases() async {
    final calendar = CalendarioDB.forTesting(
      factory: databaseFactoryFfi,
      path: calendarPath,
    );
    await calendar.database;
    final notes = NotasDB.forTesting(
      factory: databaseFactoryFfi,
      path: notesPath,
    );
    await notes.db;
    return (calendar, notes);
  }

  test('first_launch_without_database_files_creates_current_schema', () async {
    final before = await service.inspect();
    expect(before.calendar.integrityStatus, 'missing');
    expect(before.notes.integrityStatus, 'missing');
    expect(await databaseFactoryFfi.databaseExists(calendarPath), isFalse);
    expect(await databaseFactoryFfi.databaseExists(notesPath), isFalse);

    final (calendar, notes) = await createDatabases();
    final calendarDb = (await calendar.database)!;
    final notesDb = await notes.db;
    expect(
      (await calendarDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      )).map((row) => row['name']),
      containsAll(['Cuadrante', 'Turnos', 'theme']),
    );
    expect(
      (await notesDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      )).map((row) => row['name']),
      contains('Notas'),
    );
    await calendar.closeDb();
    await notes.close();
  });

  test('pending_external_manifest_precedes_legacy_database_open', () async {
    await createDatabases();
    final bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(_backup('Restaurado'))),
    );
    final staged = await service.stageBackup(bytes);
    await manifests.create(staged.manifest);
    final order = <String>[];

    await runPreProviderStartup(
      replayExternalManifest: () async {
        order.add('external');
        await service.replayPendingManifest();
      },
      recoverLegacyJournal: () async {
        expect(manifests.value, isNull);
        order.add('legacy');
      },
      initializeNotifications: () async => order.add('notifications'),
      initializeMemory: () async => order.add('memory'),
      initializeDateFormatting: () async => order.add('dates'),
    );

    expect(order.take(2), ['external', 'legacy']);
    final calendar = await databaseFactoryFfi.openDatabase(
      calendarPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final notes = await databaseFactoryFfi.openDatabase(
      notesPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    expect((await calendar.query('Cuadrante')).single['title'], 'Restaurado');
    expect((await notes.query('Notas')).single['title'], 'Restaurado');
    expect(
      (await calendar.query('Turnos')).single['reminderMinutesBefore'],
      30,
    );
    await calendar.close();
    await notes.close();
  });

  test(
    'legacy_prepared_journal_is_recovered_before_provider_initialization',
    () async {
      final (calendar, notes) = await createDatabases();
      final calendarDb = (await calendar.database)!;
      final notesDb = await notes.db;
      await calendarDb.insert('Cuadrante', {
        'id': 51,
        'cuadranteName': 'Antes',
        'title': 'Calendario original',
        'datetime': '2026-11-14',
        'startHour': '08:00',
        'endHour': '16:00',
        'description': '',
        'color': 'fff',
      });
      await notesDb.insert('Notas', {
        'id': 52,
        'title': 'Nota original',
        'site': 'Casa',
        'notes': '',
        'startTimeMilliseconds': 1,
        'endTimeMilliseconds': 2,
        'time': '00:00',
        'isImportant': 0,
        'idAlarma': 0,
        'alarmaActivadaString': 'false',
        'isAlarmaCreated': 0,
        'notificationMode': 'notificacion',
      });
      final calendarSnapshot = {
        'Cuadrante': await calendarDb.query('Cuadrante'),
        'Turnos': await calendarDb.query('Turnos'),
        'theme': await calendarDb.query('theme'),
      };
      final notesSnapshot = await notesDb.query('Notas');
      await calendarDb.execute('''
      CREATE TABLE backup_restore_journal (
        id INTEGER PRIMARY KEY,
        phase TEXT NOT NULL,
        calendar_snapshot TEXT NOT NULL,
        notes_snapshot TEXT NOT NULL
      )
    ''');
      await calendarDb.insert('backup_restore_journal', {
        'id': 1,
        'phase': 'prepared',
        'calendar_snapshot': jsonEncode(calendarSnapshot),
        'notes_snapshot': jsonEncode(notesSnapshot),
      });
      await calendarDb.update('Cuadrante', {'title': 'Escritura parcial'});
      await notesDb.update('Notas', {'title': 'Nota parcial'});
      await calendar.closeDb();
      await notes.close();

      final reopenedCalendar = CalendarioDB.forTesting(
        factory: databaseFactoryFfi,
        path: calendarPath,
      );
      final reopenedNotes = NotasDB.forTesting(
        factory: databaseFactoryFfi,
        path: notesPath,
      );
      final reopenedCalendarDb = (await reopenedCalendar.database)!;
      final reopenedNotesDb = await reopenedNotes.db;
      var providersInitialized = false;

      await runPreProviderStartup(
        replayExternalManifest: () async {},
        recoverLegacyJournal: () => AppBackupService.recoverPendingRestore(
          calendarDatabase: reopenedCalendarDb,
          notesDatabase: reopenedNotesDb,
        ),
        initializeNotifications: () async {},
        initializeMemory: () async {},
        initializeDateFormatting: () async {
          expect(
            (await reopenedCalendarDb.query('Cuadrante')).single['title'],
            'Calendario original',
          );
          expect(
            (await reopenedNotesDb.query('Notas')).single['title'],
            'Nota original',
          );
          providersInitialized = true;
        },
      );

      expect(providersInitialized, isTrue);
      expect(await reopenedCalendarDb.query('backup_restore_journal'), isEmpty);
      await reopenedCalendar.closeDb();
      await reopenedNotes.close();
    },
  );

  test('legacy_corrupt_journal_fails_closed_and_remains_for_rescue', () async {
    final (calendar, notes) = await createDatabases();
    final calendarDb = (await calendar.database)!;
    final notesDb = await notes.db;
    await calendarDb.execute('''
      CREATE TABLE backup_restore_journal (
        id INTEGER PRIMARY KEY,
        phase TEXT NOT NULL,
        calendar_snapshot TEXT NOT NULL,
        notes_snapshot TEXT NOT NULL
      )
    ''');
    await calendarDb.insert('backup_restore_journal', {
      'id': 1,
      'phase': 'prepared',
      'calendar_snapshot': '{truncated',
      'notes_snapshot': '[]',
    });
    final diagnostics = await service.inspect();
    expect(diagnostics.legacyJournalStatus, 'corrupt');

    final order = <String>[];
    await expectLater(
      runPreProviderStartup(
        replayExternalManifest: () async => order.add('external'),
        recoverLegacyJournal: () async {
          order.add('legacy');
          await AppBackupService.recoverPendingRestore(
            calendarDatabase: calendarDb,
            notesDatabase: notesDb,
          );
        },
        initializeNotifications: () async => order.add('notifications'),
        initializeMemory: () async => order.add('memory'),
        initializeDateFormatting: () async => order.add('dates'),
      ),
      throwsA(isA<StateError>()),
    );
    expect(order, ['external', 'legacy']);
    expect(await calendarDb.query('backup_restore_journal'), hasLength(1));
    await calendar.closeDb();
    await notes.close();
  });
}
