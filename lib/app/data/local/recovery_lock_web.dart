import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'recovery_lock.dart';

RecoveryLock createRecoveryLock() => _WebRecoveryLock();

class _WebRecoveryLock implements RecoveryLock {
  static const _name = 'calendario2-sqlite-persistence-v1';

  Future<T> _run<T>(String mode, Future<T> Function() operation) async {
    try {
      final manager = web.window.navigator.locks;
      T? result;
      final callback = (() {
        final future = operation();
        future.then((value) => result = value);
        return future.then<JSAny?>((_) => null).toJS;
      }).toJS;
      await manager
          .request(_name, web.LockOptions(mode: mode), callback)
          .toDart;
      return result as T;
    } catch (error) {
      if (error is UnsupportedError) rethrow;
      throw StateError('No se pudo adquirir el bloqueo Web de SQLite: $error');
    }
  }

  @override
  Future<T> withRead<T>(Future<T> Function() operation) =>
      _run('shared', operation);

  @override
  Future<T> withWrite<T>(Future<T> Function() operation) =>
      _run('exclusive', operation);

  @override
  Future<T> withExclusiveRecovery<T>(Future<T> Function() operation) =>
      _run('exclusive', operation);
}
