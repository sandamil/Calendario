import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/recovery_manifest_store_native.dart';
import 'package:calendario2/app/data/local/recovery_service.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native_database_bytes_can_be_staged_replaced_and_reopened', (
    tester,
  ) async {
    final support = await getApplicationSupportDirectory();
    final operationDirectory = Directory(
      '${support.path}/recovery-integration-${DateTime.now().microsecondsSinceEpoch}',
    );
    await operationDirectory.create(recursive: true);
    final calendarPath = '${operationDirectory.path}/CalendarioAjatsoft.db';
    final notesPath = '${operationDirectory.path}/notas_database.db';
    final manifestDirectory = Directory('${operationDirectory.path}/manifest');
    await manifestDirectory.create(recursive: true);

    final calendar = CalendarioDB.forTesting(
      factory: databaseFactory,
      path: calendarPath,
    );
    await calendar.database;
    await calendar.closeDb();
    final notes = NotasDB.forTesting(factory: databaseFactory, path: notesPath);
    await notes.db;
    await notes.close();

    final manifestStore = NativeRecoveryManifestStore.forTesting(
      directory: manifestDirectory,
    );
    final service = RecoveryService(
      databaseFactory: databaseFactory,
      pathResolver: () async => RecoveryDatabasePaths(
        calendarTargetPath: calendarPath,
        notesTargetPath: notesPath,
      ),
      manifestStore: manifestStore,
    );
    final backup = {
      'format': 'calendario2.backup',
      'version': 1,
      'createdAt': '2026-11-14T12:00:00.000Z',
      'data': {
        'calendar': {
          'Cuadrante': [
            {
              'id': 901,
              'cuadranteName': 'Android/iOS',
              'title': 'Turno nativo',
              'datetime': '2026-11-15',
              'startHour': '08:00',
              'endHour': '16:00',
              'description': 'Prueba de persistencia',
              'color': 'abc',
            },
          ],
          'Turnos': [
            {
              'id': 902,
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
              'id': 903,
              'title': 'Nota nativa',
              'site': 'Casa',
              'notes': 'Restaurada',
              'startTimeMilliseconds': 1000,
              'endTimeMilliseconds': 2000,
              'time': '00:00',
              'isImportant': 1,
              'idAlarma': 904,
              'alarmaHora': '07:30',
              'alarmaTimestamp': 1500,
              'alarmaActivadaString': 'true',
              'isAlarmaCreated': 1,
              'notificationMode': 'alarma',
            },
          ],
        },
      },
    };

    final result = await service.restoreBackup(
      Uint8List.fromList(utf8.encode(jsonEncode(backup))),
      preserveExisting: false,
    );
    expect(result.succeeded, isTrue);
    expect(await manifestStore.read(), isNull);

    final calendarDb = await databaseFactory.openDatabase(
      calendarPath,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    final notesDb = await databaseFactory.openDatabase(
      notesPath,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    expect((await calendarDb.query('Cuadrante')).single['id'], 901);
    expect(
      (await calendarDb.query('Turnos')).single['reminderMinutesBefore'],
      30,
    );
    expect((await notesDb.query('Notas')).single['id'], 903);
    expect((await notesDb.query('Notas')).single['alarmaTimestamp'], 1500);
    await calendarDb.close();
    await notesDb.close();

    await databaseFactory.deleteDatabase(calendarPath);
    await databaseFactory.deleteDatabase(notesPath);
    await operationDirectory.delete(recursive: true);
  });
}
