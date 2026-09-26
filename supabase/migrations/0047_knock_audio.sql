-- Step 47: move the seller-added plugin Knock to its real developer, Knock Audio (Victor, 2026-09-26).
-- A seller (created_by set, added from the Sell form) listed KNOCK under Ableton because Knock
-- Audio was not in the developer list. KNOCK is the drum plugin by DECAP, sold by Knock Audio
-- (formerly Plugins That Knock, knockaudio.com), not an Ableton product.
-- Knock Audio publishes no license transfer policy. Its terms of service are the generic shop
-- template (no reproducing or reselling any portion of the Service without written permission),
-- which does not address plugin licenses. So the policy stays unverified: transferable null,
-- last_verified empty, both sides asked to check with Knock Audio first.
-- The plugin row keeps its id, so any listing or alert pointing at it follows the move.
-- Run once in Supabase > SQL Editor.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Knock Audio', 'knock-audio', 'https://knockaudio.com', null,
 null, null,
 null,
 null,
 'Knock Audio (formerly Plugins That Knock) publishes no license transfer policy. Its terms of service only contain a generic shop clause against reselling any portion of the Service without its written permission, which does not say whether a plugin license can change owner. Ask Knock Audio support before buying or selling.',
 'https://knockaudio.com/policies/terms-of-service', null, false)
on conflict (slug) do nothing;

update public.plugins set
  developer_id = (select id from public.developers where slug = 'knock-audio'),
  name = 'KNOCK'
where slug = 'knock'
  and developer_id = (select id from public.developers where slug = 'ableton');
