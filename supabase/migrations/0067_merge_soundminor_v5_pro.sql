-- Step 67: clean up a plugin added by a seller on 2026-10-12 (Victor, 2026-10-13).
-- Soundminor V5 Pro is the catalogue row Soundminer V5 Pro (added by 0066 the same day) with a typo.
-- Listings and alerts move to Soundminer V5 Pro, then the duplicate is removed.
-- Run once in Supabase > SQL Editor.

update public.listings set
  plugin_id = (select p.id from public.plugins p join public.developers d on d.id = p.developer_id
               where d.slug = 'soundminer' and p.name = 'Soundminer V5 Pro')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'soundminer' and p.name = 'Soundminor V5 Pro');

delete from public.listing_alerts a
using public.plugins p, public.developers d
where d.id = p.developer_id and a.plugin_id = p.id
  and d.slug = 'soundminer' and p.name = 'Soundminor V5 Pro'
  and exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p2.id from public.plugins p2 where p2.developer_id = d.id and p2.name = 'Soundminer V5 Pro'));

update public.listing_alerts set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'soundminer' and p.name = 'Soundminer V5 Pro')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'soundminer' and p.name = 'Soundminor V5 Pro');

delete from public.plugins p
using public.developers d
where d.id = p.developer_id and d.slug = 'soundminer'
  and p.name = 'Soundminor V5 Pro'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
