-- Step 2: profiles (one row per auth user).
-- Run once in Supabase → SQL Editor.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text unique
    check (username ~ '^[a-z0-9_]{3,20}$'),
  created_at timestamptz not null default now()
);

comment on column public.profiles.username is
  'Public handle, lowercase letters/digits/underscore, 3–20 chars. Null until the user picks one.';

-- Row Level Security: anyone can read usernames, users can only edit their own row.
alter table public.profiles enable row level security;

create policy "Profiles are public"
  on public.profiles for select
  to anon, authenticated
  using (true);

create policy "Users update their own profile"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Column-level grants: only the username can be changed from the app.
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to anon, authenticated;
grant update (username) on public.profiles to authenticated;

-- Create a profile automatically when someone signs up.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill users created before this migration.
insert into public.profiles (id)
select id from auth.users
on conflict (id) do nothing;
