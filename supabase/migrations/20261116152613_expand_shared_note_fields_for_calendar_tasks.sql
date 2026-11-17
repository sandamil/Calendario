alter table public.shared_calendar_notes
  add column if not exists site text,
  add column if not exists start_time_ms bigint,
  add column if not exists end_time_ms bigint,
  add column if not exists is_important boolean not null default false,
  add column if not exists notification_mode text not null default 'notificacion'
    check (notification_mode in ('notificacion', 'alarma'));

comment on table public.shared_calendar_notes is
  'Shared note/task content. Device-specific notification IDs and alarm scheduling state remain local.';
comment on column public.shared_calendar_notes.notification_mode is
  'User preference only; actual scheduled notifications and device IDs are never synchronized.';
