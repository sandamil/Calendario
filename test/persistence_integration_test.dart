import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:calendario2/app/data/local/backup_service.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/persistence_coordinator.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory directory;
  late CalendarioDB calendar;
  late NotasDB notes;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('calendario-db-test-');
    calendar = CalendarioDB.forTesting(
      factory: databaseFactoryFfi,
      path: '${directory.path}/calendar.db',
    );
    notes = NotasDB.forTesting(
      factory: databaseFactoryFfi,
      path: '${directory.path}/notes.db',
    );
  });

  tearDown(() async {
    await calendar.closeDb();
    await notes.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'crea, lee, edita y elimina turnos sin colapsar los del mismo día',
    () async {
      final date = DateTime(2026, 11, 14);
      final nightId = await calendar.addCuadranteItem(
        _shift(date, name: 'Trabajo', title: 'N', start: '22:00', end: '06:00'),
      );
      await calendar.addCuadranteItem(
        _shift(date, name: 'Trabajo', title: 'M', start: '07:00', end: '15:00'),
      );

      expect((await calendar.getCuadranteList()), hasLength(2));
      final night = await calendar.fetchItem(nightId);
      expect(night?.title, 'N');
      expect(night?.startHour, '22:00');
      expect(night?.endHour, '06:00');

      await calendar.updateItem(
        _shift(date, name: 'Trabajo', title: 'N2', start: '21:00', end: '05:00')
          ..id = nightId,
      );

      expect((await calendar.fetchItem(nightId))?.title, 'N2');
      expect(await calendar.getCuadranteList(), hasLength(2));

      await calendar.deleteItemID(nightId);
      expect(await calendar.fetchItem(nightId), isNull);
      expect(await calendar.getCuadranteList(), hasLength(1));
    },
  );

  test(
    'mover una ocurrencia conserva su ID y copiar crea otra fila independiente',
    () async {
      final firstDay = DateTime(2026, 11, 14);
      final secondDay = DateTime(2026, 11, 16);
      final movedId = await calendar.addCuadranteItem(
        _shift(
          firstDay,
          name: 'Turnos sueltos',
          title: 'M',
          start: '07:00',
          end: '15:00',
        ),
      );
      await calendar.addCuadranteItem(
        _shift(
          secondDay,
          name: 'Turnos sueltos',
          title: 'T',
          start: '15:00',
          end: '22:00',
        ),
      );

      await calendar.updateItem(
        _shift(
          secondDay,
          name: 'Turnos sueltos',
          title: 'M',
          start: '07:00',
          end: '15:00',
        )..id = movedId,
      );

      final moved = await calendar.fetchItem(movedId);
      expect(moved?.id, movedId);
      expect(moved?.dateTime, secondDay);
      expect(await calendar.getCuadranteList(), hasLength(2));

      final copiedId = await calendar.addCuadranteItem(
        _shift(
          secondDay,
          name: 'Turnos sueltos',
          title: 'M',
          start: '07:00',
          end: '15:00',
        ),
      );
      expect(copiedId, isNot(movedId));
      expect(await calendar.fetchItem(movedId), isNotNull);
      expect(await calendar.fetchItem(copiedId), isNotNull);
      expect(await calendar.getCuadranteList(), hasLength(3));
    },
  );

  test(
    'intercambia fechas conservando los IDs y crea repeticiones por lotes',
    () async {
      final firstDate = DateTime(2026, 11, 14);
      final secondDate = DateTime(2026, 11, 16);
      final firstId = await calendar.addCuadranteItem(
        _shift(
          firstDate,
          name: 'Turnos sueltos',
          title: 'M',
          start: '07:00',
          end: '15:00',
        ),
      );
      final secondId = await calendar.addCuadranteItem(
        _shift(
          secondDate,
          name: 'Turnos sueltos',
          title: 'N',
          start: '22:00',
          end: '06:00',
        ),
      );

      await calendar.swapCuadranteItemDates(firstId, secondId);
      expect((await calendar.fetchItem(firstId))?.dateTime, secondDate);
      expect((await calendar.fetchItem(firstId))?.title, 'M');
      expect((await calendar.fetchItem(secondId))?.dateTime, firstDate);
      expect((await calendar.fetchItem(secondId))?.title, 'N');

      final repeatedIds = await calendar.addCuadranteItems([
        _shift(
          DateTime(2026, 11, 23),
          name: 'Turnos sueltos',
          title: 'N',
          start: '22:00',
          end: '06:00',
        ),
        _shift(
          DateTime(2026, 11, 30),
          name: 'Turnos sueltos',
          title: 'N',
          start: '22:00',
          end: '06:00',
        ),
      ]);
      expect(repeatedIds, hasLength(2));
      expect(await calendar.fetchItem(repeatedIds.first), isNotNull);
      expect(await calendar.fetchItem(repeatedIds.last), isNotNull);
      expect(await calendar.getCuadranteList(), hasLength(4));
    },
  );

  test('el intercambio de fechas revierte ambas filas si falla la segunda actualización', () async {
    final firstDate = DateTime(2026, 11, 14);
    final secondDate = DateTime(2026, 11, 16);
    final firstId = await calendar.addCuadranteItem(
      _shift(firstDate, name: 'Turnos', title: 'M'),
    );
    final secondId = await calendar.addCuadranteItem(
      _shift(secondDate, name: 'Turnos', title: 'N'),
    );
    await (await calendar.database)!.execute('''
      CREATE TRIGGER fail_second_swap
      BEFORE UPDATE OF datetime ON Cuadrante
      WHEN OLD.id = $secondId
      BEGIN SELECT RAISE(ABORT, 'simulated swap failure'); END
    ''');

    await expectLater(
      calendar.swapCuadranteItemDates(firstId, secondId),
      throwsA(anything),
    );
    expect((await calendar.fetchItem(firstId))?.dateTime, firstDate);
    expect((await calendar.fetchItem(secondId))?.dateTime, secondDate);
  });

  test(
    'la repetición por lotes es atómica si falla una de las inserciones',
    () async {
      await (await calendar.database)!.execute('''
      CREATE TRIGGER fail_second_batch_insert
      BEFORE INSERT ON Cuadrante
      WHEN NEW.datetime = '2026-11-30'
      BEGIN SELECT RAISE(ABORT, 'simulated batch failure'); END
    ''');

      await expectLater(
        calendar.addCuadranteItems([
          _shift(DateTime(2026, 11, 23), name: 'Turnos', title: 'N'),
          _shift(DateTime(2026, 11, 30), name: 'Turnos', title: 'N'),
        ]),
        throwsA(anything),
      );
      expect(await calendar.getCuadranteList(), isEmpty);
    },
  );

  test('deleteTypeId no reentra en el bloqueo de lectura', () async {
    final typeId = await calendar.addTypeModel(
      TurnoType(
        title: 'Especial',
        description: 'Turno especial',
        startHour: '09:00',
        endHour: '17:00',
        color: '123456',
      ),
    );
    final shiftId = await calendar.addCuadranteItem(
      _shift(
          DateTime(2026, 11, 15),
          name: 'Trabajo',
          title: 'Especial',
          start: '09:00',
          end: '17:00',
        )
        ..description = 'Turno especial'
        ..color = '123456',
    );

    await calendar.deleteTypeId(typeId).timeout(const Duration(seconds: 2));

    expect(await calendar.fetchTurnoType(typeId), isNull);
    expect(await calendar.fetchItem(shiftId), isNotNull);
  });

  test(
    'migra esquemas SQLite antiguos sin perder filas ni identificadores',
    () async {
      final calendarPath = '${directory.path}/calendar.db';
      final calendarV1 = await databaseFactoryFfi.openDatabase(
        calendarPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute('''
            CREATE TABLE Cuadrante(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cuadranteName STRING, title STRING, datetime TEXT,
              startHour TEXT, endHour TEXT, description TEXT, color TEXT
            )
          ''');
            await db.execute('''
            CREATE TABLE Turnos(
              id INTEGER PRIMARY KEY, description TEXT, title TEXT,
              startHour TEXT, endHour TEXT, color TEXT, status TEXT
            )
          ''');
            await db.execute('CREATE TABLE theme(id INTEGER NOT NULL)');
          },
        ),
      );
      await calendarV1.insert('Cuadrante', {
        'id': 41,
        'cuadranteName': 'Antiguo',
        'title': 'N',
        'datetime': '2024-02-29',
        'startHour': '22:00',
        'endHour': '06:00',
        'description': 'Noche antigua',
        'color': 'bd9648',
      });
      await calendarV1.insert('Turnos', {
        'id': 8,
        'description': 'Noche antigua',
        'title': 'N',
        'startHour': '22:00',
        'endHour': '06:00',
        'color': 'bd9648',
        'status': null,
      });
      await calendarV1.close();

      final notesPath = '${directory.path}/notes.db';
      final notesV1 = await databaseFactoryFfi.openDatabase(
        notesPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute('''
            CREATE TABLE Notas(
              id INTEGER PRIMARY KEY, title TEXT, site TEXT, notes TEXT,
              startTimeMilliseconds INTEGER, endTimeMilliseconds INTEGER,
              time TEXT, isImportant INTEGER, idAlarma INTEGER,
              alarmaActivadaString TEXT, isAlarmaCreated INTEGER
            )
          ''');
          },
        ),
      );
      await notesV1.insert('Notas', {
        'id': 42,
        'title': 'Nota antigua',
        'site': 'Archivo',
        'notes': 'No perder',
        'startTimeMilliseconds': 1709168400000,
        'endTimeMilliseconds': 1709172000000,
        'time': '10:00',
        'isImportant': 1,
        'idAlarma': 702,
        'alarmaActivadaString': 'true',
        'isAlarmaCreated': 1,
      });
      await notesV1.close();

      calendar = CalendarioDB.forTesting(
        factory: databaseFactoryFfi,
        path: calendarPath,
      );
      notes = NotasDB.forTesting(factory: databaseFactoryFfi, path: notesPath);

      final migratedShift = await calendar.fetchItem(41);
      expect(migratedShift?.title, 'N');
      expect(migratedShift?.dateTime, DateTime(2024, 2, 29));
      expect((await calendar.fetchTurnoType(8))?.reminderMode, 'notificacion');
      final migratedNote = await notes.select(42);
      expect(migratedNote.id, 42);
      expect(migratedNote.site, 'Archivo');
      expect(migratedNote.startTimeMilliseconds, 1709168400000);
      expect(migratedNote.idAlarma, 702);
      expect(migratedNote.notificationMode, 'notificacion');
    },
  );

  test('guarda una rotación de varios días de forma atómica', () async {
    final original = _shift(
      DateTime(2026, 11, 1),
      name: 'Rotación',
      title: 'Original',
      start: '08:00',
      end: '16:00',
    );
    final originalSchedule = [
      original,
      _shift(DateTime(2026, 11, 2), name: 'Rotación', title: 'Original B'),
      _shift(DateTime(2026, 11, 3), name: 'Rotación', title: 'Original C'),
    ];
    await calendar.replaceCuadranteItems('Rotación', originalSchedule);
    expect(await calendar.getCuadranteList(), hasLength(3));

    await (await calendar.database)!.execute('''
      CREATE TRIGGER fail_second_rotation_day
      BEFORE INSERT ON Cuadrante
      WHEN NEW.datetime = '2026-11-02'
      BEGIN SELECT RAISE(ABORT, 'simulated insert failure'); END
    ''');

    await expectLater(
      calendar.replaceCuadranteItems('Rotación', [
        _shift(DateTime(2026, 11, 1), name: 'Rotación', title: 'A'),
        _shift(DateTime(2026, 11, 2), name: 'Rotación', title: 'B'),
        _shift(DateTime(2026, 11, 3), name: 'Rotación', title: 'C'),
      ]),
      throwsA(anything),
    );

    final rows = await calendar.getCuadranteList();
    expect(rows, hasLength(3));
    expect(rows.map((row) => row.title), [
      'Original',
      'Original B',
      'Original C',
    ]);
    expect(rows.map((row) => row.dateTime), [
      DateTime(2026, 11, 1),
      DateTime(2026, 11, 2),
      DateTime(2026, 11, 3),
    ]);
  });

  test(
    'persiste notas, ubicación y recordatorio tras cerrar y reabrir',
    () async {
      final noteId = await notes.insertNotas(
        Task(
          title: 'Cita',
          site: 'Calle Mayor 12, Madrid',
          notes: 'Llevar documentación',
          startTimeMilliseconds: 1794661200000,
          endTimeMilliseconds: 1794664800000,
          idAlarma: 701,
          alarmaHora: '09:00',
          alarmaTimestamp: 1794658800000,
          alarmaActivadaString: 'true',
          isAlarmaCreated: true,
          notificationMode: 'alarma',
        ),
      );
      expect((await notes.select(noteId)).site, 'Calle Mayor 12, Madrid');

      await notes.update(
        Task(
          id: noteId,
          title: 'Cita médica',
          site: 'Calle Mayor 14, Madrid',
          notes: 'Llevar documentación',
          startTimeMilliseconds: 1794661200000,
          endTimeMilliseconds: 1794664800000,
          idAlarma: 701,
          alarmaHora: '09:00',
          alarmaTimestamp: 1794658800000,
          alarmaActivadaString: 'true',
          isAlarmaCreated: true,
          notificationMode: 'alarma',
        ),
      );
      expect((await notes.select(noteId)).notificationMode, 'alarma');

      await calendar.addCuadranteItem(
        _shift(DateTime(2026, 11, 14), name: 'Trabajo', title: 'M'),
      );
      await calendar.closeDb();
      await notes.close();

      calendar = CalendarioDB.forTesting(
        factory: databaseFactoryFfi,
        path: '${directory.path}/calendar.db',
      );
      notes = NotasDB.forTesting(
        factory: databaseFactoryFfi,
        path: '${directory.path}/notes.db',
      );

      expect((await notes.select(noteId)).site, 'Calle Mayor 14, Madrid');
      expect((await notes.select(noteId)).alarmaTimestamp, 1794658800000);
      expect((await calendar.getCuadranteList()), hasLength(1));

      await notes.delete(noteId);
      await expectLater(notes.select(noteId), throwsFormatException);
    },
  );

  test(
    'restaura calendario y notas desde backup v1 sin duplicar registros',
    () async {
      await calendar.replaceCuadranteItems('Turno A', [
        _shift(DateTime(2026, 11, 14), name: 'Turno A', title: 'Tarde'),
        _shift(DateTime(2026, 11, 15), name: 'Turno A', title: 'Noche'),
      ]);
      await notes.insertNotas(
        Task(
          id: 81,
          title: 'Dentista',
          site: 'Plaza Central',
          idAlarma: 701,
          alarmaTimestamp: 1794658800000,
          notificationMode: 'alarma',
        ),
      );

      final backup = await AppBackupService.createBackupJson(
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );
      expect(jsonDecode(backup)['version'], 1);

      await calendar.deleteCuadrante('Turno A');
      await notes.delete(81);
      await AppBackupService.restoreBackupJson(
        backup,
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );
      await AppBackupService.restoreBackupJson(
        backup,
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );

      expect(await calendar.getCuadranteList(), hasLength(2));
      final restoredNote = await notes.select(81);
      expect(restoredNote.site, 'Plaza Central');
      expect(restoredNote.notificationMode, 'alarma');
      expect(restoredNote.idAlarma, 701);
      expect(await notes.getNotesFromDB(), hasLength(1));
      final restoredRows = await (await calendar.database)!.query('Cuadrante');
      expect(restoredRows.map((row) => row['id']), [1, 2]);
      expect(restoredRows.map((row) => row['datetime']), [
        '2026-11-14',
        '2026-11-15',
      ]);
    },
  );

  test('revierte ambas bases si falla la restauración de notas', () async {
    await calendar.replaceCuadranteItems('Existente', [
      _shift(DateTime(2026, 11, 14), name: 'Existente', title: 'Antes'),
    ]);
    await notes.insertNotas(Task(id: 44, title: 'Nota anterior', site: 'Casa'));

    final source = await AppBackupService.createBackupJson(
      calendarDatabase: await calendar.database,
      notesDatabase: await notes.db,
    );
    final backup = jsonDecode(source) as Map<String, dynamic>;
    final data = backup['data'] as Map<String, dynamic>;
    final calendarData = data['calendar'] as Map<String, dynamic>;
    final notesData = data['notes'] as Map<String, dynamic>;
    calendarData['Cuadrante'] = [
      _shift(
        DateTime(2026, 11, 15),
        name: 'Nuevo',
        title: 'No debe quedar',
      ).toMap()..['id'] = 999,
    ];
    notesData['Notas'] = [
      {'id': 900, 'title': 'Duplicada'},
      {'id': 900, 'title': 'Duplicada otra vez'},
    ];

    await expectLater(
      AppBackupService.restoreBackupJson(
        jsonEncode(backup),
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      ),
      throwsA(isA<StateError>()),
    );

    expect((await calendar.getCuadranteList()).single.title, 'Antes');
    expect((await calendar.getCuadranteList()), hasLength(1));
    expect((await notes.select(44)).title, 'Nota anterior');
    expect(await notes.getNotesFromDB(), hasLength(1));
  });

  test(
    'rechaza un backup corrupto antes de alterar cualquiera de las bases',
    () async {
      await calendar.replaceCuadranteItems('Seguro', [
        _shift(DateTime(2026, 11, 14), name: 'Seguro', title: 'Turno guardado'),
      ]);
      await notes.insertNotas(
        Task(id: 45, title: 'Nota guardada', site: 'Casa'),
      );

      await expectLater(
        AppBackupService.restoreBackupJson(
          '{backup incompleto',
          calendarDatabase: await calendar.database,
          notesDatabase: await notes.db,
        ),
        throwsFormatException,
      );

      expect(
        (await calendar.getCuadranteList()).single.title,
        'Turno guardado',
      );
      expect((await notes.select(45)).title, 'Nota guardada');
    },
  );

  test(
    'restaura backups v1 de notas anteriores a los campos de recordatorio',
    () async {
      final legacyBackup = {
        'format': 'calendario2.backup',
        'version': 1,
        'createdAt': '2026-10-21T10:00:00.000Z',
        'data': {
          'calendar': {
            'Cuadrante': <Map<String, Object?>>[],
            'Turnos': <Map<String, Object?>>[],
            'theme': <Map<String, Object?>>[],
          },
          'notes': {
            'Notas': <Map<String, Object?>>[
              {
                'id': 91,
                'title': 'Nota legacy',
                'site': 'Biblioteca',
                'notes': 'Importada desde una copia antigua',
              },
            ],
          },
        },
      };

      await AppBackupService.restoreBackupJson(
        jsonEncode(legacyBackup),
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );

      final restored = await notes.select(91);
      expect(restored.title, 'Nota legacy');
      expect(restored.site, 'Biblioteca');
      expect(restored.notificationMode, 'notificacion');
    },
  );

  test(
    'recupera las dos bases tras reiniciar durante una restauración',
    () async {
      await calendar.replaceCuadranteItems('Trabajo', [
        _shift(DateTime(2026, 11, 14), name: 'Trabajo', title: 'Antes'),
      ]);
      await notes.insertNotas(Task(id: 92, title: 'Nota antes', site: 'Casa'));

      final calendarDb = (await calendar.database)!;
      final notesDb = await notes.db;
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

      // Simulate the calendar commit completing before the process is killed.
      await calendarDb.update(
        'Cuadrante',
        {'title': 'Restauración incompleta'},
        where: 'cuadranteName = ?',
        whereArgs: ['Trabajo'],
      );
      await calendar.closeDb();
      await notes.close();

      calendar = CalendarioDB.forTesting(
        factory: databaseFactoryFfi,
        path: '${directory.path}/calendar.db',
      );
      notes = NotasDB.forTesting(
        factory: databaseFactoryFfi,
        path: '${directory.path}/notes.db',
      );

      await AppBackupService.recoverPendingRestore(
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );
      await AppBackupService.recoverPendingRestore(
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );

      expect((await calendar.getCuadranteList()).single.title, 'Antes');
      expect((await notes.select(92)).title, 'Nota antes');
      expect(
        await (await calendar.database)!.query('backup_restore_journal'),
        isEmpty,
      );
    },
  );

  test('un diario vacío no modifica datos y se diagnostica', () async {
    await calendar.addCuadranteItem(
      _shift(DateTime(2026, 11, 14), name: 'Vacío', title: 'Conservar'),
    );
    final calendarDb = (await calendar.database)!;
    await calendarDb.execute('''
      CREATE TABLE backup_restore_journal (
        id INTEGER PRIMARY KEY,
        phase TEXT NOT NULL,
        calendar_snapshot TEXT NOT NULL,
        notes_snapshot TEXT NOT NULL
      )
    ''');

    final diagnostics = await AppBackupService.inspectRestoreRecovery(
      calendarDatabase: calendarDb,
      notesDatabase: await notes.db,
    );
    expect(diagnostics.journalStatus, 'empty');
    expect(diagnostics.calendarIntegrity, 'ok');
    expect(diagnostics.notesIntegrity, 'ok');

    await AppBackupService.recoverPendingRestore(
      calendarDatabase: calendarDb,
      notesDatabase: await notes.db,
    );
    expect((await calendar.getCuadranteList()).single.title, 'Conservar');
  });

  test(
    'si ambas bases se restauraron pero falta el marcador, revierte ambas',
    () async {
      await calendar.addCuadranteItem(
        _shift(
          DateTime(2026, 11, 14),
          name: 'Trabajo',
          title: 'Calendario anterior',
        ),
      );
      await notes.insertNotas(
        Task(id: 95, title: 'Nota anterior', site: 'Casa'),
      );
      final calendarDb = (await calendar.database)!;
      final notesDb = await notes.db;
      final oldCalendar = <String, Object?>{
        'Cuadrante': await calendarDb.query('Cuadrante'),
        'Turnos': await calendarDb.query('Turnos'),
        'theme': await calendarDb.query('theme'),
      };
      final oldNotes = await notesDb.query('Notas');
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
        'calendar_snapshot': jsonEncode(oldCalendar),
        'notes_snapshot': jsonEncode(oldNotes),
      });

      // Both target transactions committed, but the process died before phase=complete.
      await calendarDb.update(
        'Cuadrante',
        {'title': 'Calendario objetivo'},
        where: 'cuadranteName = ?',
        whereArgs: ['Trabajo'],
      );
      await notesDb.update(
        'Notas',
        {'title': 'Nota objetivo'},
        where: 'id = ?',
        whereArgs: [95],
      );
      await AppBackupService.recoverPendingRestore(
        calendarDatabase: calendarDb,
        notesDatabase: notesDb,
      );

      expect(
        (await calendar.getCuadranteList()).single.title,
        'Calendario anterior',
      );
      expect((await notes.select(95)).title, 'Nota anterior');
    },
  );

  test(
    'si se cierra justo después de crear el diario, recupera el estado intacto',
    () async {
      await calendar.addCuadranteItem(
        _shift(DateTime(2026, 11, 14), name: 'Preparado', title: 'Sin cambios'),
      );
      await notes.insertNotas(
        Task(id: 96, title: 'Nota intacta', site: 'Casa'),
      );
      final calendarDb = (await calendar.database)!;
      final notesDb = await notes.db;
      final oldCalendar = <String, Object?>{
        'Cuadrante': await calendarDb.query('Cuadrante'),
        'Turnos': await calendarDb.query('Turnos'),
        'theme': await calendarDb.query('theme'),
      };
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
        'calendar_snapshot': jsonEncode(oldCalendar),
        'notes_snapshot': jsonEncode(await notesDb.query('Notas')),
      });

      await AppBackupService.recoverPendingRestore(
        calendarDatabase: calendarDb,
        notesDatabase: notesDb,
      );
      expect((await calendar.getCuadranteList()).single.title, 'Sin cambios');
      expect((await notes.select(96)).title, 'Nota intacta');
      expect(await calendarDb.query('backup_restore_journal'), isEmpty);
    },
  );

  test(
    'diagnostica un diario corrupto y permite recuperarlo con backup v1',
    () async {
      await calendar.addCuadranteItem(
        _shift(DateTime(2026, 11, 14), name: 'Guardado', title: 'Original'),
      );
      await notes.insertNotas(Task(id: 93, title: 'Original', site: 'Casa'));
      final validBackup = await AppBackupService.createBackupJson(
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );

      final calendarDb = (await calendar.database)!;
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
        'calendar_snapshot': '{truncado',
        'notes_snapshot': '[]',
      });
      await calendarDb.update(
        'Cuadrante',
        {'title': 'Parcial'},
        where: 'cuadranteName = ?',
        whereArgs: ['Guardado'],
      );

      final diagnostics = await AppBackupService.inspectRestoreRecovery(
        calendarDatabase: calendarDb,
        notesDatabase: await notes.db,
      );
      expect(diagnostics.journalStatus, 'corrupt');
      expect(diagnostics.calendarIntegrity, 'ok');
      expect(diagnostics.notesIntegrity, 'ok');
      await expectLater(
        AppBackupService.recoverPendingRestore(
          calendarDatabase: calendarDb,
          notesDatabase: await notes.db,
        ),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        AppBackupService.restoreBackupJson(
          validBackup,
          calendarDatabase: calendarDb,
          notesDatabase: await notes.db,
        ),
        throwsA(isA<StateError>()),
        reason: 'Una restauración nueva no debe reemplazar un diario corrupto.',
      );
      await expectLater(
        AppBackupService.createBackupJson(
          calendarDatabase: calendarDb,
          notesDatabase: await notes.db,
        ),
        throwsA(isA<StateError>()),
        reason: 'No se debe exportar una instantánea potencialmente mixta.',
      );
      expect(
        await calendarDb.query('backup_restore_journal'),
        hasLength(1),
        reason: 'El diagnóstico no debe borrar el diario sin restauración verificada.',
      );

      await AppBackupService.recoverFromExternalBackupJson(
        validBackup,
        calendarDatabase: calendarDb,
        notesDatabase: await notes.db,
      );
      expect((await calendar.getCuadranteList()).single.title, 'Original');
      expect((await notes.select(93)).title, 'Original');
      expect(await calendarDb.query('backup_restore_journal'), isEmpty);
    },
  );

  test(
    'un snapshot original ausente queda diagnosticado y no se elimina',
    () async {
      await calendar.addCuadranteItem(
        _shift(DateTime(2026, 11, 14), name: 'Rescate', title: 'Original'),
      );
      final calendarDb = (await calendar.database)!;
      final source = await AppBackupService.createBackupJson(
        calendarDatabase: calendarDb,
        notesDatabase: await notes.db,
      );
      final calendarSnapshot =
          ((jsonDecode(source) as Map<String, dynamic>)['data']
              as Map<String, dynamic>)['calendar'];
      await calendarDb.execute('''
      CREATE TABLE backup_restore_journal (
        id INTEGER PRIMARY KEY,
        phase TEXT NOT NULL,
        calendar_snapshot TEXT,
        notes_snapshot TEXT
      )
    ''');
      await calendarDb.insert('backup_restore_journal', {
        'id': 1,
        'phase': 'prepared',
        'calendar_snapshot': jsonEncode(calendarSnapshot),
        'notes_snapshot': null,
      });

      final diagnostics = await AppBackupService.inspectRestoreRecovery(
        calendarDatabase: calendarDb,
        notesDatabase: await notes.db,
      );
      expect(diagnostics.journalStatus, 'corrupt');
      await expectLater(
        AppBackupService.recoverPendingRestore(
          calendarDatabase: calendarDb,
          notesDatabase: await notes.db,
        ),
        throwsA(isA<StateError>()),
      );
      expect(await calendarDb.query('backup_restore_journal'), hasLength(1));

      await AppBackupService.recoverFromExternalBackupJson(
        source,
        calendarDatabase: calendarDb,
        notesDatabase: await notes.db,
      );
      expect((await calendar.getCuadranteList()).single.title, 'Original');
    },
  );

  test(
    'el fallo al escribir el diario no empieza una restauración parcial',
    () async {
      await calendar.addCuadranteItem(
        _shift(DateTime(2026, 11, 14), name: 'Seguro', title: 'Antes'),
      );
      await notes.insertNotas(Task(id: 94, title: 'Antes', site: 'Casa'));
      final source = await AppBackupService.createBackupJson(
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );
      final calendarDb = (await calendar.database)!;
      await calendarDb.execute('''
      CREATE TABLE backup_restore_journal (
        id INTEGER PRIMARY KEY,
        phase TEXT NOT NULL,
        calendar_snapshot TEXT NOT NULL,
        notes_snapshot TEXT NOT NULL
      )
    ''');
      await calendarDb.execute('''
      CREATE TRIGGER refuse_restore_journal
      BEFORE INSERT ON backup_restore_journal
      BEGIN SELECT RAISE(ABORT, 'simulated full disk'); END
    ''');

      await expectLater(
        AppBackupService.restoreBackupJson(
          source,
          calendarDatabase: calendarDb,
          notesDatabase: await notes.db,
        ),
        throwsA(anything),
      );
      expect((await calendar.getCuadranteList()).single.title, 'Antes');
      expect((await notes.select(94)).title, 'Antes');
      expect(await calendarDb.query('backup_restore_journal'), isEmpty);
    },
  );

  test(
    'preserva el estado restaurado si no se puede limpiar el diario completo',
    () async {
      await calendar.addCuadranteItem(
        _shift(DateTime(2026, 11, 14), name: 'Completo', title: 'Aplicado'),
      );
      final calendarDb = (await calendar.database)!;
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
        'phase': 'complete',
        'calendar_snapshot': '{}',
        'notes_snapshot': '[]',
      });
      await calendarDb.execute('''
      CREATE TRIGGER prevent_journal_cleanup
      BEFORE DELETE ON backup_restore_journal
      BEGIN SELECT RAISE(ABORT, 'simulated cleanup interruption'); END
    ''');

      for (var attempt = 0; attempt < 2; attempt++) {
        await AppBackupService.recoverPendingRestore(
          calendarDatabase: calendarDb,
          notesDatabase: await notes.db,
        );
      }
      expect((await calendar.getCuadranteList()).single.title, 'Aplicado');
      expect(await calendarDb.query('backup_restore_journal'), hasLength(1));
    },
  );

  test('no limpia journal complete si integrity_check falla', () async {
    final calendarDb = (await calendar.database)!;
    final notesDb = await notes.db;
    await calendarDb.execute(
      'CREATE TABLE integrity_probe(value INTEGER CHECK(value > 0))',
    );
    await calendarDb.execute('PRAGMA ignore_check_constraints = ON');
    await calendarDb.insert('integrity_probe', {'value': -1});
    await calendarDb.execute('PRAGMA ignore_check_constraints = OFF');
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
      'phase': 'complete',
      'calendar_snapshot': '{}',
      'notes_snapshot': '[]',
    });
    expect(await calendarDb.rawQuery('PRAGMA integrity_check'), isNot(['ok']));

    await expectLater(
      AppBackupService.recoverPendingRestore(
        calendarDatabase: calendarDb,
        notesDatabase: notesDb,
      ),
      throwsA(isA<StateError>()),
    );
    expect(await calendarDb.query('backup_restore_journal'), hasLength(1));
  });

  test(
    'un backup espera a que terminen las escrituras de las dos bases',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      final blocker = PersistenceCoordinator.run(() async {
        entered.complete();
        await release.future;
      });
      await entered.future;

      final noteWrite = notes.insertNotas(
        Task(id: 123, title: 'Durante backup', site: 'Biblioteca'),
      );
      final backupFuture = AppBackupService.createBackupJson(
        calendarDatabase: await calendar.database,
        notesDatabase: await notes.db,
      );

      release.complete();
      await blocker;
      await noteWrite;
      final backup = jsonDecode(await backupFuture) as Map<String, dynamic>;
      final notesData =
          (backup['data'] as Map<String, dynamic>)['notes']
              as Map<String, dynamic>;
      expect((notesData['Notas'] as List).single['title'], 'Durante backup');
    },
  );
}

CuadranteDay _shift(
  DateTime date, {
  required String name,
  String title = 'M',
  String start = '08:00',
  String end = '16:00',
}) => CuadranteDay(
  cuadranteName: name,
  title: title,
  description: title,
  startHour: start,
  endHour: end,
  color: '4287f5',
  dateTime: date,
);
