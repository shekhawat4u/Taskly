-- Taskly initial schema, RLS, triggers, and helper RPCs.
-- Apply with: supabase db push   OR paste into the SQL editor.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
do $$ begin
  create type public.user_role as enum ('founder', 'admin', 'employee', 'intern');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.task_status as enum ('todo', 'in_progress', 'completed');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.task_priority as enum ('low', 'medium', 'high', 'urgent');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.notification_type as enum (
    'task_assigned', 'task_started', 'task_completed', 'task_due', 'task_overdue'
  );
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  organization_id uuid not null references public.organizations (id) on delete restrict,
  name text not null,
  email text not null,
  avatar_url text,
  role text not null default 'employee'
    check (role in ('founder', 'admin', 'employee', 'intern')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.organization_settings (
  organization_id uuid primary key references public.organizations (id) on delete cascade,
  completed_task_retention_days integer not null default 180
    check (completed_task_retention_days >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  title text not null,
  description text,
  assigned_by uuid not null references public.profiles (id),
  assigned_to uuid not null references public.profiles (id),
  status text not null default 'todo'
    check (status in ('todo', 'in_progress', 'completed')),
  priority text not null default 'medium'
    check (priority in ('low', 'medium', 'high', 'urgent')),
  due_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  started_at timestamptz,
  completed_at timestamptz,
  completed_by uuid references public.profiles (id),
  is_archived boolean not null default false
);

create table if not exists public.task_activity (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  user_id uuid not null references public.profiles (id),
  action text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  task_id uuid references public.tasks (id) on delete set null,
  type text not null
    check (type in ('task_assigned', 'task_started', 'task_completed', 'task_due', 'task_overdue')),
  title text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('android', 'ios')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);

create table if not exists public.task_attachments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks (id) on delete cascade,
  organization_id uuid not null references public.organizations (id) on delete cascade,
  uploaded_by uuid not null references public.profiles (id),
  file_name text not null,
  file_path text not null,
  mime_type text not null,
  file_size bigint not null check (file_size > 0 and file_size <= 20971520),
  created_at timestamptz not null default now()
);

create table if not exists public.task_reminders (
  task_id uuid not null references public.tasks (id) on delete cascade,
  reminder_type text not null check (reminder_type in ('due_today', 'overdue')),
  sent_on date not null,
  primary key (task_id, reminder_type, sent_on)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
create index if not exists idx_profiles_org on public.profiles (organization_id);
create index if not exists idx_profiles_org_active on public.profiles (organization_id, is_active);
create index if not exists idx_tasks_org on public.tasks (organization_id);
create index if not exists idx_tasks_assigned_to on public.tasks (assigned_to);
create index if not exists idx_tasks_assigned_by on public.tasks (assigned_by);
create index if not exists idx_tasks_status on public.tasks (status);
create index if not exists idx_tasks_due_date on public.tasks (due_date);
create index if not exists idx_tasks_created_at on public.tasks (created_at desc);
create index if not exists idx_tasks_completed_at on public.tasks (completed_at desc);
create index if not exists idx_tasks_org_active on public.tasks (organization_id, is_archived, status);
create index if not exists idx_tasks_org_assignee_active
  on public.tasks (organization_id, assigned_to, is_archived, status);
create index if not exists idx_tasks_org_assigner_active
  on public.tasks (organization_id, assigned_by, is_archived, status);
create index if not exists idx_activity_task on public.task_activity (task_id, created_at desc);
create index if not exists idx_activity_org on public.task_activity (organization_id);
create index if not exists idx_notifications_user
  on public.notifications (user_id, is_read, created_at desc);
create index if not exists idx_notifications_org on public.notifications (organization_id);
create index if not exists idx_device_tokens_user on public.device_tokens (user_id);
create index if not exists idx_attachments_task on public.task_attachments (task_id);

-- ---------------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_organizations_updated on public.organizations;
create trigger trg_organizations_updated
before update on public.organizations
for each row execute function public.set_updated_at();

drop trigger if exists trg_profiles_updated on public.profiles;
create trigger trg_profiles_updated
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_org_settings_updated on public.organization_settings;
create trigger trg_org_settings_updated
before update on public.organization_settings
for each row execute function public.set_updated_at();

drop trigger if exists trg_tasks_updated on public.tasks;
create trigger trg_tasks_updated
before update on public.tasks
for each row execute function public.set_updated_at();

drop trigger if exists trg_device_tokens_updated on public.device_tokens;
create trigger trg_device_tokens_updated
before update on public.device_tokens
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Auth helpers (security definer, no table grants beyond authenticated)
-- ---------------------------------------------------------------------------
create or replace function public.current_profile()
returns public.profiles
language sql
stable
security definer
set search_path = public
as $$
  select * from public.profiles where id = auth.uid() limit 1;
$$;

create or replace function public.current_org_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select organization_id from public.profiles where id = auth.uid() and is_active = true;
$$;

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid() and is_active = true;
$$;

create or replace function public.is_org_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role in ('founder', 'admin')
     from public.profiles
     where id = auth.uid() and is_active = true),
    false
  );
$$;

create or replace function public.is_founder()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role = 'founder'
     from public.profiles
     where id = auth.uid() and is_active = true),
    false
  );
$$;

create or replace function public.same_org(p_org uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_org is not null and p_org = public.current_org_id();
$$;

-- ---------------------------------------------------------------------------
-- New org settings when organization is created
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_organization()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.organization_settings (organization_id)
  values (new.id)
  on conflict (organization_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_org_settings_init on public.organizations;
create trigger trg_org_settings_init
after insert on public.organizations
for each row execute function public.handle_new_organization();

-- ---------------------------------------------------------------------------
-- Activity + notifications helpers
-- ---------------------------------------------------------------------------
create or replace function public.log_task_activity(
  p_task_id uuid,
  p_action text,
  p_metadata jsonb default '{}'::jsonb
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t public.tasks;
begin
  select * into t from public.tasks where id = p_task_id;
  if t.id is null then
    raise exception 'Task not found';
  end if;
  insert into public.task_activity (organization_id, task_id, user_id, action, metadata)
  values (t.organization_id, t.id, auth.uid(), p_action, coalesce(p_metadata, '{}'::jsonb));
end;
$$;

create or replace function public.notify_user(
  p_user_id uuid,
  p_org_id uuid,
  p_task_id uuid,
  p_type text,
  p_title text,
  p_message text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_user_id = auth.uid() then
    return;
  end if;
  insert into public.notifications (
    organization_id, user_id, task_id, type, title, message
  ) values (
    p_org_id, p_user_id, p_task_id, p_type, p_title, p_message
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Atomic task mutations
-- ---------------------------------------------------------------------------
create or replace function public.create_task(
  p_title text,
  p_description text,
  p_assigned_to uuid,
  p_priority text,
  p_due_date timestamptz
) returns public.tasks
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  assignee public.profiles;
  created public.tasks;
begin
  select * into me from public.profiles where id = auth.uid() and is_active = true;
  if me.id is null then
    raise exception 'Not authenticated';
  end if;

  if p_title is null or length(trim(p_title)) = 0 then
    raise exception 'Title is required';
  end if;

  if p_priority not in ('low', 'medium', 'high', 'urgent') then
    raise exception 'Invalid priority';
  end if;

  select * into assignee
  from public.profiles
  where id = p_assigned_to
    and organization_id = me.organization_id
    and is_active = true;

  if assignee.id is null then
    raise exception 'Assignee is not an active member of your organization';
  end if;

  insert into public.tasks (
    organization_id, title, description, assigned_by, assigned_to,
    status, priority, due_date
  ) values (
    me.organization_id, trim(p_title), p_description, me.id, assignee.id,
    'todo', p_priority, p_due_date
  ) returning * into created;

  perform public.log_task_activity(created.id, 'task_created', jsonb_build_object(
    'assigned_to', assignee.id,
    'priority', p_priority
  ));

  perform public.notify_user(
    assignee.id,
    me.organization_id,
    created.id,
    'task_assigned',
    'New task assigned',
    me.name || ' assigned you ' || created.title
  );

  return created;
end;
$$;

create or replace function public.start_task(p_task_id uuid)
returns public.tasks
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  t public.tasks;
begin
  select * into me from public.profiles where id = auth.uid() and is_active = true;
  select * into t from public.tasks where id = p_task_id;

  if t.id is null or t.organization_id <> me.organization_id then
    raise exception 'Task not found';
  end if;

  if t.assigned_to <> me.id and me.role not in ('founder', 'admin') then
    raise exception 'Only the assignee can start this task';
  end if;

  if t.status <> 'todo' then
    raise exception 'Task cannot be started from the current status';
  end if;

  update public.tasks
  set status = 'in_progress', started_at = now()
  where id = t.id
  returning * into t;

  perform public.log_task_activity(t.id, 'task_started', '{}'::jsonb);
  perform public.notify_user(
    t.assigned_by,
    t.organization_id,
    t.id,
    'task_started',
    'Task started',
    me.name || ' started ' || t.title
  );
  return t;
end;
$$;

create or replace function public.complete_task(p_task_id uuid)
returns public.tasks
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  t public.tasks;
begin
  select * into me from public.profiles where id = auth.uid() and is_active = true;
  select * into t from public.tasks where id = p_task_id;

  if t.id is null or t.organization_id <> me.organization_id then
    raise exception 'Task not found';
  end if;

  if t.assigned_to <> me.id and me.role not in ('founder', 'admin') then
    raise exception 'Only the assignee can complete this task';
  end if;

  if t.status = 'completed' then
    raise exception 'Task is already completed';
  end if;

  if t.status <> 'in_progress' and me.role not in ('founder', 'admin') then
    raise exception 'Start the task before completing it';
  end if;

  update public.tasks
  set status = 'completed',
      completed_at = now(),
      completed_by = me.id,
      is_archived = true
  where id = t.id
  returning * into t;

  perform public.log_task_activity(t.id, 'task_completed', '{}'::jsonb);
  perform public.notify_user(
    t.assigned_by,
    t.organization_id,
    t.id,
    'task_completed',
    'Task completed',
    me.name || ' completed your task'
  );
  return t;
end;
$$;

-- Due / overdue reminders (called by scheduled job with service role)
create or replace function public.dispatch_due_reminders()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  sent integer := 0;
  rec record;
  today date := (timezone('utc', now()))::date;
begin
  for rec in
    select t.*
    from public.tasks t
    where t.is_archived = false
      and t.status <> 'completed'
      and t.due_date is not null
      and (t.due_date::date = today or t.due_date::date < today)
  loop
    if rec.due_date::date = today then
      if not exists (
        select 1 from public.task_reminders
        where task_id = rec.id and reminder_type = 'due_today' and sent_on = today
      ) then
        insert into public.notifications (
          organization_id, user_id, task_id, type, title, message
        ) values (
          rec.organization_id, rec.assigned_to, rec.id, 'task_due',
          'Task due today', rec.title
        );
        insert into public.task_reminders (task_id, reminder_type, sent_on)
        values (rec.id, 'due_today', today);
        sent := sent + 1;
      end if;
    elsif rec.due_date::date < today then
      if not exists (
        select 1 from public.task_reminders
        where task_id = rec.id and reminder_type = 'overdue' and sent_on = today
      ) then
        insert into public.notifications (
          organization_id, user_id, task_id, type, title, message
        ) values (
          rec.organization_id, rec.assigned_to, rec.id, 'task_overdue',
          'Task overdue', rec.title
        );
        insert into public.task_reminders (task_id, reminder_type, sent_on)
        values (rec.id, 'overdue', today);
        sent := sent + 1;
      end if;
    end if;
  end loop;
  return sent;
end;
$$;

-- Retention: permanently delete archived completed tasks older than policy
create or replace function public.purge_expired_completed_tasks()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted integer := 0;
begin
  with doomed as (
    select t.id
    from public.tasks t
    join public.organization_settings s on s.organization_id = t.organization_id
    where t.is_archived = true
      and t.status = 'completed'
      and t.completed_at is not null
      and t.completed_at < now() - make_interval(days => s.completed_task_retention_days)
  )
  delete from public.tasks t
  using doomed d
  where t.id = d.id;

  get diagnostics deleted = row_count;
  return deleted;
end;
$$;

-- Admin: invite is handled in Flutter via Auth + insert profile using this RPC
create or replace function public.admin_upsert_member(
  p_user_id uuid,
  p_name text,
  p_email text,
  p_role text,
  p_is_active boolean default true
) returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  result public.profiles;
begin
  select * into me from public.profiles where id = auth.uid() and is_active = true;
  if me.role not in ('founder', 'admin') then
    raise exception 'Not authorized';
  end if;
  if p_role not in ('founder', 'admin', 'employee', 'intern') then
    raise exception 'Invalid role';
  end if;
  if me.role = 'admin' and p_role in ('founder', 'admin') then
    raise exception 'Admins cannot assign founder/admin roles';
  end if;

  insert into public.profiles (id, organization_id, name, email, role, is_active)
  values (p_user_id, me.organization_id, p_name, p_email, p_role, p_is_active)
  on conflict (id) do update
    set name = excluded.name,
        email = excluded.email,
        role = excluded.role,
        is_active = excluded.is_active
    where public.profiles.organization_id = me.organization_id
  returning * into result;

  return result;
end;
$$;

create or replace function public.admin_set_member_active(
  p_user_id uuid,
  p_is_active boolean
) returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  target public.profiles;
begin
  select * into me from public.profiles where id = auth.uid() and is_active = true;
  if me.role not in ('founder', 'admin') then
    raise exception 'Not authorized';
  end if;
  select * into target from public.profiles
  where id = p_user_id and organization_id = me.organization_id;
  if target.id is null then
    raise exception 'User not found';
  end if;
  if target.role = 'founder' and me.role <> 'founder' then
    raise exception 'Cannot modify the founder';
  end if;
  update public.profiles set is_active = p_is_active where id = target.id
  returning * into target;
  return target;
end;
$$;

create or replace function public.admin_set_member_role(
  p_user_id uuid,
  p_role text
) returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  target public.profiles;
begin
  select * into me from public.profiles where id = auth.uid() and is_active = true;
  if me.role not in ('founder', 'admin') then
    raise exception 'Not authorized';
  end if;
  if p_role not in ('founder', 'admin', 'employee', 'intern') then
    raise exception 'Invalid role';
  end if;
  if me.role = 'admin' and p_role in ('founder', 'admin') then
    raise exception 'Admins can only change Employee/Intern roles';
  end if;

  select * into target from public.profiles
  where id = p_user_id and organization_id = me.organization_id;
  if target.id is null then
    raise exception 'User not found';
  end if;
  if target.role = 'founder' and me.id <> target.id then
    raise exception 'Cannot change the founder role';
  end if;

  update public.profiles set role = p_role where id = target.id
  returning * into target;
  return target;
end;
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.organization_settings enable row level security;
alter table public.tasks enable row level security;
alter table public.task_activity enable row level security;
alter table public.notifications enable row level security;
alter table public.device_tokens enable row level security;
alter table public.task_attachments enable row level security;
alter table public.task_reminders enable row level security;

-- organizations
drop policy if exists org_select on public.organizations;
create policy org_select on public.organizations
for select to authenticated
using (id = public.current_org_id());

drop policy if exists org_update on public.organizations;
create policy org_update on public.organizations
for update to authenticated
using (id = public.current_org_id() and public.is_org_admin())
with check (id = public.current_org_id() and public.is_org_admin());

-- profiles
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
for select to authenticated
using (organization_id = public.current_org_id());

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
for update to authenticated
using (id = auth.uid())
with check (
  id = auth.uid()
  and organization_id = public.current_org_id()
  and role = (select role from public.profiles p where p.id = auth.uid())
);

drop policy if exists profiles_update_admin on public.profiles;
create policy profiles_update_admin on public.profiles
for update to authenticated
using (organization_id = public.current_org_id() and public.is_org_admin())
with check (organization_id = public.current_org_id() and public.is_org_admin());

-- organization_settings
drop policy if exists settings_select on public.organization_settings;
create policy settings_select on public.organization_settings
for select to authenticated
using (organization_id = public.current_org_id());

drop policy if exists settings_update on public.organization_settings;
create policy settings_update on public.organization_settings
for update to authenticated
using (organization_id = public.current_org_id() and public.is_org_admin())
with check (organization_id = public.current_org_id() and public.is_org_admin());

-- tasks: members see org tasks they are involved in; admins see all org tasks
drop policy if exists tasks_select on public.tasks;
create policy tasks_select on public.tasks
for select to authenticated
using (
  organization_id = public.current_org_id()
  and (
    public.is_org_admin()
    or assigned_to = auth.uid()
    or assigned_by = auth.uid()
  )
);

drop policy if exists tasks_insert on public.tasks;
create policy tasks_insert on public.tasks
for insert to authenticated
with check (
  organization_id = public.current_org_id()
  and assigned_by = auth.uid()
  and exists (
    select 1 from public.profiles p
    where p.id = assigned_to
      and p.organization_id = public.current_org_id()
      and p.is_active = true
  )
);

drop policy if exists tasks_update on public.tasks;
create policy tasks_update on public.tasks
for update to authenticated
using (
  organization_id = public.current_org_id()
  and (assigned_to = auth.uid() or assigned_by = auth.uid() or public.is_org_admin())
)
with check (organization_id = public.current_org_id());

-- activity
drop policy if exists activity_select on public.task_activity;
create policy activity_select on public.task_activity
for select to authenticated
using (
  organization_id = public.current_org_id()
  and exists (
    select 1 from public.tasks t
    where t.id = task_id
      and t.organization_id = public.current_org_id()
      and (public.is_org_admin() or t.assigned_to = auth.uid() or t.assigned_by = auth.uid())
  )
);

drop policy if exists activity_insert on public.task_activity;
create policy activity_insert on public.task_activity
for insert to authenticated
with check (
  organization_id = public.current_org_id()
  and user_id = auth.uid()
);

-- notifications
drop policy if exists notifications_select on public.notifications;
create policy notifications_select on public.notifications
for select to authenticated
using (user_id = auth.uid() and organization_id = public.current_org_id());

drop policy if exists notifications_update on public.notifications;
create policy notifications_update on public.notifications
for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- device tokens
drop policy if exists tokens_select on public.device_tokens;
create policy tokens_select on public.device_tokens
for select to authenticated
using (user_id = auth.uid());

drop policy if exists tokens_insert on public.device_tokens;
create policy tokens_insert on public.device_tokens
for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists tokens_update on public.device_tokens;
create policy tokens_update on public.device_tokens
for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists tokens_delete on public.device_tokens;
create policy tokens_delete on public.device_tokens
for delete to authenticated
using (user_id = auth.uid());

-- attachments
drop policy if exists attachments_select on public.task_attachments;
create policy attachments_select on public.task_attachments
for select to authenticated
using (
  organization_id = public.current_org_id()
  and exists (
    select 1 from public.tasks t
    where t.id = task_id
      and (public.is_org_admin() or t.assigned_to = auth.uid() or t.assigned_by = auth.uid())
  )
);

drop policy if exists attachments_insert on public.task_attachments;
create policy attachments_insert on public.task_attachments
for insert to authenticated
with check (
  organization_id = public.current_org_id()
  and uploaded_by = auth.uid()
  and exists (
    select 1 from public.tasks t
    where t.id = task_id
      and t.organization_id = public.current_org_id()
      and (t.assigned_to = auth.uid() or t.assigned_by = auth.uid() or public.is_org_admin())
  )
);

-- reminders: no client access
drop policy if exists reminders_no_client on public.task_reminders;
create policy reminders_no_client on public.task_reminders
for all to authenticated
using (false)
with check (false);

-- ---------------------------------------------------------------------------
-- Storage
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('task-attachments', 'task-attachments', false)
on conflict (id) do nothing;

drop policy if exists attachment_storage_select on storage.objects;
create policy attachment_storage_select on storage.objects
for select to authenticated
using (
  bucket_id = 'task-attachments'
  and (storage.foldername(name))[1] = public.current_org_id()::text
);

drop policy if exists attachment_storage_insert on storage.objects;
create policy attachment_storage_insert on storage.objects
for insert to authenticated
with check (
  bucket_id = 'task-attachments'
  and (storage.foldername(name))[1] = public.current_org_id()::text
);

drop policy if exists attachment_storage_delete on storage.objects;
create policy attachment_storage_delete on storage.objects
for delete to authenticated
using (
  bucket_id = 'task-attachments'
  and (storage.foldername(name))[1] = public.current_org_id()::text
  and public.is_org_admin()
);

-- ---------------------------------------------------------------------------
-- Realtime
-- ---------------------------------------------------------------------------
alter publication supabase_realtime add table public.tasks;
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.task_activity;

-- Grants
grant usage on schema public to authenticated, anon;
grant select, insert, update on public.organizations to authenticated;
grant select, update on public.profiles to authenticated;
grant select, update on public.organization_settings to authenticated;
grant select, insert, update on public.tasks to authenticated;
grant select, insert on public.task_activity to authenticated;
grant select, update on public.notifications to authenticated;
grant select, insert, update, delete on public.device_tokens to authenticated;
grant select, insert on public.task_attachments to authenticated;

grant execute on function public.create_task(text, text, uuid, text, timestamptz) to authenticated;
grant execute on function public.start_task(uuid) to authenticated;
grant execute on function public.complete_task(uuid) to authenticated;
grant execute on function public.admin_upsert_member(uuid, text, text, text, boolean) to authenticated;
grant execute on function public.admin_set_member_active(uuid, boolean) to authenticated;
grant execute on function public.admin_set_member_role(uuid, text) to authenticated;
grant execute on function public.current_org_id() to authenticated;
grant execute on function public.current_user_role() to authenticated;
grant execute on function public.is_org_admin() to authenticated;
