import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:calendario2/app/data/local/backup_service.dart';

void main() {
  Map<String, dynamic> validBackup() {
    return {
      'format': 'calendario2.backup',
      'version': 1,
      'createdAt': '2026-10-21T10:00:00.000Z',
      'data': {
        'calendar': {
          'Cuadrante': <Map<String, dynamic>>[],
          'Turnos': <Map<String, dynamic>>[],
          'theme': <Map<String, dynamic>>[],
        },
        'notes': {
          'Notas': <Map<String, dynamic>>[],
        },
      },
    };
  }

  group('AppBackupService.decodeAndValidateBackup', () {
    test('acepta una copia válida con tablas vacías', () {
      final source = jsonEncode(validBackup());

      final result = AppBackupService.decodeAndValidateBackup(source);

      expect(result['format'], 'calendario2.backup');
      expect(result['version'], 1);
    });

    test('rechaza JSON mal formado', () {
      expect(
        () => AppBackupService.decodeAndValidateBackup('{no-json'),
        throwsFormatException,
      );
    });

    test('rechaza una fecha de creación inválida', () {
      final backup = validBackup();
      backup['createdAt'] = 'fecha-inválida';

      expect(
        () => AppBackupService.decodeAndValidateBackup(
          jsonEncode(backup),
        ),
        throwsFormatException,
      );
    });

    test('rechaza un formato de copia incompatible', () {
      final backup = validBackup();
      backup['format'] = 'otro.formato';

      expect(
        () => AppBackupService.decodeAndValidateBackup(
          jsonEncode(backup),
        ),
        throwsFormatException,
      );
    });

    test('rechaza una sección de notas ausente', () {
      final backup = validBackup();
      (backup['data'] as Map<String, dynamic>).remove('notes');

      expect(
        () => AppBackupService.decodeAndValidateBackup(
          jsonEncode(backup),
        ),
        throwsFormatException,
      );
    });

    test('rechaza campos desconocidos en la raíz', () {
      final backup = validBackup();
      backup['extra'] = 'campo no permitido';

      expect(
        () => AppBackupService.decodeAndValidateBackup(
          jsonEncode(backup),
        ),
        throwsFormatException,
      );
    });

    test('rechaza una versión incompatible', () {
      final backup = validBackup();
      backup['version'] = 999;

      expect(
        () => AppBackupService.decodeAndValidateBackup(
          jsonEncode(backup),
        ),
        throwsFormatException,
      );
    });

    test('rechaza una tabla que no sea una lista', () {
      final source = jsonEncode(validBackup()).replaceFirst(
        '"Cuadrante":[]',
        '"Cuadrante":"no es una lista"',
      );

      expect(
        source,
        contains('"Cuadrante":"no es una lista"'),
      );
      expect(
        () => AppBackupService.decodeAndValidateBackup(source),
        throwsFormatException,
      );
    });

    test('rechaza registros que no sean objetos', () {
      final source = jsonEncode(validBackup()).replaceFirst(
        '"Cuadrante":[]',
        '"Cuadrante":["registro inválido"]',
      );

      expect(
        () => AppBackupService.decodeAndValidateBackup(source),
        throwsFormatException,
      );
    });
  });
}
