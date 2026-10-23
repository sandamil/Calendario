import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:async';

import '../model/cuadranteDay.dart';
import '../model/turnoType.dart';
import '../../modules/notas/services/notificaciones_service.dart';

class CalendarioDB {
  static final CalendarioDB db = CalendarioDB._();
  factory CalendarioDB() => db;
  CalendarioDB._();

  static Database? _database;
  final String databaseName = 'CalendarioAjatsoft.db';
  static const String _cuadrantesTable = 'Cuadrante';
  static const String _turnosTable = 'Turnos';
  static const int _version = 2;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await initDb();
  }

  Future<String> databasePath() async {
    if (kIsWeb) return databaseName;
    final documentDirectory = await getApplicationDocumentsDirectory();
    return join(documentDirectory.path, databaseName);
  }

  Future<Database> initDb() async {
    if (kIsWeb) databaseFactory = databaseFactoryFfiWeb;

    final path = await databasePath();
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _ensureDefaultTurnos,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $_cuadrantesTable('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'cuadranteName STRING, '
      'title STRING, '
      'datetime TEXT, '
      'startHour TEXT, '
      'endHour TEXT, '
      'description TEXT, '
      'color TEXT)',
    );

    await db.execute('''CREATE TABLE $_turnosTable
      (
        id INTEGER PRIMARY KEY,
        description TEXT,
        title TEXT,
        startHour TEXT,
        endHour TEXT,
        color TEXT,
        status TEXT,
        reminderEnabled INTEGER NOT NULL DEFAULT 0,
        reminderMinutesBefore INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('CREATE TABLE theme (id INTEGER NOT NULL)');
    await _insertDefaultTurnos(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_turnosTable ADD COLUMN reminderEnabled INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $_turnosTable ADD COLUMN reminderMinutesBefore INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _ensureDefaultTurnos(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $_turnosTable',
    );
    final total = (result.first['total'] as num?)?.toInt() ?? 0;

    if (total == 0) await _insertDefaultTurnos(db);
  }

  Future<void> _insertDefaultTurnos(Database db) async {
    const turnos = <Map<String, Object?>>[
      {
        'id': 1,
        'title': 'M',
        'description': 'Mañana',
        'color': '4287f5',
        'startHour': '07:00',
        'endHour': '15:00',
        'reminderEnabled': 0,
        'reminderMinutesBefore': 0,
      },
      {
        'id': 2,
        'title': 'T',
        'description': 'Tarde',
        'color': '71bd48',
        'startHour': '15:00',
        'endHour': '22:00',
        'reminderEnabled': 0,
        'reminderMinutesBefore': 0,
      },
      {
        'id': 3,
        'title': 'N',
        'description': 'Noche',
        'color': 'bd9648',
        'startHour': '22:00',
        'endHour': '07:00',
        'reminderEnabled': 0,
        'reminderMinutesBefore': 0,
      },
      {
        'id': 4,
        'title': 'L',
        'description': 'Libre',
        'color': 'ffffff',
        'startHour': '00:00',
        'endHour': '23:59',
        'reminderEnabled': 0,
        'reminderMinutesBefore': 0,
      },
    ];

    for (final turno in turnos) {
      await db.insert(
        _turnosTable,
        turno,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<CuadranteDay?> fetchItem(int id) async {
    final dbClient = await database;
    final result = await dbClient!
        .query(_cuadrantesTable, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return CuadranteDay.fromMap(result.first);
  }

  getCuadrantesName() {}

  Future<List<CuadranteDay>> getCuadranteList() async {
    final dbClient = await database;
    final result = await dbClient!.rawQuery('SELECT * FROM $_cuadrantesTable');
    return result.map((m) => CuadranteDay.fromMap(m)).toList();
  }

  Future<TurnoType?> _findTurnoTypeForDay(CuadranteDay item) async {
    final dbClient = await database;
    final result = await dbClient!.query(
      _turnosTable,
      where: '''
        title IS ?
        AND description IS ?
        AND startHour IS ?
        AND endHour IS ?
        AND color IS ?
      ''',
      whereArgs: [
        item.title,
        item.description,
        item.startHour,
        item.endHour,
        item.color,
      ],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return TurnoType.fromMap(result.first);
  }

  Future<void> _syncTurnoNotification(
    CuadranteDay item,
    int notificationId,
  ) async {
    final tipo = await _findTurnoTypeForDay(item);

    if (tipo == null || !tipo.reminderEnabled || item.dateTime == null) {
      await NotificacionesService.instance.cancelar(notificationId);
      return;
    }

    final start = item.startHour ?? '';
    final partes = start.split(':');
    if (partes.length != 2) {
      await NotificacionesService.instance.cancelar(notificationId);
      return;
    }

    final hour = int.tryParse(partes[0]);
    final minute = int.tryParse(partes[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      await NotificacionesService.instance.cancelar(notificationId);
      return;
    }

    final inicio = DateTime(
      item.dateTime!.year,
      item.dateTime!.month,
      item.dateTime!.day,
      hour,
      minute,
    );

    await NotificacionesService.instance.programarTurno(
      id: notificationId,
      titulo: item.description?.trim().isNotEmpty == true
          ? item.description!.trim()
          : (item.title ?? 'Turno'),
      inicioTurno: inicio,
      minutosAntes: tipo.reminderMinutesBefore,
    );
  }

  Future<int> addCuadranteItem(CuadranteDay item) async {
    final dbClient = await database;
    final res = await dbClient!.insert(
      _cuadrantesTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    if (res > 0) {
      try {
        await _syncTurnoNotification(item, res);
      } catch (_) {
        // El turno queda guardado aunque el aviso no pueda programarse.
      }
    }

    return res;
  }

  Future<int> updateItem(CuadranteDay item) async {
    final dbClient = await database;
    final fecha = item.dateTime?.toIso8601String().substring(0, 10);

    final antiguos = await dbClient!.query(
      _cuadrantesTable,
      columns: ['id'],
      where: 'datetime = ? AND cuadranteName = ?',
      whereArgs: [fecha, item.cuadranteName],
    );

    for (final antiguo in antiguos) {
      final id = (antiguo['id'] as num?)?.toInt();
      if (id != null) await NotificacionesService.instance.cancelar(id);
    }

    await dbClient.delete(
      _cuadrantesTable,
      where: 'datetime = ? AND cuadranteName = ?',
      whereArgs: [fecha, item.cuadranteName],
    );

    final res = await dbClient.insert(
      _cuadrantesTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (res > 0) await _syncTurnoNotification(item, res);
    return res;
  }

  Future<void> deleteItemDateTime(String dateTime) async {
    final dbClient = await database;
    final rows = await dbClient!.query(
      _cuadrantesTable,
      columns: ['id'],
      where: 'datetime = ?',
      whereArgs: [dateTime],
    );
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await NotificacionesService.instance.cancelar(id);
    }
    await dbClient.delete(
      _cuadrantesTable,
      where: 'datetime = ?',
      whereArgs: [dateTime],
    );
  }

  Future<void> deleteCuadrante(String cuadranteName) async {
    final dbClient = await database;
    final rows = await dbClient!.query(
      _cuadrantesTable,
      columns: ['id'],
      where: 'cuadranteName = ?',
      whereArgs: [cuadranteName],
    );
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await NotificacionesService.instance.cancelar(id);
    }
    await dbClient.delete(
      _cuadrantesTable,
      where: 'cuadranteName = ?',
      whereArgs: [cuadranteName],
    );
  }

  Future<void> deleteCuadranteOutsideRange(
    String cuadranteName,
    DateTime start,
    DateTime end,
  ) async {
    final dbClient = await database;
    final fechaInicio = start.toIso8601String().substring(0, 10);
    final fechaFin = end.toIso8601String().substring(0, 10);

    final rows = await dbClient!.query(
      _cuadrantesTable,
      columns: ['id'],
      where: 'cuadranteName = ? AND (datetime < ? OR datetime > ?)',
      whereArgs: [cuadranteName, fechaInicio, fechaFin],
    );
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await NotificacionesService.instance.cancelar(id);
    }

    await dbClient.delete(
      _cuadrantesTable,
      where: 'cuadranteName = ? AND (datetime < ? OR datetime > ?)',
      whereArgs: [cuadranteName, fechaInicio, fechaFin],
    );
  }

  Future<void> deleteALlCuadrante() async {
    final dbClient = await database;
    final rows = await dbClient!.query(_cuadrantesTable, columns: ['id']);
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await NotificacionesService.instance.cancelar(id);
    }
    await dbClient.delete(_cuadrantesTable);
  }

  Future<void> deleteItemID(int id) async {
    final dbClient = await database;
    await NotificacionesService.instance.cancelar(id);
    await dbClient!.delete(_cuadrantesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TurnoType>> getTypeModels() async {
    final dbClient = await database;
    final result = await dbClient!.query(_turnosTable);
    return result.map((m) => TurnoType.fromMap(m)).toList();
  }

  Future<int> addTypeModel(TurnoType itemModel) async {
    final dbClient = await database;
    return dbClient!.insert(
      _turnosTable,
      itemModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<TurnoType?> fetchTurnoType(int id) async {
    final dbClient = await database;
    final result = await dbClient!.query(
      _turnosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return TurnoType.fromMap(result.first);
  }

  Future<void> _syncNotificationsForTurnoType(TurnoType turno) async {
    final dbClient = await database;
    final rows = await dbClient!.query(
      _cuadrantesTable,
      where: '''
        title IS ?
        AND description IS ?
        AND startHour IS ?
        AND endHour IS ?
        AND color IS ?
      ''',
      whereArgs: [
        turno.title,
        turno.description,
        turno.startHour,
        turno.endHour,
        turno.color,
      ],
    );

    for (final row in rows) {
      final item = CuadranteDay.fromMap(row);
      final id = (row['id'] as num?)?.toInt();
      if (id == null) continue;
      await _syncTurnoNotification(item, id);
    }
  }

  Future<void> updateTurno(TurnoType turno) async {
    final dbClient = await database;
    final resultado = await dbClient!.query(
      _turnosTable,
      where: 'id = ?',
      whereArgs: [turno.id],
      limit: 1,
    );

    if (resultado.isEmpty) return;

    final anterior = TurnoType.fromMap(resultado.first);

    await dbClient.update(
      _turnosTable,
      turno.toMap(),
      where: 'id = ?',
      whereArgs: [turno.id],
    );

    await dbClient.update(
      _cuadrantesTable,
      {
        'title': turno.title,
        'description': turno.description,
        'startHour': turno.startHour,
        'endHour': turno.endHour,
        'color': turno.color,
      },
      where: '''
        title IS ?
        AND description IS ?
        AND startHour IS ?
        AND endHour IS ?
        AND color IS ?
      ''',
      whereArgs: [
        anterior.title,
        anterior.description,
        anterior.startHour,
        anterior.endHour,
        anterior.color,
      ],
    );

    await _syncNotificationsForTurnoType(turno);
  }

  Future<void> deleteTypeId(int id) async {
    final dbClient = await database;
    final turno = await fetchTurnoType(id);

    if (turno != null) {
      final rows = await dbClient!.query(
        _cuadrantesTable,
        columns: ['id'],
        where: '''
          title IS ?
          AND description IS ?
          AND startHour IS ?
          AND endHour IS ?
          AND color IS ?
        ''',
        whereArgs: [
          turno.title,
          turno.description,
          turno.startHour,
          turno.endHour,
          turno.color,
        ],
      );
      for (final row in rows) {
        final notificationId = (row['id'] as num?)?.toInt();
        if (notificationId != null) {
          await NotificacionesService.instance.cancelar(notificationId);
        }
      }
    }

    await dbClient!.delete(_turnosTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDb() async {
    final dbClient = _database;
    if (dbClient == null) return;
    await dbClient.close();
    _database = null;
  }

  Future<int> clear() async {
    final dbClient = await database;
    final rows = await dbClient!.query(_cuadrantesTable, columns: ['id']);
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await NotificacionesService.instance.cancelar(id);
    }
    return dbClient.delete(_cuadrantesTable);
  }
}
