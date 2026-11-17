import 'dart:async';

import 'package:calendario2/app/data/local/persistence_coordinator.dart';
import 'package:calendario2/app/data/local/recovery_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read_lock_blocks_exclusive_recovery_until_release', () async {
    final enteredRead = Completer<void>();
    final releaseRead = Completer<void>();
    var recoveryEntered = false;
    final read = RecoveryLock.instance.withRead(() async {
      enteredRead.complete();
      await releaseRead.future;
    });
    await enteredRead.future;
    final recovery = RecoveryLock.instance.withExclusiveRecovery(() async {
      recoveryEntered = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(recoveryEntered, isFalse);
    releaseRead.complete();
    await Future.wait([read, recovery]);
    expect(recoveryEntered, isTrue);
  });

  test('write_lock_serializes_other_writes', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var secondEntered = false;
    final first = RecoveryLock.instance.withWrite(() async {
      entered.complete();
      await release.future;
    });
    await entered.future;
    final second = RecoveryLock.instance.withWrite(() async {
      secondEntered = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(secondEntered, isFalse);
    release.complete();
    await Future.wait([first, second]);
    expect(secondEntered, isTrue);
  });

  test('coordinator_does_not_deadlock_nested_repository_reads', () async {
    final value = await PersistenceCoordinator.run(() async {
      return PersistenceCoordinator.read(() async => 42);
    }).timeout(const Duration(seconds: 1));
    expect(value, 42);
  });

  test('exclusive_recovery_allows_coordinated_close_helpers', () async {
    final value = await PersistenceCoordinator.runExclusiveRecovery(() async {
      return PersistenceCoordinator.run(() async => 42);
    }).timeout(const Duration(seconds: 1));
    expect(value, 42);
  });

  test('unsupported_web_lock_refuses_recovery_without_mutation', () async {
    final original = RecoveryLock.instance;
    RecoveryLock.instanceForTesting = _UnsupportedRecoveryLock();
    addTearDown(() => RecoveryLock.instanceForTesting = original);

    var mutated = false;
    await expectLater(
      PersistenceCoordinator.runExclusiveRecovery(() async {
        mutated = true;
      }),
      throwsUnsupportedError,
    );
    expect(mutated, isFalse);
  });
}

class _UnsupportedRecoveryLock implements RecoveryLock {
  @override
  Future<T> withRead<T>(Future<T> Function() operation) => operation();

  @override
  Future<T> withWrite<T>(Future<T> Function() operation) => operation();

  @override
  Future<T> withExclusiveRecovery<T>(Future<T> Function() operation) async {
    throw UnsupportedError('Web Locks API no disponible');
  }
}
