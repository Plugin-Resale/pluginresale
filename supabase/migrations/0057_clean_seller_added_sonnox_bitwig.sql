-- Step 57: clean up plugins added by sellers from the Sell form on 2026-09-30, the day the
-- Production Expert article brought a wave of new listings (Victor, 2026-09-30).
-- 1. Sonnox Sonnox Oxford TransMod becomes Oxford TransMod, the naming used by every other
--    Sonnox row (the brand showed twice in titles). The slug is kept so its page URL does not change.
-- 2. Bitwig Studio 6.1.3 + Upgrade Plan and Bitwig Bitwig Studio 6.1.3 + Upgrade Plan are the
--    catalogue row Bitwig Studio typed again with a version. Bitwig sells one Studio license
--    with an upgrade plan, so the version goes in the listing version field. Listings and
--    alerts move to Bitwig Studio first, then the duplicates are removed.
-- 3. Sonnox Oxford Inflator plugin for sale. is the catalogue row Oxford Inflator typed again.
--    Same merge.
-- A duplicate is only deleted once no listing points at it.
-- Run once in Supabase > SQL Editor.

update public.plugins set name = 'Oxford TransMod'
where slug = 'sonnox-oxford-transmod'
  and developer_id = (select id from public.developers where slug = 'sonnox');

-- Bitwig

update public.listings set
  version = '6.1.3 + Upgrade Plan',
  plugin_id = (select p.id from public.plugins p join public.developers d on d.id = p.developer_id
               where d.slug = 'bitwig' and p.slug = 'bitwig-studio')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'bitwig'
    and p.slug in ('bitwig-studio-6-1-3-upgrade-plan', 'bitwig-bitwig-studio-6-1-3-upgrade-plan'));

delete from public.listing_alerts a
using public.plugins p, public.developers d
where d.id = p.developer_id and a.plugin_id = p.id
  and d.slug = 'bitwig'
  and p.slug in ('bitwig-studio-6-1-3-upgrade-plan', 'bitwig-bitwig-studio-6-1-3-upgrade-plan')
  and exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p2.id from public.plugins p2 where p2.developer_id = d.id and p2.slug = 'bitwig-studio'));

update public.listing_alerts set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'bitwig' and p.slug = 'bitwig-studio')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'bitwig'
    and p.slug in ('bitwig-studio-6-1-3-upgrade-plan', 'bitwig-bitwig-studio-6-1-3-upgrade-plan'));

delete from public.plugins p
using public.developers d
where d.id = p.developer_id
  and d.slug = 'bitwig'
  and p.slug in ('bitwig-studio-6-1-3-upgrade-plan', 'bitwig-bitwig-studio-6-1-3-upgrade-plan')
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Sonnox Oxford Inflator

update public.listings set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.slug = 'oxford-inflator')
where plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.slug = 'sonnox-oxford-inflator-plugin-for-sale');

delete from public.listing_alerts a
using public.plugins p, public.developers d
where d.id = p.developer_id and a.plugin_id = p.id
  and d.slug = 'sonnox' and p.slug = 'sonnox-oxford-inflator-plugin-for-sale'
  and exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p2.id from public.plugins p2 where p2.developer_id = d.id and p2.slug = 'oxford-inflator'));

update public.listing_alerts set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.slug = 'oxford-inflator')
where plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.slug = 'sonnox-oxford-inflator-plugin-for-sale');

delete from public.plugins p
using public.developers d
where d.id = p.developer_id
  and d.slug = 'sonnox'
  and p.slug = 'sonnox-oxford-inflator-plugin-for-sale'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
