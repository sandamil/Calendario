import 'dart:async';
import 'package:calendario2/app/data/model/previousTaskModel.dart';

import 'package:sqflite/sqflite.dart';



class PreviusDbProvider {
  static final PreviusDbProvider instance = PreviusDbProvider._internal();

  factory PreviusDbProvider() => instance;

  PreviusDbProvider._internal();

  static Database? _db;
  final String taskTable = 'notes';

  final String DATABASE_PATH =
  "/sdcard/Documents/Backup/backupDBC4A.db";


  get db async {

    if (_db != null) {
      return _db;
    }
    _db = await init();
    return _db;
  }


  Future<Database> init() async {
    String path = DATABASE_PATH;
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    final tables = await db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
  }


  Future<List<PreviousTask>> getPreviousTaskFromDB() async {
    var dbClient = await db;
    List<PreviousTask> notesList = [];
    List<Map> maps = await dbClient.query(taskTable, columns: [
      'id',
      'day',
      'month',
      'year',
      'note',
      'alarm'
    ]);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        notesList.add(PreviousTask.fromMap(map));
      }
    }
    print(notesList.asMap());

    return notesList;
  }

  
}