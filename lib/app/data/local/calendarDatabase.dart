import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';

import '../model/turnoCalendar.dart';
import '../model/turnoType.dart';


class TurnoDbProvider {
  //The singleton pattern ensures only one instance of a class is ever created.
  static final TurnoDbProvider instance = TurnoDbProvider._internal();
  factory TurnoDbProvider() => instance;
  TurnoDbProvider._internal();
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
    String path = join(doucumentDirectory.path, 'TurnoDatabase.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE Cuadrante
      (
        id INTEGER PRIMARY KEY,
        datetime TEXT,
        title TEXT,
        starthour  TEXT,
        endhour TEXT,
        description TEXT,
        color TEXT
      )
    ''');

    await db.execute('''CREATE TABLE TurnoType
      (
        id INTEGER PRIMARY KEY,
        description TEXT,
        title TEXT,
        starthour  TEXT,
        endhour TEXT,
        color TEXT,
        status TEXT
      )
    ''');

    db.execute("CREATE TABLE theme ("
        "id INTEGER NOT NULL"
        ")");

    db.execute("INSERT into TurnoType(id, title, description, color) "   ' VALUES(1, "M", "Mañana", "4287f5") ');
    db.execute("INSERT into TurnoType(id, title, description, color) "   ' VALUES(2, "T", "Tarde", "71bd48")  ');
    db.execute("INSERT into TurnoType(id, title, description, color) "   ' VALUES(3, "N", "Noche", "bd9648")  ');
    db.execute("INSERT into TurnoType(id, title, description, color) "   ' VALUES(4, "L", "Libre", "ffffff")  ');


    db.execute("INSERT into theme (id) "
        "VALUES(0) ");

    print("Database was Created!");
  }




  Future<Cuadrante?> fetchItem(int id) async {
    var dbClient = await db;
    List result =
    await dbClient.query(
        "Cuadrante",
        where: "id = ?",
        whereArgs: [id]
    );
    if (result.length == 0) {
      return null;
    } else {
      return Cuadrante.fromDb(result.first);
    }
  }

  Future<List<Cuadrante>> getItemModels() async {
    var dbClient = await db;

    var _day = DateTime.now();
    DateTime dayStart = _day.subtract(Duration(days: 60));
    DateTime dayEnd = _day.add(Duration(days: 300));

    List<Map<String, dynamic>> result =
    await dbClient.rawQuery(
        "SELECT * FROM Cuadrante WHERE datetime BETWEEN '${dayStart.toString()}' AND '${dayEnd.toString()}'");
    return result.map((m) => Cuadrante.fromDb(m)).toList();
  }

  Future<int> addItemModel(Cuadrante itemModel) async {
    Database dbClient = await db;

    int res = await dbClient.insert("Cuadrante", itemModel.toDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<int> replaceItemModel(Cuadrante itemModel) async {
    Database dbClient = await db;
    List result = await dbClient.query("Cuadrante",
        where: "datetime = ?",
        whereArgs: [itemModel.dateTime?.toIso8601String()]);
    if (result.length != 0) {
      for (var item in result) {
        await deleteItemDateTime(item['datetime']);
      }

      int res = await dbClient.insert("Cuadrante", itemModel.toDb(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return res;
    } else {
      int res = await dbClient.insert("Cuadrante", itemModel.toDb(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return res;
    }
  }

  Future<void> deleteItemDateTime(String dateTime) async {
    Database dbClient = await db;
    await dbClient
        .delete('Cuadrante', where: "datetime = ?", whereArgs: [dateTime]);
    print('deleted');
  }

  Future<void> deleteItemID(int id) async {
    Database dbClient = await db;
    await dbClient
        .delete(
        'Cuadrante',
        where: "id = ?",
        whereArgs: [id]);
    print('deleted');
  }

  Future<List<TurnoType>> getTypeModels() async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query("TurnoType");
    return result.map((m) => TurnoType.fromDb(m)).toList();
  }

  Future<int> addTypeModel(TurnoType itemModel) async {
    Database dbClient = await db;
    int res = await dbClient.insert("TurnoType", itemModel.toDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<void> deleteTypeId(int id) async {
    Database dbClient = await db;
    await dbClient
        .delete('TurnoType', where: "id = ?", whereArgs: [id]);
    print('deleted');
  }

  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<int> clear() async {
    Database dbClient = await db;
    return await dbClient.delete("Cuadrante");
  }
}


