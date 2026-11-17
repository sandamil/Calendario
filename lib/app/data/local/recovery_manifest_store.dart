import 'recovery_manifest.dart';
import 'recovery_manifest_store_stub.dart'
    if (dart.library.io) 'recovery_manifest_store_native.dart'
    if (dart.library.js_interop) 'recovery_manifest_store_web.dart'
    as platform;

abstract interface class RecoveryManifestStore {
  Future<RecoveryManifest?> read();

  /// Creates the pending manifest and refuses to replace an existing one.
  Future<void> create(RecoveryManifest manifest);

  /// Clears only a manifest belonging to [operationId].
  Future<void> clear(String operationId);
}

Future<RecoveryManifestStore> createRecoveryManifestStore() =>
    platform.createRecoveryManifestStore();
