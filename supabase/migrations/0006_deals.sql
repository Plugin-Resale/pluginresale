-- Step 5a: deals (purchase flow). Run once in Supabase > SQL Editor.
-- requested -> paid -> completed, or requested -> cancelled.
-- Every change goes through the functions below; no direct writes from the app.

create table public.deals (
  id bigint generated always as identity (start with 5001) primary key,
  listing_id bigint not null references public.listings (id),
  buyer_id uuid not null references public.profiles (id),
  seller_id uuid not null references public.profiles (id),
  price_eur numeric(10, 2) not null, -- price at the time of the purchase
  status text not null default 'requested'
    check (status in ('requested', 'paid', 'completed', 'cancelled')),
  created_at timestamptz not null default now(),
  paid_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancelled_by uuid references public.profiles (id),
  check (buyer_id <> seller_id)
);

-- Only one open deal per listing.
create unique index deals_one_open_per_listing
  on public.deals (listing_id) where status in ('requested', 'paid');
create index deals_buyer_id_idx on public.deals (buyer_id);
create index deals_seller_id_idx on public.deals (seller_id);

alter table public.deals enable row level security;

create policy "Buyer and seller see their deals" on public.deals
  for select to authenticated
  using ((select auth.uid()) in (buyer_id, seller_id));

revoke all on public.deals from anon, authenticated;
grant select on public.deals to authenticated;

-- The buyer of an open deal can read the seller's PayPal email.
create policy "Buyers of an open deal read the PayPal email" on public.listing_private
  for select to authenticated
  using (exists (select 1 from public.deals d
                 where d.listing_id = listing_private.listing_id
                   and d.buyer_id = (select auth.uid())
                   and d.status in ('requested', 'paid')));

-- 1. Buyer clicks "Buy with PayPal".
create function public.start_deal(p_listing_id bigint)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_listing public.listings%rowtype;
  v_id bigint;
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;
  if not exists (select 1 from public.profiles where id = auth.uid() and username is not null) then
    raise exception 'USERNAME_REQUIRED';
  end if;

  -- Lock the listing so two buyers can't reserve it at the same time.
  select * into v_listing from public.listings where id = p_listing_id for update;
  if not found or v_listing.status <> 'active' then
    raise exception 'NOT_AVAILABLE';
  end if;
  if v_listing.seller_id = auth.uid() then
    raise exception 'OWN_LISTING';
  end if;

  insert into public.deals (listing_id, buyer_id, seller_id, price_eur)
  values (v_listing.id, auth.uid(), v_listing.seller_id, v_listing.price_eur)
  returning id into v_id;

  update public.listings set status = 'reserved' where id = v_listing.id;
  return v_id;
end;
$$;

-- 3. Seller confirms the PayPal payment arrived.
create function public.mark_deal_paid(p_deal_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.deals set status = 'paid', paid_at = now()
  where id = p_deal_id and seller_id = auth.uid() and status = 'requested';
  if not found then
    raise exception 'NOT_ALLOWED';
  end if;
end;
$$;

-- 4. Buyer confirms the license is in their account.
create function public.mark_deal_completed(p_deal_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_listing_id bigint;
begin
  update public.deals set status = 'completed', completed_at = now()
  where id = p_deal_id and buyer_id = auth.uid() and status = 'paid'
  returning listing_id into v_listing_id;
  if not found then
    raise exception 'NOT_ALLOWED';
  end if;

  update public.listings set status = 'sold' where id = v_listing_id;
end;
$$;

-- 6. Either side cancels before the payment is confirmed.
create function public.cancel_deal(p_deal_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_listing_id bigint;
begin
  update public.deals
  set status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid()
  where id = p_deal_id and auth.uid() in (buyer_id, seller_id) and status = 'requested'
  returning listing_id into v_listing_id;
  if not found then
    raise exception 'NOT_ALLOWED';
  end if;

  update public.listings set status = 'active' where id = v_listing_id and status = 'reserved';
end;
$$;

revoke execute on function public.start_deal, public.mark_deal_paid,
  public.mark_deal_completed, public.cancel_deal from public, anon;
grant execute on function public.start_deal, public.mark_deal_paid,
  public.mark_deal_completed, public.cancel_deal to authenticated;
