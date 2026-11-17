import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/persistence_coordinator.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:sqflite/sqflite.dart';

/// Genera y valida copias lógicas de los datos de la aplicación.
/// No depende del sistema de archivos ni de dart:io.
class AppBackupService {
  AppBackupService._();

  static const String format = 'calendario2.backup';
  static const int version = 1;
  static const String _restoreJournalTable = 'backup_restore_journal';

  /// Recovers a restore interrupted by process termination before the app UI
  /// can read either database.
  static Future<void> recoverPendingRestore({
    Database? calendarDatabase,
    Database? notesDatabase,
  }) => PersistenceCoordinator.run(() async {
    final calendarDb = calendarDatabase ?? await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError('No se pudo abrir la base de datos del calendario.');
    }
    final notesDb = notesDatabase ?? await NotasDB.instance.db;
    await _recoverPendingRestore(calendarDb, notesDb);
  });

  static Future<void> _recoverPendingRestore(
    Database calendarDb,
    Database notesDb,
  ) async {
    final table = await calendarDb.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [_restoreJournalTable],
    );
    if (table.isEmpty) return;

    final rows = await calendarDb.query(_restoreJournalTable);
    if (rows.isEmpty) return;
    if (rows.length != 1 || rows.single['id'] != 1) {
      throw StateError(
        'Diario de restauración inválido: se esperaba exactamente el registro 1. '
        'No se ha borrado ni modificado ninguna base de datos.',
      );
    }

    final journal = rows.single;
    final phase = journal['phase'] as String?;
    if (phase == 'complete') {
      await _requireHealthyDatabases(calendarDb, notesDb);
      await _clearRestoreJournal(calendarDb);
      return;
    }
    if (phase != 'prepared' && phase != 'external_recovery') {
      throw StateError(
        'Diario de restauración inválido: fase "$phase" desconocida. '
        'No se ha borrado ni modificado ninguna base de datos.',
      );
    }

    late final Map<String, dynamic> calendarSnapshot;
    late final List<dynamic> notesSnapshot;
    try {
      calendarSnapshot = _decodeCalendarSnapshot(
        _journalText(journal['calendar_snapshot'], 'calendario'),
      );
      notesSnapshot = _decodeNotesSnapshot(
        _journalText(journal['notes_snapshot'], 'notas'),
      );
    } catch (error) {
      throw StateError(
        'Diario de restauración corrupto ($error). No se ha borrado ni '
        'modificado. Conserva una copia de ambas bases, ejecuta '
        'inspectRestoreRecovery y usa una copia JSON v1 íntegra con '
        'recoverFromExternalBackupJson; no elimines el diario manualmente.',
      );
    }
    await _validateRestoredState(
      calendarDb,
      notesDb,
      calendarSnapshot,
      notesSnapshot,
    );
    await _requireHealthyDatabases(calendarDb, notesDb);
    await _applyRestoredState(
      calendarDb,
      notesDb,
      calendarSnapshot,
      notesSnapshot,
    );
    await _markRestoreJournalComplete(calendarDb);
    await _clearRestoreJournal(calendarDb);
  }

  /// Read-only report used to diagnose a startup blocked by a restore journal.
  static Future<RestoreRecoveryDiagnostics> inspectRestoreRecovery({
    Database? calendarDatabase,
    Database? notesDatabase,
  }) => PersistenceCoordinator.run(() async {
    final calendarDb = calendarDatabase ?? await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError('No se pudo abrir la base de datos del calendario.');
    }
    final notesDb = notesDatabase ?? await NotasDB.instance.db;
    final calendarIntegrity = await _integrityResult(calendarDb);
    final notesIntegrity = await _integrityResult(notesDb);
    final table = await calendarDb.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [_restoreJournalTable],
    );
    if (table.isEmpty) {
      return RestoreRecoveryDiagnostics(
        calendarIntegrity: calendarIntegrity,
        notesIntegrity: notesIntegrity,
        journalStatus: 'none',
      );
    }

    try {
      final rows = await calendarDb.query(_restoreJournalTable);
      if (rows.isEmpty) {
        return RestoreRecoveryDiagnostics(
          calendarIntegrity: calendarIntegrity,
          notesIntegrity: notesIntegrity,
          journalStatus: 'empty',
        );
      }
      if (rows.length != 1 || rows.single['id'] != 1) {
        throw const FormatException('Registros de diario inesperados.');
      }
      final journal = rows.single;
      final phase = journal['phase'];
      if (phase == 'complete') {
        return RestoreRecoveryDiagnostics(
          calendarIntegrity: calendarIntegrity,
          notesIntegrity: notesIntegrity,
          journalStatus: 'complete',
        );
      }
      if (phase != 'prepared' && phase != 'external_recovery') {
        throw FormatException('Fase desconocida: $phase');
      }
      final calendarSnapshot = _decodeCalendarSnapshot(
        _journalText(journal['calendar_snapshot'], 'calendario'),
      );
      final notesSnapshot = _decodeNotesSnapshot(
        _journalText(journal['notes_snapshot'], 'notas'),
      );
      await _validateRestoredState(
        calendarDb,
        notesDb,
        calendarSnapshot,
        notesSnapshot,
      );
      return RestoreRecoveryDiagnostics(
        calendarIntegrity: calendarIntegrity,
        notesIntegrity: notesIntegrity,
        journalStatus: phase as String,
      );
    } catch (error) {
      return RestoreRecoveryDiagnostics(
        calendarIntegrity: calendarIntegrity,
        notesIntegrity: notesIntegrity,
        journalStatus: 'corrupt',
        detail: error.toString(),
      );
    }
  });

  /// Replaces a corrupt/incomplete journal only after both SQLite files pass
  /// integrity checks and the supplied full v1 backup validates against both
  /// current schemas. The durable journal then reapplies that backup on every
  /// retry until all rows are restored.
  static Future<void> recoverFromExternalBackupJson(
    String source, {
    Database? calendarDatabase,
    Database? notesDatabase,
  }) => PersistenceCoordinator.run(() async {
    final backup = decodeAndValidateBackup(source);
    final data = backup['data'] as Map<String, dynamic>;
    final calendar = Map<String, dynamic>.from(data['calendar'] as Map);
    final notes = Map<String, dynamic>.from(data['notes'] as Map);
    final calendarDb = calendarDatabase ?? await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError('No se pudo abrir la base de datos del calendario.');
    }
    final notesDb = notesDatabase ?? await NotasDB.instance.db;

    final calendarIntegrity = await _integrityResult(calendarDb);
    final notesIntegrity = await _integrityResult(notesDb);
    if (calendarIntegrity != 'ok' || notesIntegrity != 'ok') {
      throw StateError(
        'Recuperación rechazada: integrity_check devolvió calendario='
        '"$calendarIntegrity" y notas="$notesIntegrity". '
        'Conserva una copia íntegra de ambos archivos antes de intervenir.',
      );
    }
    await _validateRestoredState(
      calendarDb,
      notesDb,
      calendar,
      notes['Notas'] as List,
    );

    await calendarDb.execute('''
          CREATE TABLE IF NOT EXISTS $_restoreJournalTable (
            id INTEGER PRIMARY KEY,
            phase TEXT NOT NULL,
            calendar_snapshot TEXT NOT NULL,
            notes_snapshot TEXT NOT NULL
          )
        ''');
    await _validateJournalSchema(calendarDb);
    await calendarDb.transaction((txn) async {
      await txn.delete(_restoreJournalTable);
      await txn.insert(_restoreJournalTable, {
        'id': 1,
        'phase': 'external_recovery',
        'calendar_snapshot': jsonEncode(calendar),
        'notes_snapshot': jsonEncode(notes['Notas']),
      });
    });
    await _recoverPendingRestore(calendarDb, notesDb);
  });

  static String _journalText(Object? value, String name) {
    if (value is! String) {
      throw FormatException('Falta la instantánea de $name en el diario.');
    }
    return value;
  }

  static Future<String> _integrityResult(Database db) async {
    final result = await db.rawQuery('PRAGMA integrity_check');
    if (result.length != 1 || result.single.values.single is! String) {
      return 'resultado inesperado';
    }
    return result.single.values.single as String;
  }

  static Future<void> _requireHealthyDatabases(
    Database calendarDb,
    Database notesDb,
  ) async {
    final calendarIntegrity = await _integrityResult(calendarDb);
    final notesIntegrity = await _integrityResult(notesDb);
    if (calendarIntegrity != 'ok' || notesIntegrity != 'ok') {
      throw StateError(
        'Recuperación detenida: integrity_check devolvió calendario='
        '"$calendarIntegrity" y notas="$notesIntegrity". '
        'El diario se conserva; copia ambos archivos antes de seguir.',
      );
    }
  }

  static Future<void> _validateJournalSchema(Database db) async {
    final info = await db.rawQuery(
      'PRAGMA table_info("$_restoreJournalTable")',
    );
    final columns = info.map((row) => row['name']).toSet();
    const required = {'id', 'phase', 'calendar_snapshot', 'notes_snapshot'};
    if (!columns.containsAll(required)) {
      throw StateError(
        'La tabla del diario tiene un esquema desconocido; no se modificó.',
      );
    }
  }

  /// Exporta calendario, tipos de turno, tema y notas a JSON.
  static Future<String> createBackupJson({
    Database? calendarDatabase,
    Database? notesDatabase,
  }) => PersistenceCoordinator.run(
    () => _createBackupJson(calendarDatabase, notesDatabase),
  );

  static Future<String> _createBackupJson(
    Database? calendarDatabase,
    Database? notesDatabase,
  ) async {
    final calendarDb = calendarDatabase ?? await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError('No se pudo abrir la base de datos del calendario.');
    }

    final notesDb = notesDatabase ?? await NotasDB.instance.db;
    await _recoverPendingRestore(calendarDb, notesDb);

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

      return <String, dynamic>{'Notas': notas};
    });

    final backup = <String, dynamic>{
      'format': format,
      'version': version,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'data': {'calendar': calendarData, 'notes': notesData},
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
      throw const FormatException('La copia debe contener un objeto JSON.');
    }

    final backup = Map<String, dynamic>.from(decoded);

    const allowedKeys = {'format', 'version', 'createdAt', 'data'};
    final unknownKeys = backup.keys
        .where((key) => !allowedKeys.contains(key))
        .toList();

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
      throw const FormatException('La copia no contiene la sección de datos.');
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
  static Future<void> restoreBackupJson(
    String source, {
    Database? calendarDatabase,
    Database? notesDatabase,
  }) => PersistenceCoordinator.run(
    () => _restoreBackupJson(source, calendarDatabase, notesDatabase),
  );

  static Future<void> _restoreBackupJson(
    String source,
    Database? calendarDatabase,
    Database? notesDatabase,
  ) async {
    // Validar el archivo antes de abrir transacciones de escritura.
    final backup = decodeAndValidateBackup(source);

    final data = backup['data'] as Map<String, dynamic>;
    final calendar = Map<String, dynamic>.from(data['calendar'] as Map);
    final notes = Map<String, dynamic>.from(data['notes'] as Map);

    final calendarDb = calendarDatabase ?? await CalendarioDB.db.database;
    if (calendarDb == null) {
      throw StateError('No se pudo abrir la base de datos del calendario.');
    }

    final notesDb = notesDatabase ?? await NotasDB.instance.db;
    await _recoverPendingRestore(calendarDb, notesDb);

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
    await _validateTableColumns(calendarDb, 'theme', calendar['theme'] as List);
    await _validateTableColumns(notesDb, 'Notas', notes['Notas'] as List);

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

    final previousCalendarJson = jsonEncode(previousCalendar);
    final previousNotesJson = jsonEncode(previousNotes);
    await calendarDb.execute('''
      CREATE TABLE IF NOT EXISTS $_restoreJournalTable (
        id INTEGER PRIMARY KEY,
        phase TEXT NOT NULL,
        calendar_snapshot TEXT NOT NULL,
        notes_snapshot TEXT NOT NULL
      )
    ''');
    await calendarDb.transaction((txn) async {
      await txn.delete(_restoreJournalTable);
      await txn.insert(_restoreJournalTable, {
        'id': 1,
        'phase': 'prepared',
        'calendar_snapshot': previousCalendarJson,
        'notes_snapshot': previousNotesJson,
      });
    });

    try {
      await _applyRestoredState(
        calendarDb,
        notesDb,
        calendar,
        notes['Notas'] as List,
      );
      await _markRestoreJournalComplete(calendarDb);
      await _clearRestoreJournal(calendarDb);
    } catch (restoreError) {
      try {
        await _applyRestoredState(
          calendarDb,
          notesDb,
          previousCalendar,
          previousNotes,
        );
        await _markRestoreJournalComplete(calendarDb);
        await _clearRestoreJournal(calendarDb);
      } catch (rollbackError) {
        throw StateError(
          'Falló la restauración ($restoreError) y también la recuperación '
          'de los datos anteriores ($rollbackError). El diario persistente '
          'intentará recuperarlos al iniciar la aplicación.',
        );
      }
      throw StateError(
        'La restauración falló; se recuperó el estado anterior: $restoreError',
      );
    }
  }

  static Future<void> _applyRestoredState(
    Database calendarDb,
    Database notesDb,
    Map<String, dynamic> calendar,
    List<dynamic> noteRows,
  ) async {
    await calendarDb.transaction((txn) async {
      for (final table in ['Cuadrante', 'Turnos', 'theme']) {
        await txn.delete(table);
        for (final row in List<Map<String, dynamic>>.from(
          calendar[table] as List,
        )) {
          await txn.insert(table, Map<String, Object?>.from(row));
        }
      }
    });
    await notesDb.transaction((txn) async {
      await txn.delete('Notas');
      for (final row in List<Map<String, dynamic>>.from(noteRows)) {
        await txn.insert('Notas', Map<String, Object?>.from(row));
      }
    });
  }

  static Future<void> _validateRestoredState(
    Database calendarDb,
    Database notesDb,
    Map<String, dynamic> calendar,
    List<dynamic> noteRows,
  ) async {
    for (final table in ['Cuadrante', 'Turnos', 'theme']) {
      await _validateTableColumns(calendarDb, table, calendar[table] as List);
    }
    await _validateTableColumns(notesDb, 'Notas', noteRows);
  }

  static Future<void> _markRestoreJournalComplete(Database db) =>
      db.update(_restoreJournalTable, {'phase': 'complete'}, where: 'id = 1');

  static Future<void> _clearRestoreJournal(Database db) async {
    try {
      await db.delete(_restoreJournalTable, where: 'id = 1');
    } catch (error) {
      debugPrint('[BACKUP] No se pudo limpiar el diario: $error');
    }
  }

  static Map<String, dynamic> _decodeCalendarSnapshot(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Diario calendario corrupto.');
    }
    final snapshot = Map<String, dynamic>.from(decoded);
    for (final table in ['Cuadrante', 'Turnos', 'theme']) {
      _validateRows(snapshot[table], table);
    }
    return snapshot;
  }

  static List<dynamic> _decodeNotesSnapshot(String source) {
    final decoded = jsonDecode(source);
    _validateRows(decoded, 'Notas');
    return decoded as List<dynamic>;
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
      throw FormatException('La base de datos no contiene la tabla $table.');
    }

    final columns = info.map((column) => column['name'] as String).toSet();

    final requiredColumns = info
        .where(
          (column) =>
              column['notnull'] == 1 &&
              column['dflt_value'] == null &&
              column['pk'] != 1,
        )
        .map((column) => column['name'] as String)
        .toSet();

    for (final item in rows) {
      if (item is! Map) {
        throw FormatException('Registro inválido en la tabla $table.');
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

class RestoreRecoveryDiagnostics {
  const RestoreRecoveryDiagnostics({
    required this.calendarIntegrity,
    required this.notesIntegrity,
    required this.journalStatus,
    this.detail,
  });

  final String calendarIntegrity;
  final String notesIntegrity;
  final String journalStatus;
  final String? detail;

  bool get databasesAreHealthy =>
      calendarIntegrity == 'ok' && notesIntegrity == 'ok';
}
