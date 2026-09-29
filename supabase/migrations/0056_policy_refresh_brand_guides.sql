-- Policy refresh, found while re-reading the official pages for the brand resale guides (2026-09-29).
-- Arturia: the help article was rewritten. Products registered 6+ months are unregistered by the
-- seller in My Arturia, earlier ones go through a support ticket. No fee mentioned anymore
-- (the old 10 euro second-hand fee is gone from the page).
-- oeksound: the page now states the fee (15 USD per license), soothe3 upgrade rules and
-- that rent-to-own licenses are excluded.
-- Plugin Alliance: new article URL, it now only says transfers are not currently possible.
-- Spitfire Audio: the old Zendesk help center is closed, the EULA (section 6, No Resale of
-- Products) is the source now.
-- u-he and Softube: restrictions completed from their official pages (NFR and soundsets for
-- u-he, locked bundles for Softube).
-- Run once in Supabase > SQL Editor.

update public.developers set
  fee = 'None mentioned on Arturia''s official page',
  who_pays = null,
  process = 'Registered 6+ months ago: the seller unregisters the product in My Arturia (My Products > Show more details), then the buyer registers it on their own account. Registered less than 6 months ago: the seller opens a support ticket (Registration & third party) and can include the buyer''s Arturia account email to have it moved directly.',
  typical_delay = null,
  restrictions = 'Before 6 months of registration, only Arturia support can unregister or transfer the product. Software bundled with Arturia hardware transfers with the hardware, including linked upgrades.',
  source_url = 'https://support.arturia.com/hc/en-us/articles/29110221549340-How-to-unregister-resell-transfer-hardware-products-or-software-licenses',
  last_verified = '2026-09-29',
  no_fee = true
where slug = 'arturia';

update public.developers set
  fee = '$15 per license',
  who_pays = 'Seller',
  process = 'The seller deactivates the license everywhere and fills in the license transfer form on oeksound.com (one transfer per license), then confirms via the "Action required" email. oeksound checks and completes it.',
  typical_delay = '1 to 2 business days',
  restrictions = 'Licenses must be at least one month old. Transfers are final. An upgrade license can''t be sold on its own: selling a soothe3 upgrade revokes both the soothe2 and upgrade licenses and the buyer gets a full soothe3 license. Owners of a soothe3 upgrade can''t sell soothe2 alone. Rent-to-own licenses can''t be transferred.',
  source_url = 'https://oeksound.com/support/reselling-licenses/',
  last_verified = '2026-09-29'
where slug = 'oeksound';

update public.developers set
  process = 'Plugin Alliance support states that license transfers are not currently possible.',
  restrictions = 'Previous policy (no longer offered): $20 per plug-in (max $50), paid by the buyer; subscription licenses and already-transferred licenses excluded.',
  source_url = 'https://support.plugin-alliance.com/hc/en-us/articles/52323567089428-License-Transfer',
  last_verified = '2026-09-29'
where slug = 'plugin-alliance';

update public.developers set
  restrictions = 'Spitfire''s EULA (section 6, No Resale of Products) grants a personal, non-transferable licence: products can''t be given, transferred or offered for resale.',
  source_url = 'https://www.spitfireaudio.com/pages/spitfire-audio-end-user-license-agreement',
  last_verified = '2026-09-29'
where slug = 'spitfire-audio';

update public.developers set
  restrictions = 'Not possible during the first 6 weeks after purchase. NFR licenses can''t be transferred. Soundsets move automatically with their plug-in and can''t be transferred on their own. The buyer always receives the license directly from u-he, never from the seller.',
  last_verified = '2026-09-29'
where slug = 'u-he';

update public.developers set
  restrictions = 'Not before 90 days after the license was deposited. Plug-ins that are part of locked bundles (such as Volume 6 and most bundles) can''t be sold separately.',
  last_verified = '2026-09-29'
where slug = 'softube';
