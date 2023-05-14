import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';

import '../model/cuadranteDay.dart';
import '../model/turnoType.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper db = DBHelper._();
  static Database? _database;
  static const String _cuadrantes = 'Cuadrante';
  static const String _turnos = 'Turnos';
  static const int _version = 1;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await initDb();
  }

  Future<Database> initDb() async {
    Directory doucumentDirectory = await getApplicationDocumentsDirectory();
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
      'cuadranteName STRING, '
      'title STRING, '
      'datetime TEXT, '
      'startHour TEXT, '
      'endHour TEXT, '
      'description TEXT, '
      'color TEXT)',
    );

    await db.execute('''CREATE TABLE $_turnos
      (
        id INTEGER PRIMARY KEY,
        description TEXT,
        title TEXT,
        startHour  TEXT,
        endHour TEXT,
        color TEXT,
        status TEXT
      )
    ''');

    db.execute("CREATE TABLE theme ("
        "id INTEGER NOT NULL"
        ")");

    db.execute(
        "INSERT into $_turnos(id, title, description, color, startHour, endHour) "
        ' VALUES(1, "M", "Mañana", "4287f5", "07:00", "15:00") ');
    db.execute(
        "INSERT into $_turnos(id, title, description, color, startHour, endHour) "
        ' VALUES(2, "T", "Tarde", "71bd48", "15:00", "22:00")  ');
    db.execute(
        "INSERT into $_turnos(id, title, description, color, startHour, endHour) "
        ' VALUES(3, "N", "Noche", "bd9648", "22:00", "07:00")  ');
    db.execute(
        "INSERT into $_turnos(id, title, description, color, startHour, endHour) "
        ' VALUES(4, "L", "Libre", "ffffff", "00:00", "23:59")  ');
  }

  Future<CuadranteDay?> fetchItem(int id) async {
    final dbClient = await database;
    List result =
        await dbClient!.query(_cuadrantes, where: "id = ?", whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    } else {
      return CuadranteDay.fromMap(result.first);
    }
  }

  Future<List<CuadranteDay>> getItemModels() async {
    final dbClient = await database;

    var day = DateTime.now();
    DateTime dayStart = day.subtract(const Duration(days: 60));
    DateTime dayEnd = day.add(const Duration(days: 300));

    List<Map<String, dynamic>> result =
        await dbClient!.rawQuery("SELECT * FROM $_cuadrantes");

    return result.map((m) => CuadranteDay.fromMap(m)).toList();
  }

  Future<int> addItem(CuadranteDay item) async {
    final dbClient = await database;
    int res = await dbClient!.insert("Cuadrante", item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<int> updateItem(CuadranteDay item) async {
    final dbClient = await database;
    await dbClient!.delete("Cuadrante",
        where: "datetime = ? and cuadranteName=?",
        whereArgs: [
          item.dateTime?.toIso8601String().substring(0, 10),
          item.cuadranteName
        ]);
    int res = await dbClient!.insert("Cuadrante", item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  // Future<int> replaceItemModel(Cuadrante itemModel) async {
  //   Database? dbClient = await database;
  //   List result = await dbClient!.query("Cuadrante",
  //       where: "datetime = ?",
  //       whereArgs: [itemModel.dateTime?.toIso8601String().substring(0,10)]);
  //   if (result.length != 0) {
  //     for (var item in result) {
  //       await deleteItemDateTime(item['datetime']);
  //     }
  //
  //     int res = await dbClient.insert("Cuadrante", itemModel.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.ignore);
  //     return res;
  //   } else {
  //     int res = await dbClient.insert("Cuadrante", itemModel.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.ignore);
  //     return res;
  //   }
  // }

  Future<void> deleteItemDateTime(String dateTime) async {
    Database? dbClient = await database;
    await dbClient!
        .delete(_cuadrantes, where: "datetime = ?", whereArgs: [dateTime]);
  }

  Future<void> deleteCuadrante(String cuadranteName) async {
    Database? dbClient = await database;
    await dbClient!.delete(_cuadrantes,
        where: "cuadranteName = ?", whereArgs: [cuadranteName]);
  }

  Future<void> deleteALlCuadrante() async {
    Database? dbClient = await database;
    await dbClient!.delete(_cuadrantes);
  }

  Future<void> deleteItemID(int id) async {
    Database? dbClient = await database;
    await dbClient!.delete(_cuadrantes, where: "id = ?", whereArgs: [id]);
  }

  Future<List<TurnoType>> getTypeModels() async {
    final dbClient = await database;
    List<Map<String, dynamic>> result = await dbClient!.query(_turnos);
    return result.map((m) => TurnoType.fromMap(m)).toList();
  }

  Future<int> addTypeModel(TurnoType itemModel) async {
    final dbClient = await database;
    int res = await dbClient!.insert(_turnos, itemModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<void> deleteTypeId(int id) async {
    final dbClient = await database;
    await dbClient!.delete(_turnos, where: "id = ?", whereArgs: [id]);
  }

  Future closeDb() async {
    var dbClient = await database;
    dbClient!.close();
  }

  Future<int> clear() async {
    Database? dbClient = await database;
    return await dbClient!.delete(_cuadrantes);
  }
}
