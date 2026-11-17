import 'dart:io';

import 'package:calendario2/app/data/local/recovery_manifest.dart';
import 'package:calendario2/app/data/local/recovery_manifest_store_native.dart';
import 'package:flutter_test/flutter_test.dart';

const _calendarTarget = '/app/support/CalendarioAjatsoft.db';
const _notesTarget = '/app/support/notas_database.db';
const _operationId = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _calendarHash =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
const _notesHash =
    'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210';

RecoveryManifestPathPolicy _policy() => const RecoveryManifestPathPolicy(
  calendarTargetPath: _calendarTarget,
  notesTargetPath: _notesTarget,
);

RecoveryManifest _manifest({
  String operationId = _operationId,
  String calendarTargetPath = _calendarTarget,
  String notesTargetPath = _notesTarget,
  String? calendarStagePath,
  String? notesStagePath,
  String calendarSha256 = _calendarHash,
  String notesSha256 = _notesHash,
}) {
  final policy = RecoveryManifestPathPolicy(
    calendarTargetPath: calendarTargetPath,
    notesTargetPath: notesTargetPath,
  );
  return RecoveryManifest(
    version: 1,
    operationId: operationId,
    calendarTargetPath: calendarTargetPath,
    notesTargetPath: notesTargetPath,
    calendarStagePath:
        calendarStagePath ?? policy.calendarStagePath(operationId),
    notesStagePath: notesStagePath ?? policy.notesStagePath(operationId),
    calendarSha256: calendarSha256,
    notesSha256: notesSha256,
  );
}

void main() {
  group('RecoveryManifest', () {
    test('round_trips_manifest_v1', () {
      final original = _manifest();

      final decoded = RecoveryManifest.fromJson(original.toJsonString());

      expect(decoded.toJson(), original.toJson());
      expect(decoded.version, 1);
      expect(decoded.operationId, _operationId);
    });

    test('rejects_unknown_manifest_version', () {
      final json = _manifest().toJson()..['version'] = 2;

      expect(() => RecoveryManifest.fromMap(json), throwsFormatException);
    });

    test('rejects_empty_truncated_and_invalid_json', () {
      for (final input in ['', '{', '{"version":1,,}', 'null']) {
        expect(
          () => RecoveryManifest.fromJson(input),
          throwsFormatException,
          reason: 'input: $input',
        );
      }
    });

    test('rejects_unknown_fields_and_invalid_hashes', () {
      final extraField = _manifest().toJson()..['extra'] = true;
      final invalidHash = _manifest().toJson()..['calendarSha256'] = 'xyz';

      expect(() => RecoveryManifest.fromMap(extraField), throwsFormatException);
      expect(
        () => RecoveryManifest.fromMap(invalidHash),
        throwsFormatException,
      );
    });

    test('rejects_unexpected_target_and_stage_paths', () {
      final policy = _policy();
      final wrongTarget = _manifest(calendarTargetPath: '/tmp/other.db');
      final escapedStage = _manifest(
        calendarStagePath: '/app/support/../outside.stage',
      );
      final wrongOperation = _manifest(
        calendarStagePath: policy.calendarStagePath(
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        ),
      );

      expect(() => wrongTarget.validatePaths(policy), throwsFormatException);
      expect(() => escapedStage.validatePaths(policy), throwsFormatException);
      expect(() => wrongOperation.validatePaths(policy), throwsFormatException);
    });

    test('generates_unique_32_character_hex_operation_ids', () {
      final first = RecoveryManifest.generateOperationId();
      final second = RecoveryManifest.generateOperationId();

      expect(first, matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(second, matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(first, isNot(second));
    });
  });

  group('NativeRecoveryManifestStore', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('manifest-test-');
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('refuses_to_replace_pending_manifest', () async {
      final store = NativeRecoveryManifestStore.forTesting(
        directory: directory,
      );
      await store.create(_manifest());

      await expectLater(
        store.create(
          _manifest(operationId: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),
        ),
        throwsStateError,
      );
      expect((await store.read())?.operationId, _operationId);
    });

    test('clear_requires_matching_operation_id', () async {
      final store = NativeRecoveryManifestStore.forTesting(
        directory: directory,
      );
      await store.create(_manifest());

      await expectLater(
        store.clear('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),
        throwsStateError,
      );
      expect((await store.read())?.operationId, _operationId);
      await store.clear(_operationId);
      expect(await store.read(), isNull);
    });

    test('native_store_write_failure_leaves_no_partial_manifest', () async {
      final store = NativeRecoveryManifestStore.forTesting(
        directory: directory,
        writeTemporaryFile: (file, contents) async {
          await file.writeAsString(contents.substring(0, 8));
          throw const FileSystemException('simulated disk full');
        },
      );

      await expectLater(
        store.create(_manifest()),
        throwsA(isA<FileSystemException>()),
      );
      expect(await store.read(), isNull);
      expect(
        directory.listSync().where((entity) => entity.path.endsWith('.json')),
        isEmpty,
      );
    });
  });
}
