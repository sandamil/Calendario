import 'dart:async';
import 'dart:io';
import 'package:calendario2/app/data/model/previousTaskModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class PreviusDbProvider {
  static final PreviusDbProvider instance = PreviusDbProvider._internal();
  factory PreviusDbProvider() => instance;
  PreviusDbProvider._internal();
  static Database? _db;
  final String taskTable = 'notes';


  get db async {
    if (_db != null) {
      print('get db async ' '$_db');

      return _db;
    } else {
      _db = await init();
      print('get db async ' '$_db');

      return _db;
    }
  }


  String DATABASE_PATH = "/data/data/ajat.calendario.turnos/databases/DBC4A.db";



  Future<Database> init() async {
    Directory doucumentDirectory = await getApplicationDocumentsDirectory();
    String path = DATABASE_PATH;
    print('PreviusDbProvider path' '$path');
    return await openDatabase(
      path,
      version: 20,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    // await db.execute('CREATE TABLE IF NOT EXISTS $taskTable('
    //     "id INTEGER PRIMARY KEY AUTOINCREMENT, day INTEGER, month INTEGER, year INTEGER, note TEXT , alarm TEXT)"
    // );
  }

  Future<int> insertNotas(PreviousTask previousNotas) async {
    var dbClient = await db;
    int res = await dbClient.insert(
      taskTable,
      previousNotas.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return res;
  }

  Future<PreviousTask> select(int id) async {
    var dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      taskTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (maps.length == 1) {
      return PreviousTask(
        id: maps[0]['id'],
        day: maps[0]['day'],
        month: maps[0]['month'],
        year: maps[0]['year'],
        note: maps[0]['note'],
        alarm: maps[0]['alarm'],
      );
    } else {
      throw FormatException(
          'Los datos de la base de datos son anormales, hay ${maps.length}!!! ¿ ++  ?');
    }
  }

  Future<List<PreviousTask>> getNotesFromDB() async {
    var dbClient = await db;
    List<PreviousTask> previousNotesList = [];
    List<Map> maps = await dbClient.query(taskTable, columns: [
      'id',
      'day',
      'month',
      'year',
      'note',
      'alarm',
    ]);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        previousNotesList.add(PreviousTask.fromMap(map));
      }
    }
    return previousNotesList;
  }

  Future<void> update(PreviousTask previousNotas) async {
    var dbClient = await db;
    await dbClient.update(
      taskTable,
      previousNotas.toMap(),
      where: "id = ?",
      whereArgs: [previousNotas.id],
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
