-- Step 62: clean up plugins added by sellers on 2026-09-30 and 2026-10-01 (Victor, 2026-10-01).
-- 1. Nugen Audio AB Assist becomes AB Assist (the brand showed twice in titles). Slug kept.
-- 2. Fabfilter Pro-Q 3 + Pro-Q 4 Upgrade is the catalogue row Pro-Q 4 typed again with the
--    upgrade path. The seller owns Pro-Q 4 through the upgrade, so listings and alerts move to
--    Pro-Q 4 and the details go in the listing version field. Then the duplicate is removed.
-- Run once in Supabase > SQL Editor.

update public.plugins set name = 'AB Assist'
where name = 'Nugen Audio AB Assist'
  and developer_id = (select id from public.developers where slug = 'nugen-audio');

update public.listings set
  version = 'Pro-Q 3 + Pro-Q 4 upgrade',
  plugin_id = (select p.id from public.plugins p join public.developers d on d.id = p.developer_id
               where d.slug = 'fabfilter' and p.name = 'Pro-Q 4')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'fabfilter' and p.name = 'Fabfilter Pro-Q 3 + Pro-Q 4 Upgrade');

delete from public.listing_alerts a
using public.plugins p, public.developers d
where d.id = p.developer_id and a.plugin_id = p.id
  and d.slug = 'fabfilter' and p.name = 'Fabfilter Pro-Q 3 + Pro-Q 4 Upgrade'
  and exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p2.id from public.plugins p2 where p2.developer_id = d.id and p2.name = 'Pro-Q 4'));

update public.listing_alerts set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'fabfilter' and p.name = 'Pro-Q 4')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'fabfilter' and p.name = 'Fabfilter Pro-Q 3 + Pro-Q 4 Upgrade');

delete from public.plugins p
using public.developers d
where d.id = p.developer_id and d.slug = 'fabfilter'
  and p.name = 'Fabfilter Pro-Q 3 + Pro-Q 4 Upgrade'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
