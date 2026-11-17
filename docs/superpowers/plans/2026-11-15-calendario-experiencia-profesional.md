# Implementation Plan — Professional Calendar Experience

## Safety

- Work only in `/Users/imac/.codex/worktrees/calendario-persistencia/Calendario-riverpod`.
- Base remains `8b26b40`; do not commit, merge, push, or deploy.
- Preserve the pre-phase snapshot in `/tmp/calendario-fase2-backup`.
- Do not change the SQLite schema, backup format, notification payloads, or recovery behavior.

## Tasks

1. [x] Add pure overnight duration and overlap helpers with tests.
2. [x] Add month/week/agenda state and a compact view selector.
3. [x] Add previous/next/date-picker navigation and synchronize selected/focused date for month, week, and day.
4. [x] Add a selected-day agenda that includes both shifts and notes.
5. [x] Add an individual occurrence editor, copy, move, swap, and daily/weekly repeat actions.
6. [x] Add advisory overlap confirmation when adding, editing, moving, swapping, copying, and repeating shifts.
7. [x] Limit calendar-cell markers on dense days and show a +N indicator; keep full detail in the agenda.
8. [x] Run targeted tests, full suite, analyze, Web release build, Android debug build, and review diff.

## Completion rule

A task is complete only after its behavior and regression tests pass. If platform tooling blocks a check, record the exact limitation rather than claiming success.

## Final verification — 2026-11-15

- Full Flutter suite: 110 passed, 1 Web-only test skipped by its platform guard; exit code 0.
- Targeted analyzer over all changed calendar, persistence, and new test files: no issues found.
- Full-project analyzer: 153 diagnostics, including two pre-existing warnings in unrelated files (`dev_page.dart` unused import and `add_notas_view.dart` unused local variable); no analyzer errors. The remaining diagnostics are legacy style/info findings.
- Web release build: passed. Standard JS build output was generated. Existing Flutter loader/service-worker deprecation warnings remain. A prior Wasm dry-run identified `get_storage`'s `dart:html` import as incompatible with WebAssembly; JS Web build is successful.
- Android debug APK: passed. The project's Gradle script evaluates release signing properties even for debug; a temporary local debug-key properties file was used and removed by the shell trap. No signing key was added to the repository.
- iOS was not rebuilt in this phase. The previous Xcode 14.3 / Flutter 3.47.7 incompatibility remains the known platform blocker.
- `git diff --check`: clean. No commit, push, merge, deployment, or installation on the user's device.
- Worktree remains based on `8b26b40`; original checkout remains separate.

## Implemented behavior

- Month, week, and agenda modes with responsive selector.
- Mode-aware previous/next navigation; date picker and Today action stay synchronized with the selected date.
- Agenda displays all selected-day shifts and notes, including overnight labels.
- Individual occurrence edit preserves the reusable shift template; copy creates a new row; move preserves the occurrence ID.
- Swap updates both dates in one SQLite transaction and preserves both IDs.
- Daily/weekly repeat previews date range and checks conflicts before one atomic batch insert (maximum 180 generated occurrences).
- Overnight-aware duration and overlap detection includes the previous and following calendar day; conflicts are advisory and require explicit confirmation to proceed.
- Dense day cells show up to two shift markers, one note marker, and a +N count; agenda remains the full detail view.
