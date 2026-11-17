# Calendario — Accessible Persistence Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Every behavior change starts with a failing test. Do not commit, merge, or push during this plan.

**Goal:** Make a backup-driven recovery UI reachable before normal startup and safely rebuild both SQLite databases even when the existing database files cannot be opened.

**Architecture:** `main()` will mount a provider-free bootstrap root immediately after Flutter binding initialization. Recovery will build and validate a pair of temporary databases from JSON v1, preserve readable current database bytes under unique names, and write an external durable manifest before copying either staged file to its stable path. Startup replays that manifest before opening normal repositories, verifies both databases, and only then clears the manifest and creates the normal provider tree.

**Tech Stack:** Flutter/Dart, Riverpod app shell, `sqflite` `DatabaseFactory` byte APIs, `sqflite_common_ffi_web`, `file_picker`, conditional native file/Web `localStorage` manifest stores, `crypto` SHA-256, `integration_test`, `flutter_test` and SQLite FFI.

**Spec:** `docs/superpowers/specs/2026-11-14-recuperacion-accesible-design.md`

## Global Constraints

- Work only in `/Users/imac/.codex/worktrees/calendario-persistencia/Calendario-riverpod`, based on `8b26b40`; leave the original checkout untouched.
- Do not commit, merge, or push.
- Do not modify notification services, payloads, backend, synchronization, or publishing.
- Preserve JSON backup `format: calendario2.backup`, `version: 1`, all record IDs, date values, reminder fields, and the existing SQLite schema versions.
- Keep the current internal `backup_restore_journal` format and its `prepared`, `external_recovery`, and `complete` behavior compatible. The new external manifest supplements it; it does not replace it.
- Never write to the selected external backup. All stage and preservation paths are generated internally, unique, and checked for collisions.
- Never write either stable SQLite file before both staged databases, checksums, schema, and `PRAGMA integrity_check` have passed and the external manifest has been durably created.
- Never clear an external or SQLite journal, or delete stage files, until both stable databases pass integrity and schema checks.
- If manifest persistence, stage validation, checksum validation, byte copy, lock acquisition, or final integrity validation fails, retain all recovery inputs and keep the normal provider tree unmounted.
- Do not run an unreviewed `pub get` over the already-modified lockfile. Preserve its current local dependency changes and review any lockfile delta before accepting it.

## Review Focus

1. **Failure after calendar bytes replace but before notes bytes replace:** retry must copy both staged files before providers can mount; test in Task 4.
2. **Manifest write failure or Web storage quota failure:** neither canonical database changes and no operation is treated as pending; test in Tasks 2 and 4.
3. **Staging failure, missing stage file, or checksum mismatch:** neither canonical file changes and an existing manifest is retained; test in Tasks 3 and 4.
4. **Invalid/cancelled/unreadable backup selection:** show a useful message and make no stage, manifest, preservation, or canonical writes; test in Tasks 5 and 6.
5. **Existing version-1 SQLite journal or legacy JSON rows with IDs, dates, and reminders:** old recovery completes before normal startup, or the explicit staged recovery preserves/restores those values; test in Tasks 3 and 7.

---

## File Map

- Modify `lib/main.dart`: call `runApp` immediately after binding and construct the bootstrap root; retain the existing notification initialization calls and order in the normal startup callback.
- Create `lib/app/bootstrap/bootstrap_root.dart`: loading/ready/recovery states, startup failure phase and trace reference, retry callback; no repository, router, or provider imports.
- Create `lib/app/data/local/recovery_manifest.dart`: strict typed manifest parsing and validation.
- Create `lib/app/data/local/recovery_manifest_store.dart` plus conditional native/Web implementations: persist one manifest atomically outside the calendar and notes databases.
- Create `lib/app/data/local/recovery_service.dart`: diagnostics, v1 preview, current-file preservation, stage creation, verified byte replacement, legacy journal handoff.
- Modify `lib/app/data/local/calendarDatabase.dart` and `lib/app/data/local/taskDatabase.dart`: expose recovery-only factory/path constructors that reuse current schema callbacks and never synchronize notifications.
- Modify `lib/app/data/local/persistence_coordinator.dart`: add guarded read/write operations so a Web recovery lock excludes operations from other updated app tabs.
- Create `lib/app/modules/recovery/recovery_file_picker.dart`: isolate `FilePicker` selection/read/save operations behind an injectable interface.
- Create `lib/app/modules/recovery/recovery_controller.dart` and `recovery_screen.dart`: provider-free diagnosis, backup preview, confirmation, progress, result, and retry startup.
- Create focused tests under `test/recovery/`, a real-browser storage test, and platform integration tests under `integration_test/`.
- Modify `pubspec.yaml` and only the necessary `pubspec.lock` dependency classifications for `crypto`, `web`, and Flutter SDK `integration_test` if used directly.

## Interfaces

The implementer must keep these names and signatures consistent across tasks (`dart:typed_data` supplies `Uint8List`):

```dart
class BootstrapFailure {
  final String phase;
  final Object error;
  final StackTrace stackTrace;
  final String referenceId;
}

class BootstrapRoot extends StatefulWidget {
  final Future<void> Function() initialize;
  final Widget Function() applicationBuilder;
  final Widget Function(BootstrapFailure failure, Future<void> Function() retry)
      recoveryBuilder;
}

class RecoveryManifest {
  final int version; // 1
  final String operationId;
  final String calendarTargetPath;
  final String notesTargetPath;
  final String calendarStagePath;
  final String notesStagePath;
  final String calendarSha256;
  final String notesSha256;
}

abstract interface class RecoveryManifestStore {
  Future<RecoveryManifest?> read();
  Future<void> create(RecoveryManifest manifest); // fails if one already exists
  Future<void> clear(String operationId); // clears only the matching operation
}

class RecoveryService {
  Future<RecoveryDiagnostics> inspect();
  Future<BackupPreview> previewBackup(Uint8List backupBytes);
  Future<PreservationReport> preserveCurrentDatabases(String operationId);
  Future<RecoveryResult> restoreBackup(
    Uint8List backupBytes, {
    required bool preserveExisting,
  });
  Future<void> replayPendingManifest();
}

abstract interface class RecoveryBackupPicker {
  Future<Uint8List?> pickBackupBytes();
  Future<bool> saveBytes(Uint8List bytes, String suggestedName);
}
```

`RecoveryDiagnostics` reports calendar/notes byte availability separately from open/read-only/integrity status, plus legacy SQLite journal and external manifest status. `BackupPreview` reports v1 creation time and row counts for `Cuadrante`, `Turnos`, `theme`, and `Notas`. `PreservationReport` reports each file separately; it never claims a copy succeeded when only bytes were readable. `RecoveryResult` is success only after both stable files pass schema and integrity verification.

---

## Tasks

### Task 1: Mount a testable bootstrap root before asynchronous startup

**Files:** Create `lib/app/bootstrap/bootstrap_root.dart`, `test/recovery/bootstrap_root_test.dart`; modify `lib/main.dart`.

**Interfaces:** `BootstrapRoot` and `BootstrapFailure` as defined above. `main()` calls `WidgetsFlutterBinding.ensureInitialized()` then `runApp(BootstrapRoot(...))` synchronously; its `initialize` callback is not awaited before `runApp`.

- [ ] **Step 1: Write failing widget tests** `mounts_loading_shell_before_startup_future_completes`, `shows_recovery_builder_when_startup_throws`, `does_not_build_provider_app_on_failure`, and `retry_runs_initialization_again`.
  - Use a `Completer<void>` to prove loading UI is visible before initialization settles.
  - Make the fake initializer throw a `BootstrapFailure`; assert the recovery builder is rendered and the normal application builder was never invoked.
  - Retry with a succeeding second invocation and assert the application builder is then rendered.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/bootstrap_root_test.dart`; expect missing bootstrap types/behavior.
- [ ] **Step 3: Implement the root state machine** in `bootstrap_root.dart`; catch asynchronous startup failures, keep the trace/reference, and expose retry. Move only the existing pre-run initialization sequence behind the callback in `main.dart`; do not alter notification service source or behavior.
- [ ] **Step 4: Verify GREEN** Run the focused test and assert the app builder is absent throughout failed/retrying startup.

### Task 2: Add a validated manifest model and platform stores

**Files:** Create `lib/app/data/local/recovery_manifest.dart`, `recovery_manifest_store.dart`, `recovery_manifest_store_native.dart`, `recovery_manifest_store_web.dart`, `recovery_manifest_store_stub.dart`, and `test/recovery/recovery_manifest_test.dart`; update `pubspec.yaml` and lockfile only for direct package usage.

**Interfaces:** `RecoveryManifest` and `RecoveryManifestStore` as defined above. Native storage writes a temp file, flushes, then renames it in application-support storage. Web storage writes one JSON value to a namespaced `localStorage` key. Neither `create` overwrites a pending manifest; `clear` verifies `operationId` before removing it.

- [ ] **Step 1: Write failing serialization/store tests** `round_trips_manifest_v1`, `rejects_unknown_manifest_version`, `rejects_empty_truncated_and_invalid_json_manifests_without_clearing_them`, `rejects_unexpected_target_and_stage_paths`, `refuses_to_replace_pending_manifest`, `clear_requires_matching_operation_id`, `native_store_write_failure_leaves_no_partial_manifest`, and `web_store_reports_local_storage_quota_error`.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/recovery_manifest_test.dart`; expect missing types and validation.
- [ ] **Step 3: Implement manifest validation and conditional stores**. Validate fixed target paths against paths resolved from the existing repositories; accept stage paths only with the generated recovery prefix and expected parent. Validate SHA-256 fields as 64 hexadecimal characters. Generate operation IDs from a secure random source. Use conditional imports so no `dart:io` enters the Web compilation unit.
- [ ] **Step 4: Verify GREEN** Run the focused tests. For native store tests, inject a temporary directory. For Web storage behavior, use a browser-only test in Task 8; do not claim VM tests exercise `localStorage`.
- [ ] **Step 5: Review dependency delta** Add direct `crypto` and `web` references only if imported, plus `integration_test` as an SDK dev dependency when its task is implemented. Compare `pubspec.lock` before/after and preserve all existing entries and local changes; do not accept broad version churn.

### Task 3: Build and verify a staged database pair without opening canonical files

**Files:** Create `lib/app/data/local/recovery_service.dart` (staging/path and byte-store portions) and `test/recovery/recovery_staging_test.dart`; modify `calendarDatabase.dart` and `taskDatabase.dart` to add production recovery constructors reusing current create/upgrade/open callbacks.

**Interfaces:** `RecoveryService.previewBackup(Uint8List backupBytes)` returns row counts and `createdAt` from `AppBackupService.decodeAndValidateBackup`. `RecoveryService` receives an injectable `DatabaseFactory`, path resolver, manifest store, and byte store. Stage databases use unique generated paths and `CalendarioDB.forRecovery(factory:, path:)` / `NotasDB.forRecovery(factory:, path:)`; they do not call notification APIs.

- [ ] **Step 1: Write failing real-SQLite tests** `stages_v1_backup_without_opening_or_mutating_canonical_files`, `preserves_ids_date_strings_timezone_offsets_and_reminder_fields_in_stages`, `rejects_duplicate_ids_before_manifest_creation`, `legacy_v1_rows_receive_current_schema_defaults`, and `reports_counts_from_preview`.
  - Use `databaseFactoryFfi` and temp paths for both canonical and staging files.
  - Seed canonical DBs, retain their bytes, stage a v1 backup, and assert the canonical bytes are unchanged.
  - Assert the staged calendar IDs and `datetime` strings, note IDs, `idAlarma`, `alarmaTimestamp`, `notificationMode`, and notification fields are unchanged.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/recovery_staging_test.dart`; expect missing recovery constructors/stager.
- [ ] **Step 3: Implement staging through the existing backup validator/restorer**. Open new databases with current schema versions and callbacks. Reuse `decodeAndValidateBackup` and `restoreBackupJson` with the staged handles so v1 behavior and row validation are shared. Close both staged handles before reading their bytes and computing SHA-256. A failure before the manifest exists must leave canonical bytes unchanged.
- [ ] **Step 4: Verify GREEN** Run the focused tests, then `flutter test --no-pub test/persistence_integration_test.dart test/backup_service_test.dart` to verify compatibility with the existing internal journal and old v1 cases.

### Task 4: Preserve current files and make pair replacement replayable

**Files:** Complete `lib/app/data/local/recovery_service.dart`; create `test/recovery/recovery_replay_test.dart`.

**Interfaces:** `preserveCurrentDatabases(operationId)`, `restoreBackup(Uint8List backupBytes, {required bool preserveExisting})`, and `replayPendingManifest()` from `RecoveryService`. `restoreBackup` stages both files, optionally preserves each current file only when explicitly requested, persists the manifest, then calls the same replay method used before app startup. A requested preservation failure aborts before the manifest or canonical writes; choosing not to preserve does not block recovery. `replayPendingManifest` validates operation/version/paths/checksums and staged SQL before writing either canonical path.

- [ ] **Step 1: Write failing preservation/replay tests** `preserves_existing_calendar_and_notes_bytes_under_unique_paths`, `does_not_overwrite_existing_preservation_copy`, `requested_preservation_failure_aborts_before_manifest_or_replacement`, `restore_without_preservation_choice_does_not_create_hidden_copies`, `does_not_touch_selected_backup_path`, and the interruption matrix below. Inject a byte-store wrapper that uses real FFI databases but can fail one named read/write/check/clear operation.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/recovery_replay_test.dart`; expect missing service behavior.
- [ ] **Step 3: Implement preservation and durable replay**. When requested, preserve each existing canonical DB as a generated unique file using `DatabaseFactory.readDatabaseBytes/writeDatabaseBytes`; if a requested copy cannot be made, return an explicit failed preservation result before canonical replacement. Write the manifest only after both stage files are closed, hashed, schema-checked, and integrity-checked. Never include or write the selected source URI/path. Do not automatically delete preserved database copies after success.
- [ ] **Step 4: Add and run interruption tests before proceeding:**
  - `failure_creating_calendar_stage_leaves_canonical_pair_unchanged`;
  - `failure_creating_notes_stage_leaves_canonical_pair_unchanged`;
  - `manifest_write_failure_leaves_both_canonical_files_unchanged`;
  - `restart_after_manifest_before_first_copy_replays_both_files`;
  - `restart_after_calendar_copy_before_notes_copy_replays_both_files`;
  - `notes_copy_failure_retains_manifest_and_retry_replaces_both`;
  - `restart_after_both_copies_before_integrity_replays_and_verifies_both`;
  - `integrity_failure_retains_manifest_and_keeps_bootstrap_in_recovery`;
  - `manifest_clear_failure_is_idempotently_retried`;
  - `replaying_the_same_manifest_twice_is_idempotent`;
  - `missing_original_database_is_reported_without_blocking_backup_restore`;
  - `checksum_mismatch_or_missing_stage_never_writes_canonical_files`.
  For every failure test, assert the external manifest and stages remain whenever replay is incomplete, and assert provider startup is not permitted until replay succeeds.
- [ ] **Step 5: Verify GREEN** Run `flutter test --no-pub test/recovery/recovery_replay_test.dart`. Review every injected failure to ensure no code path deletes a prior manifest or preserved database copy.

### Task 5: Coordinate Web recovery with active database operations

**Files:** Modify `lib/app/data/local/persistence_coordinator.dart`, `calendarDatabase.dart`, and `taskDatabase.dart`; create `lib/app/data/local/recovery_lock.dart` with conditional Web/native implementations; add `test/recovery/recovery_lock_test.dart`.

**Interfaces:** `RecoveryLock.withRead<T>(operation)`, `withWrite<T>(operation)`, and `withExclusiveRecovery<T>(operation)`. Native behavior composes with the existing in-process coordinator. Web uses `navigator.locks` on one fixed application database lock; if exclusive recovery locking is unavailable, recovery fails closed before staging or replacement. Repository public reads use `withRead`; writes, backups, and multi-file recovery use `withWrite`/exclusive recovery without nested-lock deadlocks.

- [x] **Step 1: Add lock regression tests** `read_lock_blocks_exclusive_recovery_until_release`, `write_lock_serializes_other_writes`, `unsupported_web_lock_refuses_recovery_without_mutation`, nested repository reads, coordinated close helpers, and a real `deleteTypeId` regression.
- [ ] **Step 2: Verify RED** Not recorded in this execution: the lock implementation was already present when direct inspection began, so no claim is made that a fresh baseline RED run was observed.
- [x] **Step 3: Implement conditional locking** and update public repository read entry points so an exclusive recovery cannot race an updated app tab. Keep the native in-process write queue and make private repository helpers avoid re-entering the queue.
- [x] **Step 4: Verify GREEN** Focused lock tests passed on VM (5/5) and Chrome (5/5); the `deleteTypeId` SQLite integration regression passed; persistence and replay suites passed. Cross-tab browser exclusion remains explicitly assigned to Task 8.

### Task 6: Isolate backup picking and recovery UI state from providers

**Files:** Create `lib/app/modules/recovery/recovery_file_picker.dart`, `recovery_controller.dart`, and `test/recovery/recovery_controller_test.dart`.


- [ ] **Step 1: Write failing controller tests** `cancelled_picker_does_not_write`, `read_failure_does_not_write`, `invalid_json_shows_error_without_staging`, `incompatible_v1_shows_error_without_staging`, `preview_reports_created_at_and_all_four_row_counts`, `restore_runs_only_after_confirmed_action`, `restore_error_keeps_recovery_inputs`, `selected_backup_can_be_exported_if_local_storage_is_unavailable`, `preserved_database_can_be_exported_to_user_chosen_destination`, and `successful_restore_retries_bootstrap`.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/recovery_controller_test.dart`.
- [ ] **Step 3: Implement picker adapter/controller**. Use `Uint8List` and UTF-8 validation; map cancel separately from errors. Stage only after preview and confirmation. Pass the user's explicit preserve choice to `restoreBackup`; allow exporting selected backup or preserved bytes through `saveFile` when local Web storage is unavailable; no action may overwrite an external backup.
- [ ] **Step 4: Verify GREEN** Run the focused tests with fakes for cancel/read errors and real service fakes for mutation assertions.

### Task 7: Render an independent rescue screen with truthful actions

**Files:** Create `lib/app/modules/recovery/recovery_screen.dart`; create `test/recovery/recovery_screen_test.dart`.

**Interfaces:** `RecoveryScreen` renders a `RecoveryController` and a `BootstrapFailure`; its retry callback re-enters `BootstrapRoot.initialize`. Use a minimal `MaterialApp`/`Scaffold`, not `ProviderScope`, router, theme providers, notifications, or GetStorage.

- [ ] **Step 1: Write failing widget tests** `renders_diagnostics_when_calendar_cannot_open`, `shows_technical_reference_and_expandable_error`, `shows_preview_before_restore_confirmation`, `cancel_confirmation_keeps_databases_and_manifest_unchanged`, `shows_progress_and_disables_duplicate_restore`, `shows_integrity_result_after_restore`, `offers_export_when_web_database_storage_is_unavailable`, `shows_retry_only_when_retry_is_implemented`, and `recovery_tree_contains_no_provider_scope`.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/recovery_screen_test.dart`.
- [ ] **Step 3: Implement screen** with actions limited to real controller methods: diagnose, pick/preview/export backup, preserve/export current files, confirm-and-restore, retry startup. Show per-database byte/open/integrity results and legacy/external journal state separately. A failed copy or invalid manifest stays in recovery with no false “restored” success.
- [ ] **Step 4: Verify GREEN** Run focused screen and controller tests; exercise narrow and large layouts with widget tests.

### Task 8: Wire boot order and preserve the old recovery path

**Files:** Modify `lib/main.dart`; create `test/recovery/bootstrap_recovery_compatibility_test.dart`; update `docs/superpowers/plans/2026-11-14-calendario-persistencia.md` only if its recovery procedure needs correction.

**Interfaces:** Production bootstrap callback order is: (1) replay external manifest without opening canonical DBs; (2) run existing `AppBackupService.recoverPendingRestore()` for legacy in-calendar journals; (3) initialize the existing notification services and `initMemory()`; (4) await date formatting; (5) let `BootstrapRoot` mount the existing `ProviderScope(child: buildApp())`. Ads remain non-blocking and retain their current error handler. No notification source file is modified.

- [ ] **Step 1: Write failing boot/compatibility tests** `first_launch_without_database_files_creates_current_schema`, `existing_old_schema_runs_normal_migration_without_data_loss`, `normal_boot_opens_provider_tree_only_after_database_ready`, `pending_external_manifest_precedes_legacy_database_open`, `legacy_prepared_journal_is_recovered_before_providers`, `legacy_complete_journal_is_cleaned_only_after_integrity`, `legacy_corrupt_journal_mounts_rescue_ui_without_deleting_it`, `unopenable_calendar_database_still_mounts_rescue_ui`, and `pre_run_memory_or_plugin_error_mounts_rescue_ui`.
- [ ] **Step 2: Verify RED** Run `flutter test --no-pub test/recovery/bootstrap_recovery_compatibility_test.dart`.
- [ ] **Step 3: Wire production dependencies** into the bootstrap callback and ensure all awaited pre-run services are inside its caught startup phases. Keep notification APIs, IDs, and payloads unchanged. A corrupted legacy calendar journal remains in the preserved original file; a confirmed staged replacement creates new current-schema databases from the full external v1 backup.
- [ ] **Step 4: Verify GREEN** Run focused boot tests and existing `test/persistence_integration_test.dart` plus `test/backup_service_test.dart` to prove legacy SQLite journal and JSON v1 compatibility.

### Task 9: Prove platform behavior and complete the safety review

**Files:** Create `integration_test/recovery_storage_test.dart`, `test_driver/integration_test.dart`, and `test/recovery/recovery_web_runtime_test.dart`; modify `pubspec.yaml`/`pubspec.lock` only for the required SDK integration test dependency and direct packages.

- [ ] **Step 1: Add browser runtime tests** `web_indexed_db_and_local_storage_restore_two_databases_and_retry_after_partial_copy`, `web_lock_excludes_a_second_updated_tab_during_recovery`, and `unsupported_web_lock_refuses_mutation`. Use `databaseFactoryFfiWeb` in a real browser; inject failure after the first file copy, reload/recreate the bootstrap, and assert the manifest replays both databases, IDs/dates/reminders are exact, and the manifest clears only after both integrity checks.
- [ ] **Step 2: Verify Web RED** Run `flutter test --platform chrome test/recovery/recovery_web_runtime_test.dart`; expected initially to fail on absent platform stores/replay. If Chrome is unavailable, do not substitute a Web build and call it runtime coverage; record that browser execution is blocked and keep the limitation in the report.
- [ ] **Step 3: Add Android/iOS integration coverage** `native_database_bytes_can_be_staged_replaced_and_reopened` using the platform `DatabaseFactory` and path provider. Use a fake picker only for deterministic file input; separately smoke-test the native picker when an emulator/device is available.
- [ ] **Step 4: Verify native targets** Run `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/recovery_storage_test.dart -d <android-device>` when available, `flutter build apk --debug --no-pub`, and `flutter build ios --no-codesign --no-pub`. Run iOS integration only with an available simulator/device. Record build success separately from device execution.
- [ ] **Step 5: Run the full suite** `flutter test --no-pub`; require all prior tests and new recovery tests to pass.
- [ ] **Step 6: Run static analysis** `flutter analyze --no-pub`; compare to the recorded 151-diagnostic baseline and explain every new diagnostic rather than hiding it.
- [ ] **Step 7: Build Web release** `flutter build web --release --no-pub`; treat this only as compilation evidence, alongside the real-browser runtime test.
- [ ] **Step 8: Check patch hygiene** `git diff --check`; review the complete diff, dependency lock delta, external-path handling, directory/path validation, error propagation, and confirm no notification/service/backend files changed.

## Failure Matrix and Expected State

| Failure point | Stable calendar/notes files | Manifest/stage | Bootstrap/UI outcome |
|---|---|---|---|
| Invalid/cancelled/read-failed backup | unchanged | no new manifest; no stage, or orphan stage cleaned by generated prefix only | rescue with validation/cancel/error |
| Either stage transaction or stage validation fails | unchanged | no manifest; do not delete user backup | rescue; allow retry with another valid backup |
| Current-file preservation or manifest durable write fails | unchanged | no committed manifest; stage may be an orphan | rescue; no replacement starts |
| Crash after manifest, before first copy | unchanged | manifest + both stages retained | startup replays before normal DB open |
| Crash/failure after only calendar copy | mixed on disk but inaccessible to providers | manifest + both stages retained | startup copies both again and verifies |
| Notes copy, checksum, schema, or integrity check fails | possibly mixed on disk but inaccessible to providers | manifest + both stages retained | remain in recovery; no providers |
| Crash after both copies but before manifest clear | both target files present | manifest + both stages retained | replay idempotently, verify, then clear |
| Manifest clear fails | both verified | manifest + both stages retained | remain in recovery; retry and verify again |
| Empty, truncated, invalid, or unknown-version external manifest | unchanged | malformed manifest and any stage/preservation bytes retained | show diagnostic rescue state; never fall through to normal startup or clear automatically |
| Legacy internal journal exists without external manifest | unchanged until old service recovers | old SQLite journal remains in same file | old `recoverPendingRestore` runs before providers; corrupt journal mounts rescue |

## Platform Limits to Report During Execution

- **Android:** unit tests use FFI; device integration is separate from `flutter build apk`. If no Android device/emulator exists, runtime plugin/file-picker behavior remains unverified.
- **Web/PWA:** `sqflite_common_ffi_web` uses IndexedDB and is experimental. Real-browser test must exercise `localStorage`, IndexedDB flush/reload, and a partial pair copy. A successful Web release build alone is insufficient. If Web Locks or IndexedDB is unavailable, the UI must refuse destructive recovery and explain how to retry in a supported context.
- **iOS:** attempt no-sign build and device/simulator integration if available. The current environment has Xcode 14.3 and `simctl` reported an unavailable CoreSimulator connection; if that remains true, report compile/runtime as blocked by environment, not passed.
- **Manifest durability:** verify native write, flush, rename, and read-back plus Web `localStorage.setItem`/read-back. Report that filesystem directory fsync and browser storage eviction guarantees are platform-controlled; on any reported quota/write failure, preserve prior state and refuse replacement.
- **Binding/engine failure:** if `WidgetsFlutterBinding.ensureInitialized()` or the Flutter engine itself fails, no Dart recovery UI can render; this remains outside the recoverable boundary.
- **Manifest/storage corruption:** do not clear or replace a malformed pending manifest automatically. Show its diagnostic, retain stages and preservation files, and require a verified support procedure; no silent fallback to normal app startup.

## Plan Self-Review

- **Design coverage:** bootstrap-before-async, provider-free rescue, startup phases, read-only diagnostics, technical references, v1 file selection/validation/preview/confirmation/export, pair staging, optional current-file copies/export, external durable manifest, reapply-before-open, post-copy verification, restart/retry, first launch and old-schema migration, Android/Web/iOS distinctions, legacy SQLite journal, no schema/payload changes, and failure handling all have explicit tasks/tests above.
- **TDD:** every production task starts with named failing tests and a focused command before implementation. Pair replacement has failpoints at staging, manifest write, each stable file write, final verification, and manifest cleanup.
- **Interface consistency:** `BootstrapRoot`, `RecoveryManifest`, `RecoveryManifestStore`, `RecoveryService`, `RecoveryBackupPicker`, and result types are named consistently in file map, task inputs, and outputs.
- **Security:** selected source paths are read-only; all targets are generated or fixed canonical paths; checksums and schema version are checked; preservation/staging files are not removed before both final databases validate; no existing journal is cleared by an unconfirmed path.
- **Known limitation:** browser runtime, physical Android, and iOS simulator execution depend on available platform tooling; final reporting must distinguish a unit test, build, browser run, and actual device run.
- **Scope:** no notifications source, sync/backend, merge, commit, push, or original checkout is included.
