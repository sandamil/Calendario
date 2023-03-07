import 'package:sqflite/sqflite.dart';

import '../local/calendarDatabase.dart';

class ThemeModel {

  int? id;

  ThemeModel(
      {this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }


  Future<int> getThemeInt() async {
    final Database db = await TurnoDbProvider.instance.init();
    final List<Map<String, dynamic>> maps = await db.query('theme');
    List.generate(
      maps.length,
          (i) {
        return ThemeModel(
          id: maps[i]['id'],
        );
      },
    );
    return maps.first.values.first;
  }

  Future<void> updateTheme(int i) async {
    final Database db = await TurnoDbProvider.instance.init();
    await db.rawUpdate('''
    UPDATE theme
    SET id = ?
    ''', [i]);
  }
}