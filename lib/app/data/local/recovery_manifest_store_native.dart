import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'recovery_manifest.dart';
import 'recovery_manifest_store.dart';

typedef TemporaryManifestWriter = Future<void> Function(
  File file,
  String contents,
);

class NativeRecoveryManifestStore implements RecoveryManifestStore {
  NativeRecoveryManifestStore._({
    required this.directory,
    this.writeTemporaryFile,
  });

  @visibleForTesting
  factory NativeRecoveryManifestStore.forTesting({
    required Directory directory,
    TemporaryManifestWriter? writeTemporaryFile,
  }) => NativeRecoveryManifestStore._(
    directory: directory,
    writeTemporaryFile: writeTemporaryFile,
  );

  final Directory directory;
  final TemporaryManifestWriter? writeTemporaryFile;

  static const String manifestFileName = 'calendar_recovery_manifest.json';
  static Future<void> _mutationQueue = Future<void>.value();

  File get _manifestFile => File(p.join(directory.path, manifestFileName));

  @override
  Future<RecoveryManifest?> read() async {
    final file = _manifestFile;
    if (!await file.exists()) {
      return null;
    }
    return RecoveryManifest.fromJson(await file.readAsString());
  }

  @override
  Future<void> create(RecoveryManifest manifest) => _serializeMutation(
    () async {
      final target = _manifestFile;
      if (await target.exists()) {
        final pending = await read();
        if (pending != null) {
          throw StateError('Ya existe una recuperación pendiente.');
        }
      }

      await directory.create(recursive: true);
      final temporary = File(
        p.join(directory.path, '$manifestFileName.${manifest.operationId}.tmp'),
      );
      if (await temporary.exists()) {
        throw StateError('Ya existe el archivo temporal del manifiesto.');
      }

      try {
        final writer = writeTemporaryFile;
        if (writer == null) {
          await temporary.create(exclusive: true);
          await temporary.writeAsString(manifest.toJsonString(), flush: true);
        } else {
          await writer(temporary, manifest.toJsonString());
        }

        // A rename must never replace a manifest written by another operation.
        if (await target.exists()) {
          throw StateError('Ya existe una recuperación pendiente.');
        }
        await temporary.rename(target.path);

        final persisted = await read();
        if (persisted == null ||
            jsonEncode(persisted.toJson()) != jsonEncode(manifest.toJson())) {
          throw StateError('No se pudo verificar el manifiesto persistido.');
        }
      } catch (_) {
        if (await temporary.exists()) {
          await temporary.delete();
        }
        rethrow;
      }
    },
  );

  @override
  Future<void> clear(String operationId) => _serializeMutation(() async {
    final pending = await read();
    if (pending == null) {
      return;
    }
    if (pending.operationId != operationId) {
      throw StateError('El manifiesto pertenece a otra operación.');
    }
    await _manifestFile.delete();
    if (await _manifestFile.exists()) {
      throw const FileSystemException('No se pudo borrar el manifiesto.');
    }
  });

  Future<T> _serializeMutation<T>(Future<T> Function() action) {
    final predecessor = _mutationQueue;
    final release = Completer<void>();
    _mutationQueue = release.future;
    return () async {
      await predecessor;
      try {
        return await action();
      } finally {
        release.complete();
      }
    }();
  }
}

Future<RecoveryManifestStore> createRecoveryManifestStore() async {
  final directory = await getApplicationSupportDirectory();
  return NativeRecoveryManifestStore._(directory: directory);
}
