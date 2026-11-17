import 'dart:convert';

enum SyncConflictResolution { none, keepThisDevice, useSharedCopy }

class SyncMergeResult {
  const SyncMergeResult({
    required this.local,
    required this.remote,
    required this.baseline,
    required this.conflicts,
  });

  final Map<String, Map<String, Object?>> local;
  final Map<String, Map<String, Object?>> remote;
  final Map<String, String> baseline;
  final List<String> conflicts;
}

/// Three-way merge. Unresolved concurrent edits are preserved on both sides.
class SyncMergeEngine {
  static SyncMergeResult merge({
    required Map<String, Map<String, Object?>> local,
    required Map<String, Map<String, Object?>> remote,
    required Map<String, String> baseline,
    SyncConflictResolution resolution = SyncConflictResolution.none,
  }) {
    final mergedLocal = _copy(local);
    final mergedRemote = _copy(remote);
    final nextBaseline = Map<String, String>.of(baseline);
    final conflicts = <String>[];
    final keys = <String>{...baseline.keys, ...local.keys, ...remote.keys};

    for (final key in keys) {
      final baseHash = baseline[key];
      final localValue = local[key];
      final remoteValue = remote[key];
      final localHash = _fingerprint(localValue);
      final remoteHash = _fingerprint(remoteValue);
      final localChanged = localHash != baseHash;
      final remoteChanged = remoteHash != baseHash;

      if (localChanged && remoteChanged && localHash != remoteHash) {
        if (resolution == SyncConflictResolution.none) {
          conflicts.add(key);
          continue;
        }
        final chosen = resolution == SyncConflictResolution.keepThisDevice
            ? localValue
            : remoteValue;
        _assign(mergedLocal, key, chosen);
        _assign(mergedRemote, key, chosen);
      } else if (localChanged && !remoteChanged) {
        _assign(mergedRemote, key, localValue);
      } else if (!localChanged && remoteChanged) {
        _assign(mergedLocal, key, remoteValue);
      }

      final resultingHash = _fingerprint(mergedLocal[key]);
      if (resultingHash == null) {
        nextBaseline.remove(key);
      } else {
        nextBaseline[key] = resultingHash;
      }
    }

    return SyncMergeResult(
      local: Map.unmodifiable(mergedLocal),
      remote: Map.unmodifiable(mergedRemote),
      baseline: Map.unmodifiable(nextBaseline),
      conflicts: List.unmodifiable(conflicts),
    );
  }

  static Map<String, Map<String, Object?>> _copy(
    Map<String, Map<String, Object?>> source,
  ) =>
      source.map((key, value) => MapEntry(key, Map<String, Object?>.of(value)));

  static void _assign(
    Map<String, Map<String, Object?>> target,
    String key,
    Map<String, Object?>? value,
  ) {
    if (value == null) {
      target.remove(key);
    } else {
      target[key] = Map<String, Object?>.of(value);
    }
  }

  static String? _fingerprint(Map<String, Object?>? value) {
    if (value == null) return null;
    final keys = value.keys.toList()..sort();
    return jsonEncode({for (final key in keys) key: value[key]});
  }
}
