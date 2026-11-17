# Calendario Persistence Implementation Plan

**Goal:** Prove and strengthen SQLite data integrity for calendar shifts, notes, and JSON backups using isolated temporary databases.

**Architecture:** Keep the existing two SQLite files and v1 JSON backup format. Add injectable database factories/paths for tests, atomic calendar batch updates, an app-level persistence coordinator, and a durable restore journal in the calendar DB so interrupted two-file restores recover the previous consistent state before the UI starts.

**Tech stack:** Flutter/Dart, Riverpod app unchanged, `sqflite`, `sqflite_common_ffi` test backend.

## Tasks

1. Add FFI-backed persistence tests and test-only database construction. Cover CRUD, shift time boundaries, note location/reminder fields, and close/reopen durability.
2. Save multi-day rotations as one transaction. Prove a failed row insert leaves the prior schedule intact.
3. Serialize app database writes with backup snapshot and restore. Preserve the v1 format and test full restore, duplicate prevention, malformed data, rollback after a second-database failure, and restart recovery after an interrupted restore.
4. Run the complete test, analysis, Web release, and Android debug checks. Inspect notification initialization responsibilities and report a compatibility-preserving unification proposal without removing either service.

## Review focus

- One row failing inside a rotation must not delete the old schedule.
- One notes insert failing after calendar restore must leave both databases unchanged.
- Restoring a v1 backup twice must not create duplicate rows.
- Closing and reopening both repositories must preserve locations and reminder metadata.
- A note/shift write must not interleave with a cross-database backup snapshot.
- A process restart after only one database has been restored must recover the prior state of both databases before app startup.

## Notification audit ruling

The two initializers have distinct responsibilities and cannot safely be deleted as duplicates. `Notifications` handles legacy JSON tap payloads, immediate notifications used by cloud messaging, and download progress notifications. `NotificacionesService` schedules note/shift reminders with timezone-aware exact/inexact modes, Android permission handling, and `calendario:<id>` payloads. Keep both public APIs and existing channels/pending requests during a later migration.

Proposed next step: introduce one memoized initialization owner for the shared platform plugin, then adapt both services to it. Preserve both payload decoders and notification channel identifiers; test launch/tap behavior and pending request compatibility on Android and iOS before removing the old initialization path. Do not reconcile pending OS reminders during restore until IDs are namespaced and ownership is known, because the current services share the platform notification ID namespace.

## Recovery procedure for a blocked startup

Never remove `backup_restore_journal` by hand as the first response. Stop the app and preserve copies of both SQLite files (including `-wal`/`-shm` sidecars, if present) before diagnosis. Run `AppBackupService.inspectRestoreRecovery` on both database handles and record `calendarIntegrity`, `notesIntegrity`, `journalStatus`, and `detail`. `none` and `empty` mean there is no pending transaction; `prepared` rolls back to the snapshots stored in the journal; `complete` means both target databases committed and only marker cleanup remains. Automatic replay and marker cleanup require `PRAGMA integrity_check` to return `ok` for both databases.

For `corrupt`, an unknown phase, or a missing snapshot, retain the journal and both database copies. If both integrity results are `ok`, supply a known-good full JSON v1 backup to `AppBackupService.recoverFromExternalBackupJson`. It validates the backup and destination schema, atomically replaces the unusable journal with a durable `external_recovery` record, reapplies both databases, and marks it complete. If either integrity check fails or no known-good full JSON backup exists, do not invoke the recovery API and do not delete the journal; preserve the files for offline SQLite recovery from a verified copy. The recovery API deliberately refuses to proceed when either database fails `PRAGMA integrity_check`.

The current application does not expose an in-app recovery screen when `main()` fails before `runApp`. Operational use of the diagnostic/recovery API therefore requires a support/recovery entry point or a recovery build. Add that entry point before broad production rollout; normal startup remains fail-closed to prevent providers from reading mixed data.
