-- Development seed. Run AFTER creating auth users with matching emails.
-- This script only fills organizations/profiles/tasks for existing auth.users.

do $$
declare
  org_id uuid;
  rahul uuid;
  priya uuid;
  aman uuid;
  riya uuid;
  karan uuid;
begin
  select id into rahul from auth.users where email = 'rahul@taskly.dev';
  select id into priya from auth.users where email = 'priya@taskly.dev';
  select id into aman from auth.users where email = 'aman@taskly.dev';
  select id into riya from auth.users where email = 'riya@taskly.dev';
  select id into karan from auth.users where email = 'karan@taskly.dev';

  if rahul is null or priya is null or aman is null or riya is null or karan is null then
    raise exception 'Create the five auth users first. See supabase/seed/README.md';
  end if;

  insert into public.organizations (id, name)
  values (gen_random_uuid(), 'Taskly Labs')
  returning id into org_id;

  insert into public.profiles (id, organization_id, name, email, role, is_active)
  values
    (rahul, org_id, 'Rahul Mehta', 'rahul@taskly.dev', 'founder', true),
    (priya, org_id, 'Priya Singh', 'priya@taskly.dev', 'admin', true),
    (aman, org_id, 'Aman Kumar', 'aman@taskly.dev', 'intern', true),
    (riya, org_id, 'Riya Sharma', 'riya@taskly.dev', 'intern', true),
    (karan, org_id, 'Karan Verma', 'karan@taskly.dev', 'employee', true)
  on conflict (id) do update
    set organization_id = excluded.organization_id,
        name = excluded.name,
        role = excluded.role,
        is_active = true;

  insert into public.tasks (
    organization_id, title, description, assigned_by, assigned_to,
    status, priority, due_date
  ) values
    (org_id, 'Prepare Investor Deck', 'Outline traction, roadmap, and hiring plan.', rahul, aman, 'todo', 'urgent', now() + interval '1 day'),
    (org_id, 'Update Website Content', 'Refresh homepage copy for the new launch.', rahul, aman, 'in_progress', 'high', now()),
    (org_id, 'QA onboarding flow', 'Walk through intern onboarding on Android and iOS.', priya, riya, 'todo', 'medium', now() + interval '3 day'),
    (org_id, 'Weekly standup notes', 'Summarize blockers from the last sprint.', karan, karan, 'todo', 'low', now() + interval '7 day');
end $$;
