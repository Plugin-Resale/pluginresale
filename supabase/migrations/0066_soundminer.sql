-- Step 66: Soundminer added as a developer (Victor, 2026-10-12, asked by a seller with Soundminer Pro iLok licenses).
-- Policy from the official Soundminer store, product General License Transfer (store.soundminer.com/products/license-transfer):
-- a 25 USD fee covers any licensing change, ownership transfer included, the action wanted goes in the order comment field,
-- transfers within the same iLok account are done on ilok.com without Soundminer. No restrictions or delay stated.
-- Products from the same store. Upgrades between major versions are paid (V6 Pro to V7 Pro is 175 USD),
-- so V7, V6 and V5 Pro are separate catalogue entries. Other older editions can be added by sellers from the Sell form.
-- Run once in Supabase > SQL Editor.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Soundminer', 'soundminer', 'https://soundminer.com', true,
 '$25 (General License Transfer, bought on the Soundminer store).',
 null,
 'The seller buys the General License Transfer on the Soundminer store and writes in the order comment field that the license changes owner, with the buyer''s name, email and iLok User ID. Soundminer then moves the license to the buyer.',
 null,
 null,
 'https://store.soundminer.com/products/license-transfer',
 '2026-10-12', false)
on conflict (slug) do nothing;

insert into public.plugins (developer_id, name, slug, category)
select d.id, v.name, v.slug, v.category
from public.developers d
cross join (values
  ('Soundminer V7 Pro', 'soundminer-v7-pro', 'utilities'),
  ('Soundminer V7 Plus', 'soundminer-v7-plus', 'utilities'),
  ('Soundminer V7 Basic', 'soundminer-v7-basic', 'utilities'),
  ('Soundminer V6 Pro', 'soundminer-v6-pro', 'utilities'),
  ('Soundminer V6 Plus', 'soundminer-v6-plus', 'utilities'),
  ('Soundminer V6 Basic', 'soundminer-v6-basic', 'utilities'),
  ('Soundminer V5 Pro', 'soundminer-v5-pro', 'utilities')
) as v(name, slug, category)
where d.slug = 'soundminer'
  and not exists (
    select 1 from public.plugins p where p.developer_id = d.id and p.slug = v.slug);
