-- Step 58: two seller-added plugins filed wrong (Victor, 2026-09-30).
-- 1. Cradle Audio - The God Particle was added under Avid because Cradle was not in the
--    developer list. Cradle becomes its own developer and the plugin moves there as The God Particle.
--    Policy from the official Cradle support article (read through the Zendesk API, the web page
--    answers 403 to scripts, updated 2026-02-04): licenses can be transferred to someone else,
--    the buyer creates and verifies a Cradle account and signs in on cradle.app, then either side
--    contacts Cradle support, which moves the licenses and notifies both users.
--    No fee and no exclusions are stated, so fee stays empty.
-- 2. Arturia Arturia Chorus Dimension-D becomes Chorus DIMENSION-D, the name Arturia uses
--    (the brand showed twice in titles).
-- Slugs are kept so page URLs do not change.
-- Run once in Supabase > SQL Editor.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Cradle', 'cradle', 'https://cradle.app', true,
 null, null,
 'The buyer creates and verifies a Cradle account, then signs in on cradle.app. The seller or the buyer then contacts Cradle support with both account emails, and Cradle moves the license to the buyer account. Both users get an email when the transfer is done.',
 null,
 null,
 'https://support.cradle.app/hc/en-us/articles/45973358499220-I-want-to-change-email-address-or-transfer-my-licenses',
 '2026-09-30', false)
on conflict (slug) do nothing;

update public.plugins set
  developer_id = (select id from public.developers where slug = 'cradle'),
  name = 'The God Particle'
where slug = 'cradle-audio-the-god-particle'
  and developer_id = (select id from public.developers where slug = 'avid');

update public.plugins set name = 'Chorus DIMENSION-D'
where slug = 'arturia-chorus-dimension-d'
  and developer_id = (select id from public.developers where slug = 'arturia');
