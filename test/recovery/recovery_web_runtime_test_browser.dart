import 'dart:async';
import 'dart:js_interop';

import 'package:calendario2/app/data/local/persistence_coordinator.dart';
import 'package:calendario2/app/data/local/recovery_lock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

class _UnsupportedWebLock implements RecoveryLock {
  @override
  Future<T> withRead<T>(Future<T> Function() operation) => operation();

  @override
  Future<T> withWrite<T>(Future<T> Function() operation) => operation();

  @override
  Future<T> withExclusiveRecovery<T>(Future<T> Function() operation) async {
    throw UnsupportedError('Web Locks API unavailable');
  }
}

void main() {
  test(
    'web_lock_excludes_an_independent_same_origin_browsing_context',
    () async {
      final frame =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      frame.srcdoc = '<!doctype html><html><body>lock peer</body></html>'.toJS;
      final loaded = Completer<void>();
      frame.addEventListener(
        'load',
        (() {
          if (!loaded.isCompleted) loaded.complete();
        }).toJS,
      );
      web.document.body!.append(frame);
      await loaded.future.timeout(const Duration(seconds: 10));

      final peerLocks = frame.contentWindow!.navigator.locks;
      final firstEntered = Completer<void>();
      final releaseFirst = Completer<void>();
      final secondEntered = Completer<void>();
      final releaseSecond = Completer<void>();

      final first = RecoveryLock.instance.withExclusiveRecovery(() async {
        firstEntered.complete();
        await releaseFirst.future;
      });
      await firstEntered.future;

      final secondCallback = (() {
        secondEntered.complete();
        return releaseSecond.future.then<JSAny?>((_) => null).toJS;
      }).toJS;
      final second = peerLocks
          .request(
            'calendario2-sqlite-persistence-v1',
            web.LockOptions(mode: 'exclusive'),
            secondCallback,
          )
          .toDart;

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(secondEntered.isCompleted, isFalse);
      releaseFirst.complete();
      await first;
      await secondEntered.future.timeout(const Duration(seconds: 5));
      releaseSecond.complete();
      await second;
      frame.remove();
    },
  );

  test('unsupported_web_lock_refuses_mutation', () async {
    final previous = RecoveryLock.instance;
    RecoveryLock.instanceForTesting = _UnsupportedWebLock();
    addTearDown(() => RecoveryLock.instanceForTesting = previous);
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
