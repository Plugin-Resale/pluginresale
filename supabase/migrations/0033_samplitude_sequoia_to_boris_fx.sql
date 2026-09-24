-- Step 33: Samplitude and Sequoia moved from MAGIX to Boris FX (Victor, 2026-09-24).
-- Boris FX took over the MAGIX pro audio line in April 2026 and now sells them as
-- Samplitude 2026, Samplitude Suite 2026 and Sequoia 2026 (borisfx.com/products/samplitude
-- and borisfx.com/products/sequoia). The rows are moved and renamed, not deleted, so any
-- listing pointing at them keeps working (an owner of X8 puts it in the listing version field).
-- MAGIX has no product left in the catalogue after this, so its developer row is removed.
-- Run once in Supabase > SQL Editor.

update public.plugins p set
  developer_id = (select id from public.developers where slug = 'boris-fx'),
  name = v.new_name,
  slug = v.new_slug
from (values
  ('samplitude-pro-x8', 'Samplitude 2026', 'samplitude-2026'),
  ('samplitude-pro-x8-suite', 'Samplitude Suite 2026', 'samplitude-suite-2026'),
  ('sequoia', 'Sequoia 2026', 'sequoia-2026')
) as v(old_slug, new_name, new_slug)
where p.slug = v.old_slug
  and p.developer_id = (select id from public.developers where slug = 'magix');

delete from public.developers d
where d.slug = 'magix'
  and not exists (select 1 from public.plugins p where p.developer_id = d.id);
