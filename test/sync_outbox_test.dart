import 'dart:io';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
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
    directory = await Directory.systemTemp.createTemp(
      'calendario-sync-outbox-',
    );
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
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('turnos registran altas y borrados en la cola local', () async {
    final id = await calendar.addCuadranteItem(
      CuadranteDay(
        cuadranteName: 'Trabajo',
        title: 'Mañana',
        dateTime: DateTime(2026, 11, 16),
        startHour: '07:00',
        endHour: '15:00',
      ),
    );

    var pending = await calendar.pendingSyncChanges();
    expect(pending, hasLength(1));
    expect(pending.single['operation'], 'upsert');
    final key = pending.single['sync_key'];
    expect(key, isNotEmpty);
    expect(await calendar.hasPendingSyncChange(key.toString()), isTrue);

    await calendar.acknowledgeSyncChanges(pending);
    expect(await calendar.pendingSyncChanges(), isEmpty);
    expect(await calendar.hasPendingSyncChange(key.toString()), isFalse);

    await calendar.deleteItemID(id);
    pending = await calendar.pendingSyncChanges();
    expect(pending, hasLength(1));
    expect(pending.single['sync_key'], key);
    expect(pending.single['operation'], 'delete');
  });

  test('notas registran altas, ediciones y borrados', () async {
    final id = await notes.insertNotas(
      Task(
        title: 'Comprar',
        notes: 'Leche',
        startTimeMilliseconds: DateTime(
          2026,
          11,
          16,
          10,
        ).millisecondsSinceEpoch,
      ),
    );

    var pending = await notes.pendingSyncChanges();
    expect(pending, hasLength(1));
    expect(pending.single['operation'], 'upsert');
    final key = pending.single['sync_key'];
    expect(key, isNotEmpty);
    expect(await notes.hasPendingSyncChange(key.toString()), isTrue);

    await notes.acknowledgeSyncChanges(pending);
    expect(await notes.hasPendingSyncChange(key.toString()), isFalse);
    final note = await notes.select(id);
    note.notes = 'Leche y pan';
    await notes.update(note);

    pending = await notes.pendingSyncChanges();
    expect(pending, hasLength(1));
    expect(pending.single['sync_key'], key);
    expect(pending.single['operation'], 'upsert');

    await notes.acknowledgeSyncChanges(pending);
    await notes.delete(id);
    pending = await notes.pendingSyncChanges();
    expect(pending, hasLength(1));
    expect(pending.single['sync_key'], key);
    expect(pending.single['operation'], 'delete');
  });

  test(
    'un cambio remoto no pisa turnos ni notas con cambios locales pendientes',
    () async {
      await calendar.addCuadranteItem(
        CuadranteDay(
          cuadranteName: 'Trabajo',
          title: 'Mi cambio local',
          dateTime: DateTime(2026, 11, 16),
          startHour: '07:00',
          endHour: '15:00',
        ),
      );
      final shiftKey = (await calendar.pendingSyncChanges()).single['sync_key']
          .toString();
      final shiftApplied = await calendar.applyRemoteShift({
        'sync_key': shiftKey,
        'revision': 1,
        'shift_date': '2026-11-16',
        'title': 'Cambio remoto',
        'description': '',
        'start_hour': '15:00',
        'end_hour': '22:00',
        'color': '#00AA00',
        'is_deleted': false,
      }, calendarName: 'Trabajo');
      expect(shiftApplied, isFalse);
      expect(
        (await calendar.getCuadranteList()).single.title,
        'Mi cambio local',
      );

      final noteId = await notes.insertNotas(
        Task(title: 'Nota local', notes: 'Contenido local'),
      );
      final note = await notes.select(noteId);
      final noteKey = note.syncKey!;
      final noteApplied = await notes.applyRemoteNote({
        'sync_key': noteKey,
        'revision': 1,
        'title': 'Nota remota',
        'content': 'Contenido remoto',
        'is_deleted': false,
      });
      expect(noteApplied, isFalse);
      expect((await notes.select(noteId)).title, 'Nota local');
      expect(await calendar.hasPendingSyncChange(shiftKey), isTrue);
      expect(await notes.hasPendingSyncChange(noteKey), isTrue);
    },
  );

  test(
    'aplicar cambios remotos no los vuelve a meter en la cola local',
    () async {
      await calendar.applyRemoteShift({
        'sync_key': 'remote-shift-1',
        'revision': 1,
        'calendar_name': 'Trabajo',
        'shift_date': '2026-11-16',
        'title': 'Tarde',
        'description': '',
        'start_hour': '15:00',
        'end_hour': '22:00',
        'color': '#00AA00',
        'is_deleted': false,
      }, calendarName: 'Trabajo');
      await notes.applyRemoteNote({
        'sync_key': 'remote-note-1',
        'revision': 1,
        'title': 'Cita',
        'content': 'Médico',
        'site': 'Centro',
        'start_time_ms': DateTime(2026, 11, 16, 12).millisecondsSinceEpoch,
        'end_time_ms': null,
        'is_important': true,
        'notification_mode': 'notificacion',
        'is_deleted': false,
      });

      expect(await calendar.pendingSyncChanges(), isEmpty);
      expect(await notes.pendingSyncChanges(), isEmpty);
      expect((await calendar.getCuadranteList()).single.title, 'Tarde');
      expect((await notes.getNotesFromDB()).single.title, 'Cita');
    },
  );
}
