-- Step 60: Ayaic added as a developer (Victor, 2026-10-01).
-- Products from ayaicinc.com: Mix Monolith, M3 Mixer, COS Pro, COS Xtended, ProMix Bundle.
-- Transfer policy as given by Victor: iLok protection, transfer through iLok License Manager,
-- iLok fee about $25 per license. The Ayaic site itself publishes nothing on transfers or iLok,
-- so the source is the iLok license-transfer page, same as Kush Audio and Metric Halo.
-- Other Ayaic products not added: Dragon Fader, COS V2, AutoDeMasker, M3 Breakouts, ProM3 Bundle.
-- Run once in Supabase > SQL Editor.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Ayaic', 'ayaic', 'https://www.ayaicinc.com', true,
 'iLok transfer fee: about $25 per license. Ayaic charges nothing on top.',
 null,
 'The seller transfers the license to the buyer''s iLok User ID in iLok License Manager. Transfers can''t be reversed: double-check the buyer''s iLok User ID.',
 null,
 'NFR and trial licenses are generally not transferable. iLok may require a waiting period after a license is deposited. Subscription (PRO) access can''t be resold.',
 'https://help.ilok.com/faq_licenses.html#transfer_between_accounts',
 '2026-10-01', false)
on conflict (slug) do nothing;

insert into public.plugins (developer_id, name, slug, category)
select d.id, v.name, v.slug, v.category
from public.developers d
cross join (values
  ('Mix Monolith', 'mix-monolith', 'utilities'),
  ('M3 Mixer', 'm3-mixer', 'utilities'),
  ('COS Pro', 'cos-pro', 'eq'),
  ('COS Xtended', 'cos-xtended', 'eq'),
  ('ProMix Bundle', 'promix-bundle', 'bundles')
) as v(name, slug, category)
where d.slug = 'ayaic'
  and not exists (
    select 1 from public.plugins p where p.developer_id = d.id and p.slug = v.slug);
