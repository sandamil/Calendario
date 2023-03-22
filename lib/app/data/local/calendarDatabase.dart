import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';

import '../model/turnoCalendar.dart';
import '../model/turnoType.dart';


class DBHelper {
  DBHelper._();
  static final DBHelper db = DBHelper._();
  static Database? _database;
  static const String _cuadrantes = 'Cuadrantes';
  static const String _turnos = 'Turnos';
  static const String _notas = 'Notas';
  static const int _version = 1;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await initDb();
  }

  Future<Database> initDb() async {
    Directory doucumentDirectory = await getApplicationDocumentsDirectory();
    print(doucumentDirectory.path);
    String path = join(doucumentDirectory.path, 'CalendarioAjatsoft.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $_cuadrantes('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, '
            'datetime TEXT, '
            'startHour TEXT, '
            'endHour TEXT, '
            'description TEXT, '
            'color TEXT)',
    );



    //     '''CREATE TABLE $_cuadrantes
    //   (
    //     id INTEGER PRIMARY KEY,
    //     datetime TEXT,
    //     title TEXT,
    //     starthour  TEXT,
    //     endhour TEXT,
    //     description TEXT,
    //     color TEXT
    //   )
    // ''');

    await db.execute('''CREATE TABLE $_turnos
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
      return Cuadrante.fromMap(result.first);
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
    return result.map((m) => Cuadrante.fromMap(m)).toList();
  }

  Future<int> addItemModel(Cuadrante itemModel) async {
    Database dbClient = await db;

    int res = await dbClient.insert("Cuadrante", itemModel.toMap(),
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

      int res = await dbClient.insert("Cuadrante", itemModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return res;
    } else {
      int res = await dbClient.insert("Cuadrante", itemModel.toMap(),
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


