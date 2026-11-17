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

const _backupCreatedAt = '2026-10-21T10:00:00.000Z';

Map<String, Object?> _backup({
  List<Map<String, Object?>>? cuadrantes,
  List<Map<String, Object?>>? turnos,
  List<Map<String, Object?>>? theme,
  List<Map<String, Object?>>? notas,
}) => {
  'format': 'calendario2.backup',
  'version': 1,
  'createdAt': _backupCreatedAt,
  'data': {
    'calendar': {
      'Cuadrante':
          cuadrantes ??
          [
            {
              'id': 23,
              'cuadranteName': 'Rotación A',
              'title': 'Noche',
              'datetime': '2026-10-25T02:30:00+02:00',
              'startHour': '22:00',
              'endHour': '06:00',
              'description': 'Turno conservado',
              'color': 'bd9648',
            },
          ],
      'Turnos':
          turnos ??
          [
            {
              'id': 8,
              'description': 'Guardia',
              'title': 'Noche',
              'startHour': '22:00',
              'endHour': '06:00',
              'color': 'bd9648',
              'status': null,
              'reminderEnabled': 1,
              'reminderMinutesBefore': 45,
              'reminderMode': 'alarma',
            },
          ],
      'theme':
          theme ??
          [
            {'id': 1},
          ],
    },
    'notes': {
      'Notas':
          notas ??
          [
            {
              'id': 91,
              'title': 'Nota con aviso',
              'site': 'Centro',
              'notes': 'Texto original',
              'startTimeMilliseconds': 1792895400000,
              'endTimeMilliseconds': 1792899000000,
              'time': '02:30',
              'isImportant': 1,
              'idAlarma': 501,
              'alarmaHora': '02:15',
              'alarmaTimestamp': 1792894500000,
              'alarmaActivadaString': 'true',
              'isAlarmaCreated': 1,
              'notificationMode': 'alarma',
            },
          ],
    },
  },
};

class _MemoryManifestStore implements RecoveryManifestStore {
  RecoveryManifest? manifest;
  int createCalls = 0;

  @override
  Future<RecoveryManifest?> read() async => manifest;

  @override
  Future<void> create(RecoveryManifest value) async {
    createCalls++;
    manifest = value;
  }

  @override
  Future<void> clear(String operationId) async {
    if (manifest?.operationId == operationId) manifest = null;
  }
}

void main() {
  late Directory directory;
  late String calendarPath;
  late String notesPath;
  late Uint8List originalCalendarBytes;
  late Uint8List originalNotesBytes;
  late _MemoryManifestStore manifestStore;
  late RecoveryService recovery;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('recovery-stage-');
    calendarPath = '${directory.path}/CalendarioAjatsoft.db';
    notesPath = '${directory.path}/notas_database.db';

    final calendar = CalendarioDB.forTesting(
      factory: databaseFactoryFfi,
      path: calendarPath,
    );
    final calendarDb = (await calendar.database)!;
    await calendarDb.insert('Cuadrante', {
      'id': 700,
      'cuadranteName': 'Original',
      'title': 'Mañana',
      'datetime': '2025-05-01',
      'startHour': '07:00',
      'endHour': '15:00',
      'description': 'No debe cambiar',
      'color': '000000',
    });
    await calendar.closeDb();

    final notes = NotasDB.forTesting(
      factory: databaseFactoryFfi,
      path: notesPath,
    );
    final notesDb = await notes.db;
    await notesDb.insert('Notas', {
      'id': 701,
      'title': 'Nota original',
      'site': 'Casa',
      'notes': 'No debe cambiar',
      'startTimeMilliseconds': 1000,
      'endTimeMilliseconds': 2000,
      'time': '00:00',
      'isImportant': 0,
      'idAlarma': 702,
      'alarmaHora': null,
      'alarmaTimestamp': null,
      'alarmaActivadaString': 'false',
      'isAlarmaCreated': 0,
    });
    await notes.close();

    originalCalendarBytes = await databaseFactoryFfi.readDatabaseBytes(
      calendarPath,
    );
    originalNotesBytes = await databaseFactoryFfi.readDatabaseBytes(notesPath);
    manifestStore = _MemoryManifestStore();
    recovery = RecoveryService(
      databaseFactory: databaseFactoryFfi,
      pathResolver: () async => RecoveryDatabasePaths(
        calendarTargetPath: calendarPath,
        notesTargetPath: notesPath,
      ),
      manifestStore: manifestStore,
    );
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'stages_v1_backup_without_opening_or_mutating_canonical_files',
    () async {
      final staged = await recovery.stageBackup(
        Uint8List.fromList(utf8.encode(jsonEncode(_backup()))),
      );

      expect(staged.manifest.calendarTargetPath, calendarPath);
      expect(staged.manifest.notesTargetPath, notesPath);
      expect(staged.manifest.calendarStagePath, isNot(calendarPath));
      expect(staged.manifest.notesStagePath, isNot(notesPath));
      expect(
        await databaseFactoryFfi.readDatabaseBytes(calendarPath),
        originalCalendarBytes,
      );
      expect(
        await databaseFactoryFfi.readDatabaseBytes(notesPath),
        originalNotesBytes,
      );
      expect(await manifestStore.read(), isNull);
      expect(manifestStore.createCalls, 0);
    },
  );

  test(
    'preserves_ids_date_strings_timezone_offsets_and_reminder_fields_in_stages',
    () async {
      final staged = await recovery.stageBackup(
        Uint8List.fromList(utf8.encode(jsonEncode(_backup()))),
      );
      final calendarDb = await databaseFactoryFfi.openDatabase(
        staged.manifest.calendarStagePath,
      );
      final notesDb = await databaseFactoryFfi.openDatabase(
        staged.manifest.notesStagePath,
      );
      addTearDown(calendarDb.close);
      addTearDown(notesDb.close);

      final shift = (await calendarDb.query('Cuadrante')).single;
      final type = (await calendarDb.query('Turnos'))
          .singleWhere((row) => row['id'] == 8);
      final note = (await notesDb.query('Notas')).single;
      expect(shift['id'], 23);
      expect(shift['datetime'], '2026-10-25T02:30:00+02:00');
      expect(type['reminderEnabled'], 1);
      expect(type['reminderMinutesBefore'], 45);
      expect(type['reminderMode'], 'alarma');
      expect(note['id'], 91);
      expect(note['idAlarma'], 501);
      expect(note['alarmaHora'], '02:15');
      expect(note['alarmaTimestamp'], 1792894500000);
      expect(note['notificationMode'], 'alarma');
    },
  );

  test('rejects_duplicate_ids_before_manifest_creation', () async {
    final duplicateBackup = _backup(
      cuadrantes: [
        {'id': 23, 'cuadranteName': 'A', 'datetime': '2026-01-01'},
        {'id': 23, 'cuadranteName': 'B', 'datetime': '2026-01-02'},
      ],
    );

    await expectLater(
      recovery.stageBackup(
        Uint8List.fromList(utf8.encode(jsonEncode(duplicateBackup))),
      ),
      throwsA(anything),
    );
    expect(await manifestStore.read(), isNull);
    expect(manifestStore.createCalls, 0);
    expect(
      await databaseFactoryFfi.readDatabaseBytes(calendarPath),
      originalCalendarBytes,
    );
    expect(
      await databaseFactoryFfi.readDatabaseBytes(notesPath),
      originalNotesBytes,
    );
  });

  test('legacy_v1_rows_receive_current_schema_defaults', () async {
    final legacyBackup = _backup(
      turnos: [
        {
          'id': 12,
          'description': 'Legacy',
          'title': 'Día',
          'startHour': '07:00',
          'endHour': '15:00',
          'color': '000000',
        },
      ],
      notas: [
        {
          'id': 92,
          'title': 'Nota legacy',
          'site': 'Biblioteca',
          'notes': 'Sin campos recientes',
        },
      ],
    );
    final staged = await recovery.stageBackup(
      Uint8List.fromList(utf8.encode(jsonEncode(legacyBackup))),
    );
    final calendarDb = await databaseFactoryFfi.openDatabase(
      staged.manifest.calendarStagePath,
    );
    final notesDb = await databaseFactoryFfi.openDatabase(
      staged.manifest.notesStagePath,
    );
    addTearDown(calendarDb.close);
    addTearDown(notesDb.close);

    final type = (await calendarDb.query('Turnos')).single;
    final note = (await notesDb.query('Notas')).single;
    expect(type['reminderEnabled'], 0);
    expect(type['reminderMinutesBefore'], 0);
    expect(type['reminderMode'], 'notificacion');
    expect(note['notificationMode'], 'notificacion');
    expect(note['alarmaTimestamp'], isNull);
  });

  test('reports_counts_from_preview', () async {
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(_backup())));

    final preview = await recovery.previewBackup(bytes);

    expect(preview.createdAt, DateTime.parse(_backupCreatedAt));
    expect(preview.cuadranteCount, 1);
    expect(preview.turnosCount, 1);
    expect(preview.themeCount, 1);
    expect(preview.notesCount, 1);
  });
}
