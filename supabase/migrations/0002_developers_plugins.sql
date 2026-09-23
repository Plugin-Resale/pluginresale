-- Step 3: developers (with their license-transfer rules) and plugins.
-- Run once in Supabase → SQL Editor. Seed data: 0003_seed_developers.sql.

create table public.developers (
  id bigint generated always as identity primary key,
  name text not null unique,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  website text,
  transferable boolean not null,
  fee text,           -- e.g. "€10", "$25 iLok fee"
  who_pays text,      -- e.g. "Seller"
  process text,       -- how the transfer is done
  typical_delay text,
  restrictions text,  -- NFR/EDU, minimum holding time, etc.
  source_url text,    -- official page the rules come from
  last_verified date,
  created_at timestamptz not null default now()
);

create table public.plugins (
  id bigint generated always as identity primary key,
  developer_id bigint not null references public.developers (id) on delete cascade,
  name text not null,
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  category text not null check (category in (
    'eq', 'compression', 'reverb-delay', 'saturation', 'mastering',
    'synths', 'sample-libraries', 'bundles', 'utilities'
  )),
  created_at timestamptz not null default now(),
  unique (developer_id, slug)
);

create index plugins_developer_id_idx on public.plugins (developer_id);
create index plugins_name_idx on public.plugins using gin (to_tsvector('simple', name));

-- Public read-only reference data: edited by the admin in the dashboard, never from the app.
alter table public.developers enable row level security;
alter table public.plugins enable row level security;

create policy "Developers are public" on public.developers
  for select to anon, authenticated using (true);
create policy "Plugins are public" on public.plugins
  for select to anon, authenticated using (true);

revoke all on public.developers, public.plugins from anon, authenticated;
grant select on public.developers, public.plugins to anon, authenticated;
