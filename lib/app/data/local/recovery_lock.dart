import 'package:flutter/foundation.dart' show visibleForTesting;

import 'recovery_lock_stub.dart'
    if (dart.library.io) 'recovery_lock_native.dart'
    if (dart.library.js_interop) 'recovery_lock_web.dart'
    as platform;

abstract interface class RecoveryLock {
  static RecoveryLock _instance = platform.createRecoveryLock();

  static RecoveryLock get instance => _instance;

  @visibleForTesting
  static set instanceForTesting(RecoveryLock value) {
    _instance = value;
  }

  Future<T> withRead<T>(Future<T> Function() operation);
  Future<T> withWrite<T>(Future<T> Function() operation);
  Future<T> withExclusiveRecovery<T>(Future<T> Function() operation);
}
