import 'dart:async';

import 'recovery_lock.dart';

RecoveryLock createRecoveryLock() => _SerialRecoveryLock();

class _SerialRecoveryLock implements RecoveryLock {
  Future<void> _tail = Future<void>.value();

  Future<T> _run<T>(Future<T> Function() operation) {
    final previous = _tail;
    final released = Completer<void>();
    _tail = released.future;
    return () async {
      await previous;
      try {
        return await operation();
      } finally {
        released.complete();
      }
    }();
  }

  @override
  Future<T> withRead<T>(Future<T> Function() operation) => _run(operation);

  @override
  Future<T> withWrite<T>(Future<T> Function() operation) => _run(operation);

  @override
  Future<T> withExclusiveRecovery<T>(Future<T> Function() operation) =>
      _run(operation);
}
