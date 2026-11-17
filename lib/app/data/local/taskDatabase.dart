import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;

import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'persistence_coordinator.dart';
import '../../modules/sync/services/sync_identity.dart';
import '../../modules/sync/services/sync_events.dart';

import '../model/taskModel.dart';

class NotasDB {
  static final NotasDB instance = NotasDB._();
  factory NotasDB() => instance;
  NotasDB._() : _factoryOverride = null, _pathOverride = null;

  @visibleForTesting
  NotasDB.forTesting({required DatabaseFactory factory, required String path})
    : _factoryOverride = factory,
      _pathOverride = path;

  /// Opens an isolated database for recovery staging.
  NotasDB.forRecovery({required DatabaseFactory factory, required String path})
    : _factoryOverride = factory,
      _pathOverride = path;

  final DatabaseFactory? _factoryOverride;
  final String? _pathOverride;
  Database? _db;
  final String databaseName = 'notas_database.db';
  final String taskTable = 'Notas';
  static const int _version = 5;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db ??= await init();
    return _db!;
  }

  Future<String> databasePath() async {
    if (_pathOverride != null) return _pathOverride;
    if (kIsWeb) {
      return databaseName;
    }
    final documentDirectory = await getApplicationDocumentsDirectory();
    return join(documentDirectory.path, databaseName);
  }

  Future<Database> init() async {
    if (kIsWeb && _factoryOverride == null) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final path = await databasePath();
    final factory = _factoryOverride ?? databaseFactory;
    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _ensureColumns,
      ),
    );
  }

  // void _onCreate(Database db, int version) async {
  //   await db.execute('CREATE TABLE IF NOT EXISTS $taskTable('
  //       'id INTEGER PRIMARY KEY, '
  //       'title TEXT, site TEXT, '
  //       'notes TEXT, '
  //       'startTimeMilliseconds INTEGER, '
  //       'endTimeMilliseconds INTEGER, '
  //       'time TEXT, '
  //       'isImportant INTEGER, '
  //       'idAlarma INTEGER, '
  //       'alarmaActivadaString TEXT, '
  //       'isAlarmaCreated INTEGER, '
  //       'isAlarmaCreated INTEGER)'
  //   );
  // }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $taskTable('
      'id INTEGER PRIMARY KEY, '
      'title TEXT, '
      'site TEXT, '
      'notes TEXT, '
      'startTimeMilliseconds INTEGER, '
      'endTimeMilliseconds INTEGER, '
      'time TEXT, '
      'isImportant INTEGER, '
      'idAlarma INTEGER, '
      'alarmaHora TEXT, '
      'alarmaTimestamp INTEGER, '
      'alarmaActivadaString TEXT, '
      'isAlarmaCreated INTEGER, '
      'notificationMode TEXT NOT NULL DEFAULT \'notificacion\', '
      'syncKey TEXT, '
      'syncRevision INTEGER NOT NULL DEFAULT 0)',
    );
  }

  // Asegura las columnas necesarias tanto en actualizaciones como al abrir.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _ensureColumns(db);
  }

  // Añade solo columnas ausentes; nunca borra ni recrea la tabla.
  Future<void> _ensureColumns(Database db) async {
    final info = await db.rawQuery('PRAGMA table_info($taskTable)');
    final columns = info.map((column) => column['name'] as String).toSet();

    if (columns.isEmpty) {
      throw StateError(
        'No existe la tabla $taskTable; se cancela la reparación.',
      );
    }

    if (!columns.contains('alarmaHora')) {
      await db.execute('ALTER TABLE $taskTable ADD COLUMN alarmaHora TEXT');
    }

    if (!columns.contains('notificationMode')) {
      await db.execute(
        "ALTER TABLE $taskTable ADD COLUMN notificationMode TEXT NOT NULL DEFAULT 'notificacion'",
      );
    }

    if (!columns.contains('alarmaTimestamp')) {
      await db.execute(
        'ALTER TABLE $taskTable ADD COLUMN alarmaTimestamp INTEGER',
      );
    }
    if (!columns.contains('syncKey')) {
      await db.execute('ALTER TABLE $taskTable ADD COLUMN syncKey TEXT');
    }
    if (!columns.contains('syncRevision')) {
      await db.execute(
        'ALTER TABLE $taskTable ADD COLUMN syncRevision INTEGER NOT NULL DEFAULT 0',
      );
    }
    await _backfillMissingSyncKeys(db);
    await _ensureSyncInfrastructure(db);
  }

  Future<void> _backfillMissingSyncKeys(DatabaseExecutor db) async {
    final rows = await db.query(
      taskTable,
      where: "syncKey IS NULL OR syncKey = ''",
      orderBy: 'id ASC',
    );
    final occurrences = <String, int>{};
    for (final row in rows) {
      final values = [
        row['title'],
        row['site'],
        row['notes'],
        row['startTimeMilliseconds'],
        row['endTimeMilliseconds'],
        row['isImportant'],
        row['notificationMode'],
      ];
      final fingerprint = jsonEncode(values);
      final occurrence = occurrences.update(
        fingerprint,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final key = legacySyncKey('note', [...values, occurrence]);
      await db.update(
        taskTable,
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
      'CREATE UNIQUE INDEX IF NOT EXISTS notas_sync_key_idx ON $taskTable(syncKey)',
    );
    await db.execute('DROP TRIGGER IF EXISTS notas_sync_insert');
    await db.execute('DROP TRIGGER IF EXISTS notas_sync_update');
    await db.execute('DROP TRIGGER IF EXISTS notas_sync_delete');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS notas_sync_insert
      AFTER INSERT ON $taskTable
      WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying_remote'), '0') <> '1' AND NEW.syncKey IS NOT NULL
      BEGIN
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (NEW.syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS notas_sync_update
      AFTER UPDATE ON $taskTable
      WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying_remote'), '0') <> '1' AND OLD.syncKey IS NOT NULL AND NEW.syncKey IS NOT NULL
      BEGIN
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (OLD.syncKey, 'delete', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (NEW.syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS notas_sync_delete
      AFTER DELETE ON $taskTable
      WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying_remote'), '0') <> '1' AND OLD.syncKey IS NOT NULL
      BEGIN
        INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
        VALUES (OLD.syncKey, 'delete', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER));
      END
    ''');
  }

  // El modelo y SQLite comparten los campos persistidos.
  Map<String, Object?> _mapParaBD(Task notas) {
    return notas.toMap();
  }

  Future<int> insertNotas(Task notas) => PersistenceCoordinator.run(() async {
    notas.syncKey ??= newSyncKey();
    final dbClient = await db;
    final id = await dbClient.insert(
      taskTable,
      _mapParaBD(notas),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    if (id > 0) SyncEvents.instance.notifyLocalChange();
    return id;
  });

  Future<Task> select(int id) => PersistenceCoordinator.read(() async {
    var dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      taskTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (maps.length == 1) {
      return Task(
        id: maps[0]['id'],
        title: maps[0]['title'],
        site: maps[0]['site'],
        notes: maps[0]['notes'],
        startTimeMilliseconds: maps[0]['startTimeMilliseconds'],
        endTimeMilliseconds: maps[0]['endTimeMilliseconds'],
        // time: maps[0]['time'],
        isImportant: maps[0]['isImportant'] == 1 ? true : false,
        idAlarma: maps[0]['idAlarma'],
        alarmaHora: maps[0]['alarmaHora'],
        alarmaTimestamp: maps[0]['alarmaTimestamp'] as int?,
        alarmaActivadaString: maps[0]['alarmaActivadaString'],
        isAlarmaCreated: maps[0]['isAlarmaCreated'] == 1 ? true : false,
        notificationMode: maps[0]['notificationMode']?.toString() == 'alarma'
            ? 'alarma'
            : 'notificacion',
        syncKey: maps[0]['syncKey']?.toString(),
        syncRevision: (maps[0]['syncRevision'] as num?)?.toInt(),
      );
    } else {
      throw FormatException(
        'Los datos de la base de datos son anormales, hay ${maps.length}!!! ¿ ++  ?',
      );
    }
  });

  Future<List<Task>> getNotesFromDB() => PersistenceCoordinator.read(() async {
    var dbClient = await db;
    List<Task> notesList = [];
    List<Map> maps = await dbClient.query(
      taskTable,
      columns: [
        'id',
        'title',
        'site',
        'notes',
        'startTimeMilliseconds',
        'endTimeMilliseconds',
        'time',
        'isImportant',
        'idAlarma',
        'alarmaHora',
        'alarmaTimestamp',
        'alarmaActivadaString',
        'isAlarmaCreated',
        'notificationMode',
        'syncKey',
        'syncRevision',
      ],
    );
    if (maps.isNotEmpty) {
      for (var map in maps) {
        notesList.add(Task.fromMap(map));
      }
    }
    return notesList;
  });

  Future<void> getNotaID(Task notas) => update(notas);

  Future<void> update(Task notas) => PersistenceCoordinator.run(() async {
    notas.syncKey ??= newSyncKey();
    final dbClient = await db;
    final updated = await dbClient.update(
      taskTable,
      _mapParaBD(notas),
      where: 'id = ?',
      whereArgs: [notas.id],
    );
    if (updated > 0) SyncEvents.instance.notifyLocalChange();
  });

  Future<void> delete(int id) => PersistenceCoordinator.run(() async {
    final dbClient = await db;
    final deleted = await dbClient.delete(
      taskTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleted > 0) SyncEvents.instance.notifyLocalChange();
  });

  Future<List<Map<String, Object?>>> pendingSyncChanges() async {
    final client = await db;
    return client.query('sync_outbox', orderBy: 'id ASC');
  }

  Future<bool> hasPendingSyncChange(String syncKey) async {
    final client = await db;
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
    final client = await db;
    for (final change in changes) {
      await client.delete(
        'sync_outbox',
        where: 'id = ? AND created_at = ? AND operation = ?',
        whereArgs: [change['id'], change['created_at'], change['operation']],
      );
    }
  }

  Future<void> queueAllForSync() async {
    final client = await db;
    await _backfillMissingSyncKeys(client);
    await client.rawInsert('''
      INSERT OR REPLACE INTO sync_outbox(sync_key, operation, created_at)
      SELECT syncKey, 'upsert', CAST((julianday('now') - 2440587.5) * 86400000000 AS INTEGER)
      FROM $taskTable WHERE syncKey IS NOT NULL
    ''');
  }

  Future<bool> applyRemoteNote(Map<String, dynamic> row) async {
    final client = await db;
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
          taskTable,
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
          await txn.delete(taskTable, where: 'syncKey = ?', whereArgs: [key]);
        } else {
          final old = existing.isEmpty ? <String, Object?>{} : existing.first;
          await txn.insert(taskTable, {
            'id': old['id'],
            'syncKey': key,
            'syncRevision': (row['revision'] as num?)?.toInt() ?? 0,
            'title': row['title'],
            'site': row['site'],
            'notes': row['content'] ?? '',
            'startTimeMilliseconds': row['start_time_ms'],
            'endTimeMilliseconds': row['end_time_ms'],
            'isImportant': row['is_important'] == true ? 1 : 0,
            'notificationMode': row['notification_mode'] == 'alarma'
                ? 'alarma'
                : 'notificacion',
            'idAlarma': old['idAlarma'],
            'alarmaHora': old['alarmaHora'],
            'alarmaTimestamp': old['alarmaTimestamp'],
            'alarmaActivadaString': old['alarmaActivadaString'],
            'isAlarmaCreated': old['isAlarmaCreated'] ?? 0,
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
    final client = await db;
    await client.transaction((txn) async {
      await txn.insert('sync_meta', {
        'key': 'applying_remote',
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      try {
        await txn.update(
          taskTable,
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

  Future<Map<String, Object?>?> noteBySyncKey(String key) async {
    final client = await db;
    final rows = await client.query(
      taskTable,
      where: 'syncKey = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  // close() async {
  //   await db.close();
  // }

  Future<void> close() => PersistenceCoordinator.run(_close);

  Future<void> _close() async {
    final database = _db;
    if (database == null) return;
    _db = null;
    await database.close();
  }
}
