import 'dart:async';
import 'package:calendario2/app/data/model/previousDatabase/previousTaskModel.dart';

import 'package:sqflite/sqflite.dart';

import '../model/previousDatabase/customShiftTemplate.dart';
import '../model/previousDatabase/previousShift.dart';



class PreviusDbProvider {
  static final PreviusDbProvider instance = PreviusDbProvider._internal();

  factory PreviusDbProvider() => instance;

  PreviusDbProvider._internal();

  static Database? _db;
  final String taskTable = 'notes';
  final String turnosPersonalizadosTable = 'shifts';
  final String turnosCalendarioTable = 'customShift';

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

  Future<List<PreviousShift>> getTurnosPersonalizadosFromDB() async {
    var dbClient = await db;
    List<PreviousShift> previousShiftList = [];

    List<Map> maps = await dbClient.query(turnosPersonalizadosTable, columns: [
      'id',
      'title',
      'short',
      'timeFrom',
      'timeTo',
      'color',
      'location',
      'alarm'
    ]);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        previousShiftList.add(PreviousShift.fromMap(map));
      }
    }
    print(previousShiftList.asMap());

    return previousShiftList;
  }




  Future<List<CustomShitTemplate>> getTurnosCalendarioFromDB() async {
    var dbClient = await db;
    List<CustomShitTemplate> previousTurnosCAlendariotList = [];

    List<Map> maps = await dbClient.query(turnosCalendarioTable, columns: [
      'id',
      'day',
      'month',
      'year',
      'shift',
      'alarm'
    ]);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        previousTurnosCAlendariotList.add(CustomShitTemplate.fromMap(map));
      }
    }
    print(previousTurnosCAlendariotList.asMap());

    return previousTurnosCAlendariotList;
  }

  getShift(id) async {

    final dbClient = await db;
    final maps = await dbClient.query(turnosPersonalizadosTable, where: '_id = ?', whereArgs: [id]);

    return PreviousShift.fromMap(maps[0]);

  }


}