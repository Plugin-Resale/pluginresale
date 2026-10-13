-- Step 68: price reminder email (Victor, 2026-10-13).
-- A listing still active 14 days after it went live gets one email to its seller, suggesting
-- a lower price. Sent once per listing by a daily Vercel cron (/api/cron/price-reminders).
-- Run once in Supabase > SQL Editor.

alter table public.listings add column price_reminder_sent_at timestamptz;

-- Marks the due listings as reminded and returns them in a single statement,
-- so two runs at the same time never email the same seller twice.
create function public.claim_price_reminders()
returns table (
  listing_id bigint,
  seller_id uuid,
  developer_name text,
  plugin_name text,
  price_eur numeric
)
language sql
security definer
set search_path = ''
as $$
  with due as (
    update public.listings l
    set price_reminder_sent_at = now()
    where l.status = 'active'
      and l.price_reminder_sent_at is null
      and l.created_at < now() - interval '14 days'
    returning l.id, l.seller_id, l.plugin_id, l.price_eur
  )
  select due.id, due.seller_id, d.name, p.name, due.price_eur
  from due
  join public.plugins p on p.id = due.plugin_id
  join public.developers d on d.id = p.developer_id
  order by due.seller_id, due.id
$$;

revoke all on function public.claim_price_reminders() from public, anon, authenticated;
grant execute on function public.claim_price_reminders() to service_role;
