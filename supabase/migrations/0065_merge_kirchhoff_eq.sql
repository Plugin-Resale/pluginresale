-- Step 65: merge the two Kirchhoff EQ rows (Victor, 2026-10-08).
-- Kirchhoff-EQ is a Three-Body Technology product. Plugin Alliance only resells it, but the
-- 0018 sitemap import also added it as a Plugin Alliance product. Listings and alerts move to the
-- Three-Body Technology row, then the Plugin Alliance duplicate is removed.
-- Run once in Supabase > SQL Editor, after 0064.

update public.listings set
  plugin_id = (select p.id from public.plugins p join public.developers d on d.id = p.developer_id
               where d.slug = 'three-body-technology' and p.slug = 'kirchhoff-eq')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'plugin-alliance' and p.slug = 'kirchhoff-eq');

delete from public.listing_alerts a
using public.plugins p, public.developers d
where d.id = p.developer_id and a.plugin_id = p.id
  and d.slug = 'plugin-alliance' and p.slug = 'kirchhoff-eq'
  and exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p2.id from public.plugins p2 join public.developers d2 on d2.id = p2.developer_id
      where d2.slug = 'three-body-technology' and p2.slug = 'kirchhoff-eq'));

update public.listing_alerts set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'three-body-technology' and p.slug = 'kirchhoff-eq')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'plugin-alliance' and p.slug = 'kirchhoff-eq');

delete from public.plugins p
using public.developers d
where d.id = p.developer_id and d.slug = 'plugin-alliance'
  and p.slug = 'kirchhoff-eq'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
