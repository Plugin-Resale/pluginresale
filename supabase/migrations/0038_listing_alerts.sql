-- Step 38: listing alerts (Victor, 2026-09-25). With only a handful of listings, most Browse
-- searches find nothing. Instead of a dead end, the empty result now suggests the matching
-- catalogue plugins and lets a signed-in visitor ask to be emailed when one of them is listed.
-- The email is sent by the app (Sell action, service role key) right after a new listing.
-- Run once in Supabase > SQL Editor.

create table public.listing_alerts (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  plugin_id bigint not null references public.plugins (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, plugin_id)
);

create index listing_alerts_plugin_id_idx on public.listing_alerts (plugin_id);

comment on table public.listing_alerts is
  'A user wants an email when someone lists this plugin. Private to its owner. Read by the server with the service role key to send the emails.';

alter table public.listing_alerts enable row level security;

create policy "Users read their own alerts"
  on public.listing_alerts for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "Users add their own alerts"
  on public.listing_alerts for insert
  to authenticated
  with check (user_id = (select auth.uid()));

create policy "Users remove their own alerts"
  on public.listing_alerts for delete
  to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.listing_alerts from anon, authenticated;
grant select, delete on public.listing_alerts to authenticated;
grant insert (plugin_id) on public.listing_alerts to authenticated;

-- Catalogue search for the empty Browse result, same rules as the Sell form picker:
-- every typed word must appear in the developer or plugin name, punctuation and case ignored,
-- also with the spaces removed (proq finds Pro-Q). Plugin names that start with the first
-- word come first, then the shortest names (the base product before its add-ons).
create or replace function public.search_plugins(p_query text, p_limit int default 5)
returns table (
  id bigint,
  name text,
  developer_name text,
  developer_slug text,
  transferable boolean
)
language sql
stable
set search_path = ''
as $$
  with tokens as (
    select t.word, t.pos
    from unnest(string_to_array(
      trim(regexp_replace(lower(coalesce(p_query, '')), '[^a-z0-9]+', ' ', 'g')), ' '
    )) with ordinality as t (word, pos)
    where t.word <> ''
  ),
  candidates as (
    select p.id, p.name, d.name as developer_name, d.slug as developer_slug, d.transferable,
      trim(regexp_replace(lower(d.name || ' ' || p.name), '[^a-z0-9]+', ' ', 'g')) as words,
      regexp_replace(lower(p.name), '[^a-z0-9]+', '', 'g') as squashed_name
    from public.plugins p
    join public.developers d on d.id = p.developer_id
  )
  select c.id, c.name, c.developer_name, c.developer_slug, c.transferable
  from candidates c
  where exists (select 1 from tokens)
    and not exists (
      select 1 from tokens
      where position(tokens.word in c.words) = 0
        and position(tokens.word in replace(c.words, ' ', '')) = 0
    )
  order by
    c.squashed_name like (select word from tokens order by pos limit 1) || '%' desc,
    length(c.developer_name || c.name),
    c.name
  limit least(greatest(coalesce(p_limit, 5), 1), 20);
$$;

revoke all on function public.search_plugins(text, int) from public;
grant execute on function public.search_plugins(text, int) to anon, authenticated;
