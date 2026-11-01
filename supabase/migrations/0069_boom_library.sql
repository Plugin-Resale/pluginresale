-- Step 69: move the seller-added BOOM Library plugins from Eventide to BOOM Library (Victor, 2026-11-01).
-- A seller filed StereoLab, Enforcer, DeBird and LiftFX under Eventide on 3 Oct because BOOM Library
-- was not in the developer list, and the seller of listing 1151 (StereoLab) reported it by email.
-- BOOM Library GmbH (Mainz, Germany) plugin EULA, section 5 item 3, says all licenses are nontransferable
-- (no selling or gifting to another person, only to affiliates and successors of a business).
-- Victor is asking BOOM Library directly before marking it not transferable, so for now the policy stays
-- unverified: transferable null, last_verified empty, the EULA clause is quoted in the restrictions text.
-- Flip to false (or true with the process) once BOOM Library answers.
-- The plugin rows keep their ids, so listings and alerts pointing at them follow the move.
-- Names lose the doubled brand (the developer name is shown next to them).
-- Run once in Supabase > SQL Editor.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('BOOM Library', 'boom-library', 'https://www.boomlibrary.com', null,
 null, null,
 null,
 null,
 'The BOOM Library plugin license agreement (section 5) says licenses are nontransferable: they may not be sold or given to another person, except to affiliates and successors of a business. BOOM Library publishes no transfer process. Ask BOOM Library support before buying or selling.',
 'https://www.boomlibrary.com/terms-conditions-regular/', null, false)
on conflict (slug) do nothing;

update public.plugins p set
  developer_id = (select id from public.developers where slug = 'boom-library'),
  name = v.name
from (values
  ('boom-library-stereolab', 'StereoLab'),
  ('boom-library-enforcer', 'Enforcer'),
  ('boom-library-debird', 'DeBird'),
  ('boom-library-liftfx', 'LiftFX')
) as v(slug, name)
where p.slug = v.slug
  and p.developer_id = (select id from public.developers where slug = 'eventide');
