import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/taskModel.dart';

class NotasDB {
  static final NotasDB instance = NotasDB._();
  factory NotasDB() => instance;
  NotasDB._();

  static Database? _db;
  final String databaseName = 'notas_database.db';
  final String taskTable = 'Notas';
  static const int _version = 2;

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await init();
      return _db;
    }
  }

  Future<String> databasePath() async {
    Directory doucumentDirectory = await getApplicationDocumentsDirectory();
    return join(doucumentDirectory.path, databaseName);
  }

  Future<Database> init() async {
    // Directory doucumentDirectory = await getApplicationDocumentsDirectory();
    // String path = join(doucumentDirectory.path, 'notas_database.db');
    final path = await databasePath();
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
  //       'isAlarmaCreated INTEGER)'
  //   );
  // }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE IF NOT EXISTS $taskTable('
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
        'alarmaActivadaString TEXT, '
        'isAlarmaCreated INTEGER)');
  }

  // UPGRADE DATABASE TABLES
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(' ------------------------------------------${oldVersion}');
    print(' ------------------------------------------${newVersion}');
    (newVersion);
    if (oldVersion < newVersion) {
      // you can execute drop table and create table
      await db.execute("ALTER TABLE $taskTable ADD COLUMN alarmaHora TEXT;");
    }
  }

  // Adapta Task al esquema existente de la base de datos v2.
  // alarmaTimestamp pertenece al modelo, pero no existe en SQLite.
  Map<String, Object?> _mapParaBD(Task notas) {
    final map = notas.toMap();
    map.remove('alarmaTimestamp');
    return map;
  }

  Future<int> insertNotas(Task notas) async {
    var dbClient = await db;
    int res = await dbClient.insert(
      taskTable,
      _mapParaBD(notas),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return res;
  }

  Future<Task> select(int id) async {
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
        alarmaActivadaString: maps[0]['alarmaActivadaString'],
        isAlarmaCreated: maps[0]['isAlarmaCreated'] == 1 ? true : false,
      );
    } else {
      throw FormatException(
          'Los datos de la base de datos son anormales, hay ${maps.length}!!! ¿ ++  ?');
    }
  }

  Future<List<Task>> getNotesFromDB() async {
    var dbClient = await db;
    List<Task> notesList = [];
    List<Map> maps = await dbClient.query(taskTable, columns: [
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
      'alarmaActivadaString',
      'isAlarmaCreated'
    ]);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        notesList.add(Task.fromMap(map));
      }
    }
    return notesList;
  }

  Future<void> getNotaID(Task notas) async {
    var dbClient = await db;
    await dbClient.update(
      taskTable,
      _mapParaBD(notas),
      where: "id = ?",
      whereArgs: [notas.id],
    );
  }

  Future<void> update(Task notas) async {
    var dbClient = await db;
    await dbClient.update(
      taskTable,
      _mapParaBD(notas),
      where: "id = ?",
      whereArgs: [notas.id],
    );
  }

  Future<void> delete(int id) async {
    var dbClient = await db;
    await dbClient.delete(
      taskTable,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // close() async {
  //   await db.close();
  // }

  Future close() async {
    final db = await instance.db;
    _db = null;
    return db.close();
  }
}
