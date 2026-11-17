import 'dart:convert';
import 'dart:typed_data';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/recovery_manifest_store_web.dart';
import 'package:calendario2/app/data/local/recovery_service.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class _FailNotesCopy implements RecoveryByteStore {
  _FailNotesCopy(this.delegate, this.notesPath);

  final RecoveryByteStore delegate;
  final String notesPath;
  bool failed = false;

  @override
  Future<bool> exists(String path) => delegate.exists(path);

  @override
  Future<Uint8List> read(String path) => delegate.read(path);

  @override
  Future<void> delete(String path) => delegate.delete(path);

  @override
  Future<void> write(String path, Uint8List bytes) async {
    if (!failed && path == notesPath) {
      failed = true;
      throw StateError('interrupted after calendar database copy');
    }
    await delegate.write(path, bytes);
  }
}

Map<String, Object?> _backup() => {
  'format': 'calendario2.backup',
  'version': 1,
  'createdAt': '2026-11-14T12:00:00.000Z',
  'data': {
    'calendar': {
      'Cuadrante': [
        {
          'id': 811,
          'cuadranteName': 'PWA',
          'title': 'Turno tras recarga',
          'datetime': '2026-11-15T02:30:00+01:00',
          'startHour': '22:00',
          'endHour': '06:00',
          'description': 'IndexedDB',
          'color': 'abc',
        },
      ],
      'Turnos': [
        {
          'id': 812,
          'description': 'Guardia',
          'title': 'Noche',
          'startHour': '22:00',
          'endHour': '06:00',
          'color': 'abc',
          'status': null,
          'reminderEnabled': 1,
          'reminderMinutesBefore': 45,
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
          'id': 813,
          'title': 'Nota tras recarga',
          'site': 'PWA',
          'notes': 'Persistida en IndexedDB',
          'startTimeMilliseconds': 1794706200000,
          'endTimeMilliseconds': 1794709800000,
          'time': '02:30',
          'isImportant': 1,
          'idAlarma': 814,
          'alarmaHora': '02:15',
          'alarmaTimestamp': 1794705300000,
          'alarmaActivadaString': 'true',
          'isAlarmaCreated': 1,
          'notificationMode': 'alarma',
        },
      ],
    },
  },
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('web_indexeddb_localstorage_replay_survives_partial_pair_copy', (
    tester,
  ) async {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final calendarPath = 'calendar-web-integration-$suffix.db';
    final notesPath = 'notes-web-integration-$suffix.db';
    final store = WebRecoveryManifestStore();
    final oldManifest = await store.read();
    if (oldManifest != null) await store.clear(oldManifest.operationId);

    final calendar = CalendarioDB.forTesting(
      factory: databaseFactoryFfiWeb,
      path: calendarPath,
    );
    await calendar.database;
    await calendar.closeDb();
    final notes = NotasDB.forTesting(
      factory: databaseFactoryFfiWeb,
      path: notesPath,
    );
    await notes.db;
    await notes.close();

    RecoveryService createService({RecoveryByteStore? byteStore}) =>
        RecoveryService(
          databaseFactory: databaseFactoryFfiWeb,
          pathResolver: () async => RecoveryDatabasePaths(
            calendarTargetPath: calendarPath,
            notesTargetPath: notesPath,
          ),
          manifestStore: store,
          byteStore: byteStore,
        );

    final first = createService(
      byteStore: _FailNotesCopy(
        SqfliteRecoveryByteStore(databaseFactoryFfiWeb),
        notesPath,
      ),
    );
    final diagnostics = await first.inspect();
    expect(diagnostics.calendar.integrityStatus, 'ok');
    expect(diagnostics.notes.integrityStatus, 'ok');
    await first.closeInspectionDatabases();
    final staged = await first.stageBackup(
      Uint8List.fromList(utf8.encode(jsonEncode(_backup()))),
    );
    await store.create(staged.manifest);
    await expectLater(first.replayPendingManifest(), throwsStateError);
    expect(await store.read(), isNotNull);

    final restarted = createService();
    await restarted.replayPendingManifest();
    expect(await store.read(), isNull);

    final calendarDb = await databaseFactoryFfiWeb.openDatabase(
      calendarPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final notesDb = await databaseFactoryFfiWeb.openDatabase(
      notesPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final shift = (await calendarDb.query('Cuadrante')).single;
    final turno = (await calendarDb.query('Turnos')).single;
    final note = (await notesDb.query('Notas')).single;
    expect(shift['id'], 811);
    expect(shift['datetime'], '2026-11-15T02:30:00+01:00');
    expect(turno['reminderMinutesBefore'], 45);
    expect(turno['reminderMode'], 'alarma');
    expect(note['id'], 813);
    expect(note['alarmaTimestamp'], 1794705300000);
    expect(note['notificationMode'], 'alarma');
    await calendarDb.close();
    await notesDb.close();
    await databaseFactoryFfiWeb.deleteDatabase(calendarPath);
    await databaseFactoryFfiWeb.deleteDatabase(notesPath);
  });
}
