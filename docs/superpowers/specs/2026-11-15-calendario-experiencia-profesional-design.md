# Calendario — Professional Calendar Experience

## Objective

Upgrade the existing shift calendar without replacing its storage model or breaking notes, reminders, backup/recovery, notifications, or current quadrant generation.

## Existing behavior found in audit

- A monthly `TableCalendar` with custom month swipes and colored shift markers already exists.
- The selected-day popup shows shifts and notes; shifts can currently be deleted by swiping.
- The main lower panel shows notes only, not the selected day's shifts.
- Shift templates already store a title, description, color, start/end times, and reminder configuration.
- Calendar occurrences are stored independently in SQLite with a stable row ID, date, shift label, color, and times. Multiple occurrences per date are supported by the table schema.
- Overnight shifts are represented by an end time earlier than the start time (for example 22:00–06:00).
- There is no explicit month/week/agenda selector, no day-level occurrence editor, no move/copy workflow, and no visible overlap warning in the current calendar flow.

## Scope

1. Add month, week, and agenda display modes; preserve month as the default.
2. Add explicit previous/next navigation, a date picker, and a reliable Today action.
3. Make the selected-day agenda show both shifts and notes, with useful empty/loading/error states.
4. Support editing an individual calendar occurrence without changing its reusable shift template.
5. Support copying an occurrence to another date and moving it to another date while preserving its record identity when possible.
6. Keep multiple shifts on one date and render dense days without overflowing the calendar cells.
7. Add overnight-aware duration and overlap detection, including an overnight shift from the previous day. Warn and ask before creating a conflicting shift; never silently reject a user's schedule.
8. Add accessible labels, responsive layout, and regression tests.

## Data and compatibility constraints

- Do not add columns or alter SQLite schema for this phase.
- Preserve `CuadranteDay.id`, date, start/end strings, title, description, color, and `cuadranteName` on edit/move.
- Copy creates a new row ID; move updates the existing row by ID.
- Do not change template-level reminder settings or notification payload formats.
- Keep current month view as the initial mode and retain existing date selection semantics.
- Keep all changes in the authorized worktree; no commit, push, merge, or deployment.

## Acceptance criteria

- User can switch month/week/agenda and return without losing the selected date.
- Previous/next and Today update both focused and selected dates consistently.
- Agenda lists shifts and notes for the selected date.
- Individual occurrence edits affect only that occurrence.
- Copy and move work across dates and refresh calendar state.
- Multiple shifts on one date remain independently editable/deletable.
- 22:00–06:00 is treated as an 8-hour overnight interval.
- Overlap detection compares actual absolute intervals and includes a previous-day overnight shift.
- Conflict confirmation is advisory; user can proceed or cancel.
- Existing backup, recovery, persistence, notification, and notes tests remain green.
- Full Flutter test suite, analyze delta, and Web release build are recorded.
