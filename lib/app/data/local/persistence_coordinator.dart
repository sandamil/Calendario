import 'dart:async';

import 'recovery_lock.dart';

/// Serializes app-level writes and cross-database backup operations.
///
/// SQLite transactions remain responsible for atomicity within each file;
/// this queue prevents a backup from observing app writes between the two
/// independent database snapshots.
class PersistenceCoordinator {
  PersistenceCoordinator._();

  static Future<void> _tail = Future<void>.value();
  static const Object _zoneKey = #persistenceCoordinatorActive;

  static Future<T> run<T>(Future<T> Function() operation) {
    if (Zone.current[_zoneKey] == true) return operation();
    return RecoveryLock.instance.withWrite(() => _enqueue(operation));
  }

  /// Runs a repository read under the shared lock, unless the caller already
  /// owns the coordinator's exclusive lock in the current asynchronous zone.
  static Future<T> read<T>(Future<T> Function() operation) {
    if (Zone.current[_zoneKey] == true) return operation();
    return RecoveryLock.instance.withRead(operation);
  }

  static Future<T> runExclusiveRecovery<T>(Future<T> Function() operation) {
    if (Zone.current[_zoneKey] == true) return operation();
    return RecoveryLock.instance.withExclusiveRecovery(
      () => _enqueue(operation),
    );
  }

  static Future<T> _enqueue<T>(Future<T> Function() operation) {
    final previous = _tail;
    final release = Completer<void>();
    final result = Completer<T>();
    _tail = release.future;

    () async {
      await previous;
      try {
        result.complete(
          await runZoned(operation, zoneValues: {_zoneKey: true}),
        );
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      } finally {
        release.complete();
      }
    }();

    return result.future;
  }
}
