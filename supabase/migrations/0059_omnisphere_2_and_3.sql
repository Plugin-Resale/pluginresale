-- Step 59: Omnisphere 2 and Omnisphere 3 as separate products (Victor, 2026-09-30).
-- Omnisphere 3 is a paid upgrade for Omnisphere 1 and 2 owners (199 USD, Spectrasonics pricing),
-- so the two versions have different resale value (see Catalogue maintenance rules).
-- The single row Omnisphere now carries the Omnisphere 3 official image, so it becomes
-- Omnisphere 3 (no listing pointed at it, slug kept so its page URL does not change),
-- and Omnisphere 2 is added next to it.
-- Run once in Supabase > SQL Editor.

update public.plugins set name = 'Omnisphere 3'
where slug = 'omnisphere'
  and developer_id = (select id from public.developers where slug = 'spectrasonics');

insert into public.plugins (developer_id, name, slug, category)
select d.id, 'Omnisphere 2', 'omnisphere-2', 'synths'
from public.developers d
where d.slug = 'spectrasonics'
  and not exists (
    select 1 from public.plugins p where p.developer_id = d.id and p.slug = 'omnisphere-2');
