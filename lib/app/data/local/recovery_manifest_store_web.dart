import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:web/web.dart' as web;

import 'recovery_manifest.dart';
import 'recovery_manifest_store.dart';

typedef ManifestValueReader = String? Function();
typedef ManifestValueWriter = void Function(String value);
typedef ManifestValueRemover = void Function();

class WebRecoveryManifestStore implements RecoveryManifestStore {
  WebRecoveryManifestStore()
    : this._(
        readValue: () => web.window.localStorage.getItem(storageKey),
        writeValue: (value) =>
            web.window.localStorage.setItem(storageKey, value),
        removeValue: () => web.window.localStorage.removeItem(storageKey),
      );

  @visibleForTesting
  factory WebRecoveryManifestStore.forTesting({
    required ManifestValueReader readValue,
    required ManifestValueWriter writeValue,
    required ManifestValueRemover removeValue,
  }) => WebRecoveryManifestStore._(
    readValue: readValue,
    writeValue: writeValue,
    removeValue: removeValue,
  );

  WebRecoveryManifestStore._({
    required this.readValue,
    required this.writeValue,
    required this.removeValue,
  });

  static const String storageKey = 'calendario.recovery.manifest.v1';

  final ManifestValueReader readValue;
  final ManifestValueWriter writeValue;
  final ManifestValueRemover removeValue;

  RecoveryManifest? _readCurrent() {
    final value = readValue();
    if (value == null) {
      return null;
    }
    return RecoveryManifest.fromJson(value);
  }

  @override
  Future<RecoveryManifest?> read() async => _readCurrent();

  @override
  Future<void> create(RecoveryManifest manifest) async {
    if (_readCurrent() != null) {
      throw StateError('Ya existe una recuperación pendiente.');
    }

    // localStorage.setItem replaces one value atomically or throws (for
    // example, on quota exhaustion); never fall back to another key.
    writeValue(manifest.toJsonString());
    final persisted = _readCurrent();
    if (persisted == null ||
        persisted.toJsonString() != manifest.toJsonString()) {
      throw StateError('No se pudo verificar el manifiesto de Web.');
    }
  }

  @override
  Future<void> clear(String operationId) async {
    final pending = _readCurrent();
    if (pending == null) {
      return;
    }
    if (pending.operationId != operationId) {
      throw StateError('El manifiesto pertenece a otra operación.');
    }
    removeValue();
    if (_readCurrent() != null) {
      throw StateError('No se pudo borrar el manifiesto de Web.');
    }
  }
}

Future<RecoveryManifestStore> createRecoveryManifestStore() async =>
    WebRecoveryManifestStore();
