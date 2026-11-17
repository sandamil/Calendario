import 'package:calendario2/app/data/local/recovery_manifest.dart';
import 'package:calendario2/app/data/local/recovery_manifest_store_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web_store_reports_local_storage_quota_error', () async {
    String? storedValue;
    final store = WebRecoveryManifestStore.forTesting(
      readValue: () => storedValue,
      writeValue: (_) => throw StateError('QuotaExceededError'),
      removeValue: () => storedValue = null,
    );
    final manifest = RecoveryManifest(
      version: 1,
      operationId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      calendarTargetPath: 'CalendarioAjatsoft.db',
      notesTargetPath: 'notas_database.db',
      calendarStagePath: '.CalendarioAjatsoft.db.recovery-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.stage',
      notesStagePath:
          '.notas_database.db.recovery-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.stage',
      calendarSha256:
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      notesSha256:
          'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210',
    );

    await expectLater(store.create(manifest), throwsStateError);
    expect(await store.read(), isNull);
  });
}
