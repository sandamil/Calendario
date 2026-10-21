import 'dart:convert';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';

/// Genera y valida copias lógicas de los datos de la aplicación.
/// No depende del sistema de archivos ni de dart:io.
class AppBackupService {
  AppBackupService._();

  static const String format = 'calendario2.backup';
  static const int version = 1;

  /// Exporta calendario, tipos de turno, tema y notas a JSON.
  static Future<String> createBackupJson() async {
    final calendarDb = await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError(
        'No se pudo abrir la base de datos del calendario.',
      );
    }

    final notesDb = await NotasDB.instance.db;

    // Obtener y validar una instantánea transaccional del calendario.
    final calendarData = await calendarDb.transaction((txn) async {
      final cuadrantes = await txn.query('Cuadrante');
      final turnos = await txn.query('Turnos');
      final temas = await txn.query('theme');

      await _validateTableColumns(txn, 'Cuadrante', cuadrantes);
      await _validateTableColumns(txn, 'Turnos', turnos);
      await _validateTableColumns(txn, 'theme', temas);

      return <String, dynamic>{
        'Cuadrante': cuadrantes,
        'Turnos': turnos,
        'theme': temas,
      };
    });

    // Obtener y validar una instantánea transaccional de las notas.
    final notesData = await notesDb.transaction((txn) async {
      final notas = await txn.query('Notas');
      await _validateTableColumns(txn, 'Notas', notas);

      return <String, dynamic>{
        'Notas': notas,
      };
    });

    final backup = <String, dynamic>{
      'format': format,
      'version': version,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'calendar': calendarData,
        'notes': notesData,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  /// Valida el formato y la estructura sin modificar ninguna base de datos.
  /// Devuelve el contenido decodificado o lanza FormatException.
  static Map<String, dynamic> decodeAndValidateBackup(String source) {
    final Object? decoded;

    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('El archivo no contiene JSON válido.');
    }

    if (decoded is! Map) {
      throw const FormatException(
        'La copia debe contener un objeto JSON.',
      );
    }

    final backup = Map<String, dynamic>.from(decoded);

    const allowedKeys = {'format', 'version', 'createdAt', 'data'};
    final unknownKeys =
        backup.keys.where((key) => !allowedKeys.contains(key)).toList();

    if (unknownKeys.isNotEmpty) {
      throw FormatException(
        'La copia contiene campos desconocidos: '
        '${unknownKeys.join(", ")}.',
      );
    }

    if (backup['createdAt'] is! String ||
        DateTime.tryParse(backup['createdAt'] as String) == null) {
      throw const FormatException(
        'La copia no contiene una fecha de creación válida.',
      );
    }

    if (backup['format'] != format) {
      throw const FormatException(
        'El archivo no es una copia de Calendario compatible.',
      );
    }

    if (backup['version'] != version) {
      throw FormatException(
        'Versión de copia no compatible: ${backup['version']}.',
      );
    }

    final data = backup['data'];
    if (data is! Map) {
      throw const FormatException(
        'La copia no contiene la sección de datos.',
      );
    }

    final calendar = data['calendar'];
    final notes = data['notes'];

    if (calendar is! Map || notes is! Map) {
      throw const FormatException(
        'Faltan los datos del calendario o de las notas.',
      );
    }

    _validateRows(calendar['Cuadrante'], 'Cuadrante');
    _validateRows(calendar['Turnos'], 'Turnos');
    _validateRows(calendar['theme'], 'theme');
    _validateRows(notes['Notas'], 'Notas');

    return backup;
  }

  /// Restaura una copia previamente validada.
  ///
  /// La validación se realiza antes de modificar ninguna base de datos.
  /// Cada base de datos se restaura dentro de su propia transacción.
  static Future<void> restoreBackupJson(String source) async {
    // Validar el archivo antes de abrir transacciones de escritura.
    final backup = decodeAndValidateBackup(source);

    final data = backup['data'] as Map<String, dynamic>;
    final calendar = Map<String, dynamic>.from(
      data['calendar'] as Map,
    );
    final notes = Map<String, dynamic>.from(
      data['notes'] as Map,
    );

    final calendarDb = await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError(
        'No se pudo abrir la base de datos del calendario.',
      );
    }

    final notesDb = await NotasDB.instance.db;

    // Validar todas las tablas destino antes de modificar datos.
    await _validateTableColumns(
      calendarDb,
      'Cuadrante',
      calendar['Cuadrante'] as List,
    );
    await _validateTableColumns(
      calendarDb,
      'Turnos',
      calendar['Turnos'] as List,
    );
    await _validateTableColumns(
      calendarDb,
      'theme',
      calendar['theme'] as List,
    );
    await _validateTableColumns(
      notesDb,
      'Notas',
      notes['Notas'] as List,
    );

    // Guardar el estado anterior de las dos bases de datos.
    final previousCalendar = await calendarDb.transaction((txn) async {
      return <String, List<Map<String, Object?>>>{
        'Cuadrante': await txn.query('Cuadrante'),
        'Turnos': await txn.query('Turnos'),
        'theme': await txn.query('theme'),
      };
    });

    final previousNotes = await notesDb.transaction((txn) async {
      return await txn.query('Notas');
    });

    try {
      await calendarDb.transaction((txn) async {
        await txn.delete('Cuadrante');
        await txn.delete('Turnos');
        await txn.delete('theme');

        for (final row in List<Map<String, dynamic>>.from(
          calendar['Cuadrante'] as List,
        )) {
          await txn.insert(
            'Cuadrante',
            Map<String, Object?>.from(row),
          );
        }

        for (final row in List<Map<String, dynamic>>.from(
          calendar['Turnos'] as List,
        )) {
          await txn.insert(
            'Turnos',
            Map<String, Object?>.from(row),
          );
        }

        for (final row in List<Map<String, dynamic>>.from(
          calendar['theme'] as List,
        )) {
          await txn.insert(
            'theme',
            Map<String, Object?>.from(row),
          );
        }
      });

      await notesDb.transaction((txn) async {
        await txn.delete('Notas');

        for (final row in List<Map<String, dynamic>>.from(
          notes['Notas'] as List,
        )) {
          await txn.insert(
            'Notas',
            Map<String, Object?>.from(row),
          );
        }
      });
    } catch (restoreError) {
      // Si falla alguna restauración, intentar recuperar los datos previos.
      try {
        await calendarDb.transaction((txn) async {
          await txn.delete('Cuadrante');
          await txn.delete('Turnos');
          await txn.delete('theme');

          for (final row in previousCalendar['Cuadrante']!) {
            await txn.insert('Cuadrante', row);
          }

          for (final row in previousCalendar['Turnos']!) {
            await txn.insert('Turnos', row);
          }

          for (final row in previousCalendar['theme']!) {
            await txn.insert('theme', row);
          }
        });

        await notesDb.transaction((txn) async {
          await txn.delete('Notas');

          for (final row in previousNotes) {
            await txn.insert('Notas', row);
          }
        });
      } catch (rollbackError) {
        throw StateError(
          'Falló la restauración ($restoreError) y también la recuperación '
          'de los datos anteriores ($rollbackError). '
          'No continúes modificando los datos hasta comprobar las bases '
          'de datos.',
        );
      }

      throw StateError(
        'La restauración falló y se recuperaron los datos anteriores: '
        '$restoreError',
      );
    }
  }

  /// Comprueba que las filas solo contengan columnas existentes
  /// y que incluyan las columnas obligatorias de la tabla.
  static Future<void> _validateTableColumns(
    dynamic db,
    String table,
    List rows,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info("$table")');

    if (info.isEmpty) {
      throw FormatException(
        'La base de datos no contiene la tabla $table.',
      );
    }

    final columns = info.map((column) => column['name'] as String).toSet();

    final requiredColumns = info
        .where((column) =>
            column['notnull'] == 1 &&
            column['dflt_value'] == null &&
            column['pk'] != 1)
        .map((column) => column['name'] as String)
        .toSet();

    for (final item in rows) {
      if (item is! Map) {
        throw FormatException(
          'Registro inválido en la tabla $table.',
        );
      }

      final row = Map<String, dynamic>.from(item);
      final unknown = row.keys.where((key) => !columns.contains(key)).toList();

      if (unknown.isNotEmpty) {
        throw FormatException(
          'La tabla $table no reconoce estas columnas: '
          '${unknown.join(", ")}.',
        );
      }

      final missing = requiredColumns
          .where((column) => !row.containsKey(column) || row[column] == null)
          .toList();

      if (missing.isNotEmpty) {
        throw FormatException(
          'Faltan columnas obligatorias en $table: '
          '${missing.join(", ")}.',
        );
      }
    }
  }

  static void _validateRows(Object? value, String table) {
    if (value is! List) {
      throw FormatException(
        'La copia no contiene una lista válida para $table.',
      );
    }

    for (final row in value) {
      if (row is! Map || row.keys.any((key) => key is! String)) {
        throw FormatException(
          'La copia contiene un registro inválido en $table.',
        );
      }
    }
  }
}
