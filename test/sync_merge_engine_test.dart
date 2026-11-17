import 'package:flutter_test/flutter_test.dart';
import 'package:calendario2/app/modules/sync/services/sync_merge_engine.dart';

Map<String, Object?> entry(String title) => {
  'title': title,
  'startHour': '07:00',
};

void main() {
  group('SyncMergeEngine', () {
    test('pushes local-only changes to the shared copy', () {
      final result = SyncMergeEngine.merge(
        local: {'2026-01-01': entry('M')},
        remote: {},
        baseline: {},
      );
      expect(result.remote['2026-01-01'], entry('M'));
      expect(result.conflicts, isEmpty);
    });

    test('pulls shared-only changes to this device', () {
      final result = SyncMergeEngine.merge(
        local: {},
        remote: {'2026-01-01': entry('T')},
        baseline: {},
      );
      expect(result.local['2026-01-01'], entry('T'));
      expect(result.conflicts, isEmpty);
    });

    test('detects concurrent edits without overwriting either copy', () {
      final base = {'2026-01-01': entry('M')};
      final baseline = {'2026-01-01': '{"startHour":"07:00","title":"M"}'};
      final local = {'2026-01-01': entry('T')};
      final remote = {'2026-01-01': entry('N')};
      final result = SyncMergeEngine.merge(
        local: local,
        remote: remote,
        baseline: baseline,
      );
      expect(result.conflicts, ['2026-01-01']);
      expect(result.local['2026-01-01'], entry('T'));
      expect(result.remote['2026-01-01'], entry('N'));
      expect(result.baseline['2026-01-01'], isNotNull);
      expect(base, isNotEmpty);
    });

    test('allows explicit local or shared resolution', () {
      final baseline = {'2026-01-01': '{"startHour":"07:00","title":"M"}'};
      final local = {'2026-01-01': entry('T')};
      final remote = {'2026-01-01': entry('N')};
      final localWins = SyncMergeEngine.merge(
        local: local,
        remote: remote,
        baseline: baseline,
        resolution: SyncConflictResolution.keepThisDevice,
      );
      expect(localWins.remote['2026-01-01'], entry('T'));
      final remoteWins = SyncMergeEngine.merge(
        local: local,
        remote: remote,
        baseline: baseline,
        resolution: SyncConflictResolution.useSharedCopy,
      );
      expect(remoteWins.local['2026-01-01'], entry('N'));
    });

    test('propagates deletions and advances baseline', () {
      final baseline = {'2026-01-01': '{"startHour":"07:00","title":"M"}'};
      final result = SyncMergeEngine.merge(
        local: {},
        remote: {'2026-01-01': entry('M')},
        baseline: baseline,
      );
      expect(result.remote, isEmpty);
      expect(result.baseline, isEmpty);
    });

    test('recognizes equal concurrent edits as conflict-free', () {
      final baseline = {'2026-01-01': '{"startHour":"07:00","title":"M"}'};
      final same = {'2026-01-01': entry('T')};
      final result = SyncMergeEngine.merge(
        local: same,
        remote: same,
        baseline: baseline,
      );
      expect(result.conflicts, isEmpty);
      expect(
        result.baseline['2026-01-01'],
        '{"startHour":"07:00","title":"T"}',
      );
    });
  });
}
