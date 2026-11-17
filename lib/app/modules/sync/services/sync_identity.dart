import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Stable per-record key shared by all devices after the first upload.
String newSyncKey() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// Deterministic key used only to migrate legacy records that predate sync.
String legacySyncKey(String kind, List<Object?> values) {
  final digest = sha256.convert(utf8.encode(jsonEncode([kind, ...values])));
  return 'legacy_' + kind + '_' + digest.toString();
}
