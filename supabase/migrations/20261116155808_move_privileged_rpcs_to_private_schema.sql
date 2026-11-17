
create or replace function private.create_shared_calendar(
  p_calendar_name text,
  p_invite_code_hash text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_calendar_id uuid;
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  if p_calendar_name is null or char_length(trim(p_calendar_name)) not between 1 and 120 then
    raise exception 'invalid_calendar_name' using errcode = '22023';
  end if;
  if p_invite_code_hash is null or p_invite_code_hash !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid_invite_code' using errcode = '22023';
  end if;

  insert into public.shared_calendars(owner_id, calendar_name)
  values (v_user_id, trim(p_calendar_name))
  returning id into v_calendar_id;

  insert into public.shared_calendar_members(calendar_id, user_id, role)
  values (v_calendar_id, v_user_id, 'owner');

  insert into private.shared_calendar_invites(code_hash, calendar_id, created_by)
  values (p_invite_code_hash, v_calendar_id, v_user_id);

  return v_calendar_id;
exception
  when unique_violation then
    raise exception 'user_already_has_shared_calendar_or_code_exists' using errcode = '23505';
end;
$$;

create or replace function private.join_shared_calendar(p_invite_code_hash text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_calendar_id uuid;
  v_member_count integer;
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  if p_invite_code_hash is null or p_invite_code_hash !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid_invite_code' using errcode = '22023';
  end if;

  select i.calendar_id into v_calendar_id
  from private.shared_calendar_invites i
  where i.code_hash = p_invite_code_hash
    and i.revoked_at is null;

  if v_calendar_id is null then
    raise exception 'invalid_or_revoked_invite_code' using errcode = '22023';
  end if;

  perform 1 from public.shared_calendars c
  where c.id = v_calendar_id
  for update;

  if not found then
    raise exception 'shared_calendar_not_found' using errcode = 'P0002';
  end if;

  if exists (
    select 1 from public.shared_calendar_members m
    where m.calendar_id = v_calendar_id and m.user_id = v_user_id
  ) then
    return v_calendar_id;
  end if;

  select count(*) into v_member_count
  from public.shared_calendar_members m
  where m.calendar_id = v_calendar_id;

  if v_member_count >= 10 then
    raise exception 'shared_calendar_full' using errcode = '54000';
  end if;

  insert into public.shared_calendar_members(calendar_id, user_id, role)
  values (v_calendar_id, v_user_id, 'member');

  return v_calendar_id;
exception
  when unique_violation then
    raise exception 'user_already_belongs_to_a_shared_calendar' using errcode = '23505';
end;
$$;

create or replace function private.rotate_shared_calendar_invite(
  p_calendar_id uuid,
  p_invite_code_hash text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  if p_invite_code_hash is null or p_invite_code_hash !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid_invite_code' using errcode = '22023';
  end if;
  if not exists (
    select 1 from public.shared_calendar_members m
    where m.calendar_id = p_calendar_id
      and m.user_id = v_user_id
      and m.role = 'owner'
  ) then
    raise exception 'owner_required' using errcode = '42501';
  end if;

  update private.shared_calendar_invites
  set revoked_at = now()
  where calendar_id = p_calendar_id and revoked_at is null;

  insert into private.shared_calendar_invites(code_hash, calendar_id, created_by)
  values (p_invite_code_hash, p_calendar_id, v_user_id);
end;
$$;

create or replace function private.leave_shared_calendar(p_calendar_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_role text;
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  select m.role into v_role
  from public.shared_calendar_members m
  where m.calendar_id = p_calendar_id and m.user_id = v_user_id;

  if v_role is null then
    return;
  end if;

  if v_role = 'owner' then
    delete from public.shared_calendars
    where id = p_calendar_id and owner_id = v_user_id;
  else
    delete from public.shared_calendar_members
    where calendar_id = p_calendar_id and user_id = v_user_id;
  end if;
end;
$$;

revoke all on function private.create_shared_calendar(text, text) from public, anon;
revoke all on function private.join_shared_calendar(text) from public, anon;
revoke all on function private.rotate_shared_calendar_invite(uuid, text) from public, anon;
revoke all on function private.leave_shared_calendar(uuid) from public, anon;
grant execute on function private.create_shared_calendar(text, text) to authenticated;
grant execute on function private.join_shared_calendar(text) to authenticated;
grant execute on function private.rotate_shared_calendar_invite(uuid, text) to authenticated;
grant execute on function private.leave_shared_calendar(uuid) to authenticated;

create or replace function public.create_shared_calendar(
  p_calendar_name text,
  p_invite_code_hash text
)
returns uuid
language sql
security invoker
set search_path = ''
as $$
  select private.create_shared_calendar(p_calendar_name, p_invite_code_hash);
$$;

create or replace function public.join_shared_calendar(p_invite_code_hash text)
returns uuid
language sql
security invoker
set search_path = ''
as $$
  select private.join_shared_calendar(p_invite_code_hash);
$$;

create or replace function public.rotate_shared_calendar_invite(
  p_calendar_id uuid,
  p_invite_code_hash text
)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.rotate_shared_calendar_invite(p_calendar_id, p_invite_code_hash);
$$;

create or replace function public.leave_shared_calendar(p_calendar_id uuid)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.leave_shared_calendar(p_calendar_id);
$$;

revoke all on function public.create_shared_calendar(text, text) from public, anon;
revoke all on function public.join_shared_calendar(text) from public, anon;
revoke all on function public.rotate_shared_calendar_invite(uuid, text) from public, anon;
revoke all on function public.leave_shared_calendar(uuid) from public, anon;
grant execute on function public.create_shared_calendar(text, text) to authenticated;
grant execute on function public.join_shared_calendar(text) to authenticated;
grant execute on function public.rotate_shared_calendar_invite(uuid, text) to authenticated;
grant execute on function public.leave_shared_calendar(uuid) to authenticated;

notify pgrst, 'reload schema';
