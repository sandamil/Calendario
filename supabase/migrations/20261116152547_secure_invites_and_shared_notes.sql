alter table private.shared_calendar_invites enable row level security;

create table public.shared_calendar_notes (
  calendar_id uuid not null references public.shared_calendars(id) on delete cascade,
  sync_key text not null check (char_length(sync_key) between 1 and 180),
  note_date date,
  title text,
  content text not null default '',
  color text,
  is_deleted boolean not null default false,
  updated_by uuid not null references auth.users(id),
  revision bigint not null default 1 check (revision > 0),
  updated_at timestamptz not null default now(),
  primary key (calendar_id, sync_key)
);

create index shared_calendar_notes_date_idx
  on public.shared_calendar_notes(calendar_id, note_date);

create index shared_calendar_shifts_updated_by_idx
  on public.shared_calendar_shifts(updated_by);
create index shared_calendar_notes_updated_by_idx
  on public.shared_calendar_notes(updated_by);
create index shared_calendars_owner_id_idx
  on public.shared_calendars(owner_id);
create index shared_calendar_invites_created_by_idx
  on private.shared_calendar_invites(created_by);

alter table public.shared_calendar_notes enable row level security;

create policy "Members can read shared notes"
on public.shared_calendar_notes for select
to authenticated
using (private.is_calendar_member(calendar_id));

create policy "Members can create shared notes"
on public.shared_calendar_notes for insert
to authenticated
with check (
  private.is_calendar_member(calendar_id)
  and updated_by = (select auth.uid())
);

create policy "Members can update shared notes"
on public.shared_calendar_notes for update
to authenticated
using (private.is_calendar_member(calendar_id))
with check (
  private.is_calendar_member(calendar_id)
  and updated_by = (select auth.uid())
);

grant select, insert, update on public.shared_calendar_notes to authenticated;

create or replace function private.bump_shared_note_revision()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  if tg_op = 'UPDATE' then
    new.revision := old.revision + 1;
  else
    new.revision := 1;
  end if;
  return new;
end;
$$;

create trigger shared_calendar_notes_revision
before insert or update on public.shared_calendar_notes
for each row execute function private.bump_shared_note_revision();
