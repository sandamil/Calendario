import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, visibleForTesting;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'dart:async';
import 'dart:convert';

import '../model/cuadranteDay.dart';
import '../model/turnoType.dart';
import '../../modules/notas/services/notificaciones_service.dart';
import 'persistence_coordinator.dart';
import '../../modules/sync/services/sync_identity.dart';
import '../../modules/sync/services/sync_events.dart';

class CalendarioDB {
  static final CalendarioDB db = CalendarioDB._();
  factory CalendarioDB() => db;
  CalendarioDB._()
    : _factoryOverride = null,
      _pathOverride = null,
      _syncNotifications = true;

  @visibleForTesting
  CalendarioDB.forTesting({
    required DatabaseFactory factory,
    required String path,
  }) : _factoryOverride = factory,
       _pathOverride = path,
       _syncNotifications = false;

  /// Opens an isolated database for recovery staging without side effects.
  CalendarioDB.forRecovery({
    required DatabaseFactory factory,
    required String path,
  }) : _factoryOverride = factory,
       _pathOverride = path,
       _syncNotifications = false;

  final DatabaseFactory? _factoryOverride;
  final String? _pathOverride;
  final bool _syncNotifications;
  Database? _database;
  final String databaseName = 'CalendarioAjatsoft.db';
  static const String _cuadrantesTable = 'Cuadrante';
  static const String _turnosTable = 'Turnos';
  static const int _version = 4;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await initDb();
  }

  Future<String> databasePath() async {
    if (_pathOverride != null) return _pathOverride;
    if (kIsWeb) return databaseName;
    final documentDirectory = await getApplicationDocumentsDirectory();
    return join(documentDirectory.path, databaseName);
  }

  Future<Database> initDb() async {
    if (kIsWeb && _factoryOverride == null) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final path = await databasePath();
    final factory = _factoryOverride ?? databaseFactory;
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _ensureDefaultTurnos,
      ),
    );
  }

  Future<void> _cancelNotification(int id) async {
    if (!_syncNotifications) return;
    try {
      await NotificacionesService.instance.cancelar(id);
    } catch (error) {
      debugPrint('[CALENDARIO_DB] No se pudo cancelar aviso $id: $error');
    }
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
      'color TEXT, '
      'syncKey TEXT, '
      'syncRevision INTEGER NOT NULL DEFAULT 0)',
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
        reminderMinutesBefore INTEGER NOT NULL DEFAULT 0,
        reminderMode TEXT NOT NULL DEFAULT 'notificacion'
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
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE $_turnosTable ADD COLUMN reminderMode TEXT NOT NULL DEFAULT 'notificacion'",
      );
    }
  }

  Future<void> _ensureDefaultTurnos(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $_turnosTable',
    );
    final total = (result.first['total'] as num?)?.toInt() ?? 0;

    if (total == 0) await _insertDefaultTurnos(db);

    final info = await db.rawQuery('PRAGMA table_info($_cuadrantesTable)');
    final columns = info.map((column) => column['name'] as String).toSet();
    if (!columns.contains('syncKey')) {
      await db.execute('ALTER TABLE $_cuadrantesTable ADD COLUMN syncKey TEXT');
    }
    if (!columns.contains('syncRevision')) {
      await db.execute(
        'ALTER TABLE $_cuadrantesTable ADD COLUMN syncRevision INTEGER NOT NULL DEFAULT 0',
      );
    }
    await _backfillMissingSyncKeys(db);
    await _ensureSyncInfrastructure(db);
  }

  Future<void> _backfillMissingSyncKeys(DatabaseExecutor db) async {
    final rows = await db.query(
      _cuadrantesTable,
      where: "syncKey IS NULL OR syncKey = ''",
      orderBy: 'datetime ASC, id ASC',
    );
    final occurrences = <String, int>{};
    for (final row in rows) {
      final values = [
        row['cuadranteName'],
        row['datetime'],
        row['title'],
        row['description'],
        row['startHour'],
        row['endHour'],
        row['color'],
      ];
      final fingerprint = jsonEncode(values);
      final occurrence = occurrences.update(
        fingerprint,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final key = legacySyncKey('shift', [...values, occurrence]);
      await db.update(
        _cuadrantesTable,
        {'syncKey': key},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  Future<void> _ensureSyncInfrastructure(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_key TEXT NOT NULL UNIQUE,
        operation TEXT NOT NULL CHECK (operation IN ('upsert', 'delete')),
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS cuadrante_sync_key_idx ON $_cuadrantesTable(syncKey)',
    );
    await db.execute('DROP TRIGGER IF EXISTS cuadrante_sync_insert');
    await db.execute('DROP TRIGGER IF EXISTS cuadrante_sync_update');
    await db.execute('DROP TRIGGER IF EXISTS cuadrante_sync_delete');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS cuadrante_sync_insert
      AFTER INSERT ON $_cuadrantesTable
      WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying_remote'), '0') <> '1' AND NEW.syncKey IS NOT NULL
      BEGIN
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (NEW.syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS cuadrante_sync_update
      AFTER UPDATE ON $_cuadrantesTable
      WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying_remote'), '0') <> '1' AND OLD.syncKey IS NOT NULL AND NEW.syncKey IS NOT NULL
      BEGIN
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (OLD.syncKey, 'delete', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (NEW.syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS cuadrante_sync_delete
      AFTER DELETE ON $_cuadrantesTable
      WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying_remote'), '0') <> '1' AND OLD.syncKey IS NOT NULL
      BEGIN
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (OLD.syncKey, 'delete', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
      END
    ''');
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

  Future<CuadranteDay?> fetchItem(int id) =>
      PersistenceCoordinator.read(() async {
        final dbClient = await database;
        final result = await dbClient!.query(
          _cuadrantesTable,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (result.isEmpty) return null;
        return CuadranteDay.fromMap(result.first);
      });

  getCuadrantesName() {}

  Future<List<CuadranteDay>> getCuadranteList() =>
      PersistenceCoordinator.read(() async {
        final dbClient = await database;
        final result = await dbClient!.rawQuery(
          'SELECT * FROM $_cuadrantesTable',
        );
        return result.map((m) => CuadranteDay.fromMap(m)).toList();
      });

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
    if (!_syncNotifications) return;
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
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
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
      modoAviso: tipo.reminderMode,
    );
  }

  Future<int> addCuadranteItem(CuadranteDay item) =>
      PersistenceCoordinator.run(() async {
        final dbClient = (await database)!;
        item.syncKey ??= newSyncKey();
        final res = await dbClient.insert(
          _cuadrantesTable,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        if (res > 0) {
          SyncEvents.instance.notifyLocalChange();
          try {
            await _syncTurnoNotification(item, res);
          } catch (_) {
            // El turno queda guardado aunque el aviso no pueda programarse.
          }
        }
        return res;
      });

  /// Inserts a batch of independent calendar occurrences atomically.
  Future<List<int>> addCuadranteItems(
    List<CuadranteDay> items,
  ) => PersistenceCoordinator.run(() async {
    if (items.isEmpty) return <int>[];
    if (items.any((item) => item.dateTime == null)) {
      throw ArgumentError('Todos los turnos deben tener una fecha.');
    }
    final dbClient = (await database)!;
    for (final item in items) {
      item.syncKey ??= newSyncKey();
    }
    final ids = await dbClient.transaction((txn) async {
      final inserted = <int>[];
      for (final item in items) {
        inserted.add(
          await txn.insert(
            _cuadrantesTable,
            item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort,
          ),
        );
      }
      return inserted;
    });
    if (ids.isNotEmpty) SyncEvents.instance.notifyLocalChange();
    for (var index = 0; index < items.length; index++) {
      try {
        await _syncTurnoNotification(items[index], ids[index]);
      } catch (error) {
        debugPrint(
          '[CALENDARIO_DB] No se pudo programar aviso del turno repetido: $error',
        );
      }
    }
    return ids;
  });

  /// Replaces all days in a rotation in one SQLite transaction.
  Future<List<int>> replaceCuadranteItems(
    String cuadranteName,
    List<CuadranteDay> items,
  ) => PersistenceCoordinator.run(() async {
    if (items.isEmpty) {
      throw ArgumentError('La rotación debe contener al menos un turno.');
    }
    if (items.any((item) => item.cuadranteName != cuadranteName)) {
      throw ArgumentError('Todos los turnos deben pertenecer a la rotación.');
    }

    final dbClient = (await database)!;
    for (final item in items) {
      item.syncKey ??= newSyncKey();
    }
    final previousRows = await dbClient.query(
      _cuadrantesTable,
      columns: ['id'],
      where: 'cuadranteName = ?',
      whereArgs: [cuadranteName],
    );
    final insertedIds = await dbClient.transaction((txn) async {
      await txn.delete(
        _cuadrantesTable,
        where: 'cuadranteName = ?',
        whereArgs: [cuadranteName],
      );

      final ids = <int>[];
      for (final item in items) {
        ids.add(await txn.insert(_cuadrantesTable, item.toMap()));
      }
      return ids;
    });

    SyncEvents.instance.notifyLocalChange();
    for (final row in previousRows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await _cancelNotification(id);
    }
    for (var i = 0; i < items.length; i++) {
      try {
        await _syncTurnoNotification(items[i], insertedIds[i]);
      } catch (_) {
        // Persistencia de la rotación independiente de los permisos de aviso.
      }
    }
    return insertedIds;
  });

  Future<int> updateItem(CuadranteDay item) =>
      PersistenceCoordinator.run(() async {
        final dbClient = (await database)!;
        final fecha = item.dateTime?.toIso8601String().substring(0, 10);
        var antiguos = item.id == null
            ? <Map<String, Object?>>[]
            : await dbClient.query(
                _cuadrantesTable,
                columns: ['id', 'syncKey', 'syncRevision'],
                where: 'id = ?',
                whereArgs: [item.id],
              );
        if (antiguos.isEmpty) {
          antiguos = await dbClient.query(
            _cuadrantesTable,
            columns: ['id', 'syncKey', 'syncRevision'],
            where: 'datetime = ? AND cuadranteName = ?',
            whereArgs: [fecha, item.cuadranteName],
          );
        }

        final res = await dbClient.transaction((txn) async {
          for (final antiguo in antiguos) {
            await txn.delete(
              _cuadrantesTable,
              where: 'id = ?',
              whereArgs: [antiguo['id']],
            );
          }

          final map = item.toMap();
          map['id'] ??= antiguos.isEmpty ? null : antiguos.first['id'];
          item.syncKey ??= antiguos.isEmpty
              ? newSyncKey()
              : antiguos.first['syncKey']?.toString();
          map['syncKey'] = item.syncKey;
          item.syncRevision ??= (antiguos.isEmpty
              ? 0
              : (antiguos.first['syncRevision'] as num?)?.toInt());
          map['syncRevision'] = item.syncRevision ?? 0;
          return txn.insert(
            _cuadrantesTable,
            map,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
        });

        SyncEvents.instance.notifyLocalChange();
        for (final antiguo in antiguos) {
          final id = (antiguo['id'] as num?)?.toInt();
          if (id != null && id != res) await _cancelNotification(id);
        }
        try {
          await _syncTurnoNotification(item, res);
        } catch (error) {
          debugPrint('[CALENDARIO_DB] No se pudo actualizar el aviso: $error');
        }
        return res;
      });

  /// Swaps the dates of two existing occurrences in one SQLite transaction.
  Future<void> swapCuadranteItemDates(
    int firstId,
    int secondId,
  ) => PersistenceCoordinator.run(() async {
    if (firstId == secondId) {
      throw ArgumentError('Selecciona dos turnos diferentes.');
    }
    final dbClient = (await database)!;
    final rows = await dbClient.query(
      _cuadrantesTable,
      where: 'id IN (?, ?)',
      whereArgs: [firstId, secondId],
    );
    if (rows.length != 2) {
      throw StateError('Uno de los turnos ya no existe.');
    }
    final first = rows.firstWhere((row) => row['id'] == firstId);
    final second = rows.firstWhere((row) => row['id'] == secondId);
    final firstDate = first['datetime']?.toString();
    final secondDate = second['datetime']?.toString();
    if (firstDate == null || secondDate == null) {
      throw StateError('No se pudo leer la fecha de ambos turnos.');
    }
    await dbClient.transaction((txn) async {
      await txn.update(
        _cuadrantesTable,
        {'datetime': secondDate},
        where: 'id = ?',
        whereArgs: [firstId],
      );
      await txn.update(
        _cuadrantesTable,
        {'datetime': firstDate},
        where: 'id = ?',
        whereArgs: [secondId],
      );
    });
    SyncEvents.instance.notifyLocalChange();
    final firstMoved = CuadranteDay.fromMap({...first, 'datetime': secondDate});
    final secondMoved = CuadranteDay.fromMap({
      ...second,
      'datetime': firstDate,
    });
    try {
      await _syncTurnoNotification(firstMoved, firstId);
    } catch (error) {
      debugPrint(
        '[CALENDARIO_DB] No se pudo actualizar el aviso del primer turno intercambiado: $error',
      );
    }
    try {
      await _syncTurnoNotification(secondMoved, secondId);
    } catch (error) {
      debugPrint(
        '[CALENDARIO_DB] No se pudo actualizar el aviso del segundo turno intercambiado: $error',
      );
    }
  });

  Future<void> deleteItemDateTime(String dateTime) =>
      PersistenceCoordinator.run(() async {
        final dbClient = (await database)!;
        final rows = await dbClient.query(
          _cuadrantesTable,
          columns: ['id'],
          where: 'datetime = ?',
          whereArgs: [dateTime],
        );
        final deleted = await dbClient.delete(
          _cuadrantesTable,
          where: 'datetime = ?',
          whereArgs: [dateTime],
        );
        if (deleted > 0) SyncEvents.instance.notifyLocalChange();
        for (final row in rows) {
          final id = (row['id'] as num?)?.toInt();
          if (id != null) await _cancelNotification(id);
        }
      });

  Future<void> deleteCuadrante(String cuadranteName) =>
      PersistenceCoordinator.run(() async {
        final dbClient = (await database)!;
        final rows = await dbClient.query(
          _cuadrantesTable,
          columns: ['id'],
          where: 'cuadranteName = ?',
          whereArgs: [cuadranteName],
        );
        final deleted = await dbClient.delete(
          _cuadrantesTable,
          where: 'cuadranteName = ?',
          whereArgs: [cuadranteName],
        );
        if (deleted > 0) SyncEvents.instance.notifyLocalChange();
        for (final row in rows) {
          final id = (row['id'] as num?)?.toInt();
          if (id != null) await _cancelNotification(id);
        }
      });

  Future<void> deleteCuadranteOutsideRange(
    String cuadranteName,
    DateTime start,
    DateTime end,
  ) => PersistenceCoordinator.run(() async {
    final dbClient = (await database)!;
    final fechaInicio = start.toIso8601String().substring(0, 10);
    final fechaFin = end.toIso8601String().substring(0, 10);
    const where = 'cuadranteName = ? AND (datetime < ? OR datetime > ?)';
    final args = [cuadranteName, fechaInicio, fechaFin];
    final rows = await dbClient.query(
      _cuadrantesTable,
      columns: ['id'],
      where: where,
      whereArgs: args,
    );
    final deleted = await dbClient.delete(
      _cuadrantesTable,
      where: where,
      whereArgs: args,
    );
    if (deleted > 0) SyncEvents.instance.notifyLocalChange();
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await _cancelNotification(id);
    }
  });

  Future<void> deleteALlCuadrante() => PersistenceCoordinator.run(() async {
    final dbClient = (await database)!;
    final rows = await dbClient.query(_cuadrantesTable, columns: ['id']);
    final deleted = await dbClient.delete(_cuadrantesTable);
    if (deleted > 0) SyncEvents.instance.notifyLocalChange();
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await _cancelNotification(id);
    }
  });

  Future<void> deleteItemID(int id) => PersistenceCoordinator.run(() async {
    final dbClient = (await database)!;
    final deleted = await dbClient.delete(
      _cuadrantesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleted > 0) {
      SyncEvents.instance.notifyLocalChange();
      await _cancelNotification(id);
    }
  });

  Future<List<TurnoType>> getTypeModels() =>
      PersistenceCoordinator.read(() async {
        final dbClient = await database;
        final result = await dbClient!.query(_turnosTable);
        return result.map((m) => TurnoType.fromMap(m)).toList();
      });

  Future<int> addTypeModel(TurnoType itemModel) =>
      PersistenceCoordinator.run(() async {
        final dbClient = (await database)!;
        return dbClient.insert(
          _turnosTable,
          itemModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      });

  Future<TurnoType?> fetchTurnoType(int id) =>
      PersistenceCoordinator.read(() => _fetchTurnoTypeUnlocked(id));

  Future<TurnoType?> _fetchTurnoTypeUnlocked(int id) async {
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

  Future<void> updateTurno(TurnoType turno) =>
      PersistenceCoordinator.run(() async {
        final dbClient = (await database)!;
        final resultado = await dbClient.query(
          _turnosTable,
          where: 'id = ?',
          whereArgs: [turno.id],
          limit: 1,
        );

        if (resultado.isEmpty) return;

        final anterior = TurnoType.fromMap(resultado.first);

        await dbClient.transaction((txn) async {
          await txn.update(
            _turnosTable,
            turno.toMap(),
            where: 'id = ?',
            whereArgs: [turno.id],
          );

          await txn.update(
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
        });

        SyncEvents.instance.notifyLocalChange();
        try {
          await _syncNotificationsForTurnoType(turno);
        } catch (error) {
          debugPrint(
            '[CALENDARIO_DB] No se pudieron actualizar los avisos: $error',
          );
        }
      });

  Future<void> deleteTypeId(int id) => PersistenceCoordinator.run(() async {
    final dbClient = (await database)!;
    final turno = await _fetchTurnoTypeUnlocked(id);
    var notificationIds = <int>[];

    if (turno != null) {
      final rows = await dbClient.query(
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
      notificationIds = rows
          .map((row) => (row['id'] as num?)?.toInt())
          .whereType<int>()
          .toList();
    }

    await dbClient.delete(_turnosTable, where: 'id = ?', whereArgs: [id]);
    for (final notificationId in notificationIds) {
      await _cancelNotification(notificationId);
    }
  });

  Future<List<Map<String, Object?>>> pendingSyncChanges() async {
    final client = (await database)!;
    return client.query('sync_outbox', orderBy: 'id ASC');
  }

  Future<bool> hasPendingSyncChange(String syncKey) async {
    final client = (await database)!;
    final rows = await client.query(
      'sync_outbox',
      columns: ['id'],
      where: 'sync_key = ?',
      whereArgs: [syncKey],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> acknowledgeSyncChanges(
    List<Map<String, Object?>> changes,
  ) async {
    if (changes.isEmpty) return;
    final client = (await database)!;
    for (final change in changes) {
      await client.delete(
        'sync_outbox',
        where: 'id = ? AND created_at = ? AND operation = ?',
        whereArgs: [change['id'], change['created_at'], change['operation']],
      );
    }
  }

  Future<void> queueAllForSync({String? calendarName}) async {
    final client = (await database)!;
    await _backfillMissingSyncKeys(client);
    if (calendarName == null) {
      await client.rawInsert('''
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        SELECT syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER)
        FROM $_cuadrantesTable WHERE syncKey IS NOT NULL
      ''');
    } else {
      await client.rawInsert(
        '''
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        SELECT syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER)
        FROM $_cuadrantesTable WHERE syncKey IS NOT NULL AND cuadranteName = ?
      ''',
        [calendarName],
      );
    }
  }

  Future<bool> applyRemoteShift(
    Map<String, dynamic> row, {
    required String calendarName,
  }) async {
    final client = (await database)!;
    final key = row['sync_key']?.toString();
    if (key == null || key.isEmpty) return false;
    return client.transaction((txn) async {
      final pending = await txn.query(
        'sync_outbox',
        columns: ['id'],
        where: 'sync_key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (pending.isNotEmpty) return false;
      await txn.insert('sync_meta', {
        'key': 'applying_remote',
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      try {
        final existing = await txn.query(
          _cuadrantesTable,
          where: 'syncKey = ?',
          whereArgs: [key],
          limit: 1,
        );
        final incomingRevision = (row['revision'] as num?)?.toInt() ?? 0;
        final currentRevision = existing.isEmpty
            ? 0
            : (existing.first['syncRevision'] as num?)?.toInt() ?? 0;
        if (existing.isNotEmpty && incomingRevision <= currentRevision) {
          return true;
        }
        if (row['is_deleted'] == true) {
          await txn.delete(
            _cuadrantesTable,
            where: 'syncKey = ?',
            whereArgs: [key],
          );
        } else {
          final old = existing.isEmpty ? <String, Object?>{} : existing.first;
          await txn.insert(_cuadrantesTable, {
            'id': old['id'],
            'syncKey': key,
            'syncRevision': (row['revision'] as num?)?.toInt() ?? 0,
            'cuadranteName': calendarName,
            'title': row['title'],
            'description': row['description'],
            'datetime': row['shift_date']?.toString(),
            'startHour': row['start_hour'],
            'endHour': row['end_hour'],
            'color': row['color'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        return true;
      } finally {
        await txn.delete(
          'sync_meta',
          where: 'key = ?',
          whereArgs: ['applying_remote'],
        );
      }
    });
  }

  Future<void> setSyncRevision(String key, int revision) async {
    final client = (await database)!;
    await client.transaction((txn) async {
      await txn.insert('sync_meta', {
        'key': 'applying_remote',
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      try {
        await txn.update(
          _cuadrantesTable,
          {'syncRevision': revision},
          where: 'syncKey = ?',
          whereArgs: [key],
        );
      } finally {
        await txn.delete(
          'sync_meta',
          where: 'key = ?',
          whereArgs: ['applying_remote'],
        );
      }
    });
  }

  Future<Map<String, Object?>?> shiftBySyncKey(String key) async {
    final client = (await database)!;
    final rows = await client.query(
      _cuadrantesTable,
      where: 'syncKey = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> closeDb() => PersistenceCoordinator.run(_closeDb);

  Future<void> _closeDb() async {
    final dbClient = _database;
    if (dbClient == null) return;
    await dbClient.close();
    _database = null;
  }

  Future<int> clear() => PersistenceCoordinator.run(() async {
    final dbClient = (await database)!;
    final rows = await dbClient.query(_cuadrantesTable, columns: ['id']);
    final deleted = await dbClient.delete(_cuadrantesTable);
    if (deleted > 0) SyncEvents.instance.notifyLocalChange();
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt();
      if (id != null) await _cancelNotification(id);
    }
    return deleted;
  });
}
