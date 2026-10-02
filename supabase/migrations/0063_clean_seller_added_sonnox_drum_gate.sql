-- Step 63: clean up a plugin added by a seller on 2026-10-02 (Victor, 2026-10-02).
-- Sonnox Oxford Drum Gate Native G5 is the catalogue row Oxford Drum Gate typed again with the
-- brand and the edition. Listings and alerts move to Oxford Drum Gate (the first version, not
-- Drum Gate 2), the edition goes in the listing version field when empty, then the duplicate is removed.
-- Run once in Supabase > SQL Editor.

update public.listings set
  version = coalesce(nullif(version, ''), 'Native G5'),
  plugin_id = (select p.id from public.plugins p join public.developers d on d.id = p.developer_id
               where d.slug = 'sonnox' and p.name = 'Oxford Drum Gate')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.name = 'Sonnox Oxford Drum Gate Native G5');

delete from public.listing_alerts a
using public.plugins p, public.developers d
where d.id = p.developer_id and a.plugin_id = p.id
  and d.slug = 'sonnox' and p.name = 'Sonnox Oxford Drum Gate Native G5'
  and exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p2.id from public.plugins p2 where p2.developer_id = d.id and p2.name = 'Oxford Drum Gate'));

update public.listing_alerts set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.name = 'Oxford Drum Gate')
where plugin_id in (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'sonnox' and p.name = 'Sonnox Oxford Drum Gate Native G5');

delete from public.plugins p
using public.developers d
where d.id = p.developer_id and d.slug = 'sonnox'
  and p.name = 'Sonnox Oxford Drum Gate Native G5'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
