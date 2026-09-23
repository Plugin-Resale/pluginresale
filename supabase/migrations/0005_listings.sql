-- Step 4: listings. Run once in Supabase > SQL Editor.

-- "No developer fee" filter on Browse.
alter table public.developers add column no_fee boolean not null default false;
update public.developers set no_fee = true where slug in ('izotope', 'arturia', 'u-he');

create table public.listings (
  id bigint generated always as identity (start with 1001) primary key,
  seller_id uuid not null references public.profiles (id) on delete cascade,
  plugin_id bigint not null references public.plugins (id),
  version text check (char_length(version) <= 30),
  price_eur numeric(10, 2) not null check (price_eur >= 1 and price_eur <= 10000),
  description text not null default '' check (char_length(description) <= 2000),
  formats text[] not null default '{}'
    check (formats <@ array['VST3', 'AU', 'AAX', 'VST2', 'Standalone']),
  status text not null default 'active'
    check (status in ('active', 'reserved', 'sold', 'removed')),
  attested_at timestamptz not null default now(), -- seller ticked both checkboxes
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index listings_status_created_idx on public.listings (status, created_at desc);
create index listings_seller_id_idx on public.listings (seller_id);
create index listings_plugin_id_idx on public.listings (plugin_id);

create function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger listings_touch_updated_at
  before update on public.listings
  for each row execute function public.touch_updated_at();

-- The seller's PayPal email is kept apart so it is never public.
-- Step 5 lets the buyer of an active deal read it.
create table public.listing_private (
  listing_id bigint primary key references public.listings (id) on delete cascade,
  paypal_email text not null check (paypal_email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

-- Row Level Security
alter table public.listings enable row level security;
alter table public.listing_private enable row level security;

create policy "Listings are public unless removed" on public.listings
  for select to anon, authenticated
  using (status <> 'removed' or seller_id = (select auth.uid()));

create policy "Sellers create their own listings" on public.listings
  for insert to authenticated
  with check (seller_id = (select auth.uid()));

-- Sellers can edit or remove (and re-activate) their listing; reserved/sold is handled by deals.
create policy "Sellers edit their own listings" on public.listings
  for update to authenticated
  using (seller_id = (select auth.uid()) and status in ('active', 'removed'))
  with check (seller_id = (select auth.uid()) and status in ('active', 'removed'));

create policy "Sellers read their PayPal email" on public.listing_private
  for select to authenticated
  using (exists (select 1 from public.listings l
                 where l.id = listing_id and l.seller_id = (select auth.uid())));

create policy "Sellers add their PayPal email" on public.listing_private
  for insert to authenticated
  with check (exists (select 1 from public.listings l
                      where l.id = listing_id and l.seller_id = (select auth.uid())));

create policy "Sellers update their PayPal email" on public.listing_private
  for update to authenticated
  using (exists (select 1 from public.listings l
                 where l.id = listing_id and l.seller_id = (select auth.uid())));

revoke all on public.listings, public.listing_private from anon, authenticated;
grant select on public.listings to anon, authenticated;
grant insert (seller_id, plugin_id, version, price_eur, description, formats)
  on public.listings to authenticated;
grant update (version, price_eur, description, formats, status) on public.listings to authenticated;
grant select, insert, update (paypal_email) on public.listing_private to authenticated;

-- Creates a listing and its private PayPal email in one go, with the business checks.
create function public.create_listing(
  p_plugin_id bigint,
  p_version text,
  p_price_eur numeric,
  p_description text,
  p_formats text[],
  p_paypal_email text
)
returns bigint
language plpgsql
set search_path = ''
as $$
declare
  v_id bigint;
  v_transferable boolean;
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;

  if not exists (select 1 from public.profiles where id = auth.uid() and username is not null) then
    raise exception 'USERNAME_REQUIRED';
  end if;

  select d.transferable into v_transferable
  from public.plugins p
  join public.developers d on d.id = p.developer_id
  where p.id = p_plugin_id;

  if not found then
    raise exception 'UNKNOWN_PLUGIN';
  end if;
  if not v_transferable then
    raise exception 'NOT_TRANSFERABLE';
  end if;

  insert into public.listings (seller_id, plugin_id, version, price_eur, description, formats)
  values (auth.uid(), p_plugin_id, nullif(trim(p_version), ''), p_price_eur,
          coalesce(trim(p_description), ''), coalesce(p_formats, '{}'))
  returning id into v_id;

  insert into public.listing_private (listing_id, paypal_email)
  values (v_id, lower(trim(p_paypal_email)));

  return v_id;
end;
$$;

revoke execute on function public.create_listing from public, anon;
grant execute on function public.create_listing to authenticated;

-- One row per listing with everything a card or listing page shows (respects RLS).
create view public.listing_cards with (security_invoker = true) as
select
  l.id, l.status, l.price_eur, l.version, l.formats, l.description, l.created_at,
  l.seller_id, pr.username as seller_username, pr.created_at as seller_since,
  p.id as plugin_id, p.name as plugin_name, p.category,
  d.id as developer_id, d.name as developer_name, d.slug as developer_slug,
  d.transferable, d.no_fee
from public.listings l
join public.plugins p on p.id = l.plugin_id
join public.developers d on d.id = p.developer_id
join public.profiles pr on pr.id = l.seller_id;

grant select on public.listing_cards to anon, authenticated;
