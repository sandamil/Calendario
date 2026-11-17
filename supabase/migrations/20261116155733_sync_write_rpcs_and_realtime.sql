do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'shared_calendar_shifts'
  ) then
    alter publication supabase_realtime add table public.shared_calendar_shifts;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'shared_calendar_notes'
  ) then
    alter publication supabase_realtime add table public.shared_calendar_notes;
  end if;
end $$;

drop policy if exists "No direct access to invite hashes"
  on private.shared_calendar_invites;
create policy "No direct access to invite hashes"
on private.shared_calendar_invites
for all
to public
using (false)
with check (false);

create or replace function public.save_shared_calendar_shift(
  p_calendar_id uuid,
  p_sync_key text,
  p_shift_date date,
  p_title text,
  p_description text,
  p_start_hour text,
  p_end_hour text,
  p_color text,
  p_expected_revision bigint
)
returns bigint
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_revision bigint;
begin
  if auth.uid() is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  insert into public.shared_calendar_shifts(
    calendar_id, sync_key, shift_date, title, description,
    start_hour, end_hour, color, is_deleted, updated_by
  )
  values (
    p_calendar_id, p_sync_key, p_shift_date, p_title, p_description,
    p_start_hour, p_end_hour, p_color, false, auth.uid()
  )
  on conflict (calendar_id, sync_key) do update
  set shift_date = excluded.shift_date,
      title = excluded.title,
      description = excluded.description,
      start_hour = excluded.start_hour,
      end_hour = excluded.end_hour,
      color = excluded.color,
      is_deleted = false,
      updated_by = auth.uid(),
      updated_at = now()
  where public.shared_calendar_shifts.revision = p_expected_revision
  returning revision into v_revision;

  if v_revision is null then
    raise exception 'sync_conflict' using errcode = '40001';
  end if;
  return v_revision;
end;
$$;

create or replace function public.tombstone_shared_calendar_shift(
  p_calendar_id uuid,
  p_sync_key text,
  p_expected_revision bigint
)
returns bigint
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_revision bigint;
begin
  if auth.uid() is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  update public.shared_calendar_shifts
  set is_deleted = true, updated_by = auth.uid(), updated_at = now()
  where calendar_id = p_calendar_id
    and sync_key = p_sync_key
    and revision = p_expected_revision
  returning revision into v_revision;

  if v_revision is null then
    if exists (
      select 1 from public.shared_calendar_shifts
      where calendar_id = p_calendar_id and sync_key = p_sync_key
    ) then
      raise exception 'sync_conflict' using errcode = '40001';
    end if;
    return null;
  end if;
  return v_revision;
end;
$$;

create or replace function public.save_shared_calendar_note(
  p_calendar_id uuid,
  p_sync_key text,
  p_note_date date,
  p_title text,
  p_content text,
  p_site text,
  p_start_time_ms bigint,
  p_end_time_ms bigint,
  p_is_important boolean,
  p_notification_mode text,
  p_expected_revision bigint
)
returns bigint
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_revision bigint;
begin
  if auth.uid() is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  insert into public.shared_calendar_notes(
    calendar_id, sync_key, note_date, title, content, site,
    start_time_ms, end_time_ms, is_important, notification_mode,
    is_deleted, updated_by
  )
  values (
    p_calendar_id, p_sync_key, p_note_date, p_title, coalesce(p_content, ''),
    p_site, p_start_time_ms, p_end_time_ms, coalesce(p_is_important, false),
    coalesce(p_notification_mode, 'notificacion'), false, auth.uid()
  )
  on conflict (calendar_id, sync_key) do update
  set note_date = excluded.note_date,
      title = excluded.title,
      content = excluded.content,
      site = excluded.site,
      start_time_ms = excluded.start_time_ms,
      end_time_ms = excluded.end_time_ms,
      is_important = excluded.is_important,
      notification_mode = excluded.notification_mode,
      is_deleted = false,
      updated_by = auth.uid(),
      updated_at = now()
  where public.shared_calendar_notes.revision = p_expected_revision
  returning revision into v_revision;

  if v_revision is null then
    raise exception 'sync_conflict' using errcode = '40001';
  end if;
  return v_revision;
end;
$$;

create or replace function public.tombstone_shared_calendar_note(
  p_calendar_id uuid,
  p_sync_key text,
  p_expected_revision bigint
)
returns bigint
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_revision bigint;
begin
  if auth.uid() is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  update public.shared_calendar_notes
  set is_deleted = true, updated_by = auth.uid(), updated_at = now()
  where calendar_id = p_calendar_id
    and sync_key = p_sync_key
    and revision = p_expected_revision
  returning revision into v_revision;

  if v_revision is null then
    if exists (
      select 1 from public.shared_calendar_notes
      where calendar_id = p_calendar_id and sync_key = p_sync_key
    ) then
      raise exception 'sync_conflict' using errcode = '40001';
    end if;
    return null;
  end if;
  return v_revision;
end;
$$;

create or replace function public.get_sync_server_time()
returns timestamptz
language sql
stable
security invoker
set search_path = ''
as $$
  select now();
$$;

revoke all on function public.save_shared_calendar_shift(uuid,text,date,text,text,text,text,text,bigint) from public, anon;
revoke all on function public.tombstone_shared_calendar_shift(uuid,text,bigint) from public, anon;
revoke all on function public.save_shared_calendar_note(uuid,text,date,text,text,text,bigint,bigint,boolean,text,bigint) from public, anon;
revoke all on function public.tombstone_shared_calendar_note(uuid,text,bigint) from public, anon;
revoke all on function public.get_sync_server_time() from public, anon;

grant execute on function public.save_shared_calendar_shift(uuid,text,date,text,text,text,text,text,bigint) to authenticated;
grant execute on function public.tombstone_shared_calendar_shift(uuid,text,bigint) to authenticated;
grant execute on function public.save_shared_calendar_note(uuid,text,date,text,text,text,bigint,bigint,boolean,text,bigint) to authenticated;
grant execute on function public.tombstone_shared_calendar_note(uuid,text,bigint) to authenticated;
grant execute on function public.get_sync_server_time() to authenticated;

notify pgrst, 'reload schema';
