import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/taskModel.dart';


class DbProvider {
  final String taskTable = 'travel';

  static final DbProvider instance = DbProvider._internal();
  factory DbProvider() => instance;
  DbProvider._internal();
  static Database? _db;

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await init();
      return _db;
    }
  }

  Future<Database> init() async {
    Directory doucumentDirectory = await getApplicationDocumentsDirectory();
    print(doucumentDirectory.path);
    String path = join(doucumentDirectory.path, 'essay_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $taskTable(id INTEGER PRIMARY KEY, title TEXT, site TEXT, notes TEXT, startTimeMilliseconds INTEGER, endTimeMilliseconds INTEGER, time TEXT, isImportant INTEGER)');
  }

  Future<int> insert(Task travel) async {
    var dbClient = await db;
    int res = await dbClient.insert(
      taskTable,
      travel.toMap(),
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
        time: maps[0]['time'],
        isImportant: maps[0]['isImportant'] == 1 ? true : false,
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
      'isImportant'
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(Task.fromMap(map));
      });
    }
    return notesList;
  }

  Future<void> update(Task travel) async {
    var dbClient = await db;
    await dbClient.update(
      taskTable,
      travel.toMap(),
      where: "id = ?",
      whereArgs: [travel.id],
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

  close() async {
    await db.close();
  }
}
