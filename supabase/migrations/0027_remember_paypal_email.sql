-- Step 27: remember the seller PayPal email between listings, so it does not have to be
-- retyped on every Sell form (Victor, 2026-09-24). Run once in Supabase > SQL Editor.

create table public.profile_private (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  paypal_email text check (paypal_email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

comment on table public.profile_private is
  'Per-user private data, kept apart from profiles so it stays out of the public "Profiles are public" policy. Currently just the last PayPal email used on a listing, to prefill the Sell form.';

alter table public.profile_private enable row level security;

create policy "Users read their own private profile data"
  on public.profile_private for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "Users add their own private profile data"
  on public.profile_private for insert
  to authenticated
  with check (user_id = (select auth.uid()));

create policy "Users update their own private profile data"
  on public.profile_private for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

revoke all on public.profile_private from anon, authenticated;
grant select, insert, update (paypal_email) on public.profile_private to authenticated;

-- create_listing now saves the PayPal email it was given as the user default for next time.
create or replace function public.create_listing(
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
  v_paypal_email text;
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

  v_paypal_email = lower(trim(p_paypal_email));

  insert into public.listings (seller_id, plugin_id, version, price_eur, description, formats)
  values (auth.uid(), p_plugin_id, nullif(trim(p_version), ''), p_price_eur,
          coalesce(trim(p_description), ''), coalesce(p_formats, '{}'))
  returning id into v_id;

  insert into public.listing_private (listing_id, paypal_email)
  values (v_id, v_paypal_email);

  insert into public.profile_private (user_id, paypal_email)
  values (auth.uid(), v_paypal_email)
  on conflict (user_id) do update set paypal_email = excluded.paypal_email;

  return v_id;
end;
$$;
