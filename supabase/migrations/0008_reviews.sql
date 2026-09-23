-- Step 5c: reviews + seller stats. Run once in Supabase > SQL Editor.

create table public.reviews (
  id bigint generated always as identity primary key,
  deal_id bigint not null references public.deals (id),
  author_id uuid not null references public.profiles (id),
  target_id uuid not null references public.profiles (id),
  rating smallint not null check (rating between 1 and 5),
  comment text not null default '' check (char_length(comment) <= 1000),
  created_at timestamptz not null default now(),
  check (author_id <> target_id),
  unique (deal_id, author_id)
);

create index reviews_target_id_idx on public.reviews (target_id);
create index reviews_deal_id_idx on public.reviews (deal_id);

alter table public.reviews enable row level security;

-- Reviews are public: shown on seller profiles and listing cards.
create policy "Reviews are public" on public.reviews
  for select to anon, authenticated
  using (true);

revoke all on public.reviews from anon, authenticated;
grant select on public.reviews to anon, authenticated;

-- Leaves a review for the other side of a completed deal (one per side, per deal).
create function public.add_review(p_deal_id bigint, p_rating smallint, p_comment text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deal public.deals%rowtype;
  v_target uuid;
  v_id bigint;
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;
  if p_rating < 1 or p_rating > 5 then
    raise exception 'INVALID_RATING';
  end if;

  select * into v_deal from public.deals where id = p_deal_id;
  if not found or v_deal.status <> 'completed' then
    raise exception 'NOT_ALLOWED';
  end if;

  if auth.uid() = v_deal.buyer_id then
    v_target := v_deal.seller_id;
  elsif auth.uid() = v_deal.seller_id then
    v_target := v_deal.buyer_id;
  else
    raise exception 'NOT_ALLOWED';
  end if;

  insert into public.reviews (deal_id, author_id, target_id, rating, comment)
  values (p_deal_id, auth.uid(), v_target, p_rating, coalesce(trim(p_comment), ''))
  returning id into v_id;

  return v_id;
exception
  when unique_violation then
    raise exception 'ALREADY_REVIEWED';
end;
$$;

revoke execute on function public.add_review from public, anon;
grant execute on function public.add_review to authenticated;

-- Aggregate seller stats (completed sales, average rating, review count).
-- Deliberately NOT security_invoker: it must count every completed deal and review
-- for a seller regardless of who's looking, while `deals` itself stays private.
-- Only the aggregate numbers below are exposed, never a row of `deals`.
create view public.seller_stats as
select
  p.id as seller_id,
  coalesce(sales.completed_sales, 0) as completed_sales,
  reviews.avg_rating,
  coalesce(reviews.review_count, 0) as review_count
from public.profiles p
left join (
  select seller_id, count(*) as completed_sales
  from public.deals
  where status = 'completed'
  group by seller_id
) sales on sales.seller_id = p.id
left join (
  select target_id, round(avg(rating), 2) as avg_rating, count(*) as review_count
  from public.reviews
  group by target_id
) reviews on reviews.target_id = p.id;

grant select on public.seller_stats to anon, authenticated;

-- Add seller rating stats to listing cards (grids and the listing page).
-- New columns must be appended at the end: `create or replace view` can't reorder
-- or rename the existing ones.
create or replace view public.listing_cards with (security_invoker = true) as
select
  l.id, l.status, l.price_eur, l.version, l.formats, l.description, l.created_at,
  l.seller_id, pr.username as seller_username, pr.created_at as seller_since,
  p.id as plugin_id, p.name as plugin_name, p.category,
  d.id as developer_id, d.name as developer_name, d.slug as developer_slug,
  d.transferable, d.no_fee,
  ss.avg_rating as seller_avg_rating, ss.review_count as seller_review_count
from public.listings l
join public.plugins p on p.id = l.plugin_id
join public.developers d on d.id = p.developer_id
join public.profiles pr on pr.id = l.seller_id
left join public.seller_stats ss on ss.seller_id = l.seller_id;

grant select on public.listing_cards to anon, authenticated;
