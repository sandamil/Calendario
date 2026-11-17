import 'package:calendario2/app/bootstrap/startup_sequence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'external_replay_precedes_legacy_and_all_pre_provider_services',
    () async {
      final order = <String>[];
      await runPreProviderStartup(
        replayExternalManifest: () async => order.add('external'),
        recoverLegacyJournal: () async => order.add('legacy'),
        initializeNotifications: () async => order.add('notifications'),
        initializeMemory: () async => order.add('memory'),
        initializeDateFormatting: () async => order.add('dates'),
      );
      expect(order, ['external', 'legacy', 'notifications', 'memory', 'dates']);
    },
  );

  test(
    'external_replay_failure_stops_before_legacy_or_provider_services',
    () async {
      final order = <String>[];
      await expectLater(
        runPreProviderStartup(
          replayExternalManifest: () async {
            order.add('external');
            throw const FormatException('manifest corrupt');
          },
          recoverLegacyJournal: () async => order.add('legacy'),
          initializeNotifications: () async => order.add('notifications'),
          initializeMemory: () async => order.add('memory'),
          initializeDateFormatting: () async => order.add('dates'),
        ),
        throwsFormatException,
      );
      expect(order, ['external']);
    },
  );

  test(
    'legacy_recovery_failure_stops_before_notifications_and_memory',
    () async {
      final order = <String>[];
      await expectLater(
        runPreProviderStartup(
          replayExternalManifest: () async => order.add('external'),
          recoverLegacyJournal: () async {
            order.add('legacy');
            throw StateError('legacy journal corrupt');
          },
          initializeNotifications: () async => order.add('notifications'),
          initializeMemory: () async => order.add('memory'),
          initializeDateFormatting: () async => order.add('dates'),
        ),
        throwsStateError,
      );
      expect(order, ['external', 'legacy']);
    },
  );

  test('date_formatting_is_awaited_after_notifications_and_memory', () async {
    final order = <String>[];
    await runPreProviderStartup(
      replayExternalManifest: () async => order.add('external'),
      recoverLegacyJournal: () async => order.add('legacy'),
      initializeNotifications: () async {
        await Future<void>.delayed(Duration.zero);
        order.add('notifications');
      },
      initializeMemory: () async {
        await Future<void>.delayed(Duration.zero);
        order.add('memory');
      },
      initializeDateFormatting: () async => order.add('dates'),
    );
    expect(order.last, 'dates');
    expect(order.take(2), ['external', 'legacy']);
  });
}
