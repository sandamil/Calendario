create schema if not exists private;

create table public.shared_calendars (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  calendar_name text not null check (char_length(trim(calendar_name)) between 1 and 120),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.shared_calendar_members (
  calendar_id uuid not null references public.shared_calendars(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'member')),
  joined_at timestamptz not null default now(),
  primary key (calendar_id, user_id),
  unique (user_id)
);

create table private.shared_calendar_invites (
  code_hash text primary key check (code_hash ~ '^[0-9a-f]{64}$'),
  calendar_id uuid not null references public.shared_calendars(id) on delete cascade,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);

create index shared_calendar_members_user_idx
  on public.shared_calendar_members(user_id);
create index shared_calendar_invites_calendar_idx
  on private.shared_calendar_invites(calendar_id)
  where revoked_at is null;

create table public.shared_calendar_shifts (
  calendar_id uuid not null references public.shared_calendars(id) on delete cascade,
  sync_key text not null check (char_length(sync_key) between 1 and 180),
  shift_date date not null,
  title text,
  description text,
  start_hour text,
  end_hour text,
  color text,
  is_deleted boolean not null default false,
  updated_by uuid not null references auth.users(id),
  revision bigint not null default 1 check (revision > 0),
  updated_at timestamptz not null default now(),
  primary key (calendar_id, sync_key)
);

create index shared_calendar_shifts_date_idx
  on public.shared_calendar_shifts(calendar_id, shift_date);

create or replace function private.is_calendar_member(p_calendar_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.shared_calendar_members m
    where m.calendar_id = p_calendar_id
      and m.user_id = (select auth.uid())
  );
$$;

create or replace function private.is_calendar_owner(p_calendar_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.shared_calendar_members m
    where m.calendar_id = p_calendar_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
  );
$$;

revoke all on schema private from public, anon;
grant usage on schema private to authenticated;
revoke all on function private.is_calendar_member(uuid) from public, anon;
revoke all on function private.is_calendar_owner(uuid) from public, anon;
grant execute on function private.is_calendar_member(uuid) to authenticated;
grant execute on function private.is_calendar_owner(uuid) to authenticated;

alter table public.shared_calendars enable row level security;
alter table public.shared_calendar_members enable row level security;
alter table public.shared_calendar_shifts enable row level security;

create policy "Members can read their shared calendars"
on public.shared_calendars for select
to authenticated
using (private.is_calendar_member(id));

create policy "Owners can update shared calendar name"
on public.shared_calendars for update
to authenticated
using (private.is_calendar_owner(id))
with check (private.is_calendar_owner(id) and owner_id = (select auth.uid()));

create policy "Owners can delete shared calendars"
on public.shared_calendars for delete
to authenticated
using (private.is_calendar_owner(id));

create policy "Members can read calendar membership"
on public.shared_calendar_members for select
to authenticated
using (private.is_calendar_member(calendar_id));

create policy "Members can read shared shifts"
on public.shared_calendar_shifts for select
to authenticated
using (private.is_calendar_member(calendar_id));

create policy "Members can create shared shifts"
on public.shared_calendar_shifts for insert
to authenticated
with check (
  private.is_calendar_member(calendar_id)
  and updated_by = (select auth.uid())
);

create policy "Members can update shared shifts"
on public.shared_calendar_shifts for update
to authenticated
using (private.is_calendar_member(calendar_id))
with check (
  private.is_calendar_member(calendar_id)
  and updated_by = (select auth.uid())
);

create or replace function private.bump_shared_shift_revision()
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

create trigger shared_calendar_shifts_revision
before insert or update on public.shared_calendar_shifts
for each row execute function private.bump_shared_shift_revision();

grant select, update, delete on public.shared_calendars to authenticated;
grant select on public.shared_calendar_members to authenticated;
grant select, insert, update on public.shared_calendar_shifts to authenticated;

create or replace function public.create_shared_calendar(
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

create or replace function public.join_shared_calendar(p_invite_code_hash text)
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

create or replace function public.rotate_shared_calendar_invite(
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

create or replace function public.leave_shared_calendar(p_calendar_id uuid)
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

revoke all on function public.create_shared_calendar(text, text) from public, anon;
revoke all on function public.join_shared_calendar(text) from public, anon;
revoke all on function public.rotate_shared_calendar_invite(uuid, text) from public, anon;
revoke all on function public.leave_shared_calendar(uuid) from public, anon;
grant execute on function public.create_shared_calendar(text, text) to authenticated;
grant execute on function public.join_shared_calendar(text) to authenticated;
grant execute on function public.rotate_shared_calendar_invite(uuid, text) to authenticated;
grant execute on function public.leave_shared_calendar(uuid) to authenticated;
