-- Step 43: Fender transfer policy verified (Victor, 2026-09-25).
-- The official Fender/PreSonus support article (Fender Software License Transfer, updated
-- 2026-08-10, labelled Fender Studio Pro) says the EULA allows the permanent transfer of a
-- Fender software license (Studio One / Studio Pro, Notion, Progression, add-ons).
-- The seller starts it from my.fender.com and pays the fee in the Fender store.
-- Fees: 25 USD for Studio One / Studio Pro, 10 USD for Notion or Progression, 5 USD per add-on.
-- Excluded: NFR, software given free with hardware, Prime/demo/free/beta versions, a perpetual
-- license left from the end of a yearly subscription, StudioLive Series III plugins.
-- Replaces the unverified entry from step 12: transferable becomes true.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = '$25 for Studio Pro / Studio One, $10 for Notion or Progression, $5 per add-on.',
  who_pays = 'Seller',
  process = 'The buyer creates a Fender account first. The seller logs in to my.fender.com, opens the product under My Gear, clicks Transfer License, enters the buyer''s account email and pays the fee in the Fender store. Both sides get a confirmation email once it''s done: keep it.',
  typical_delay = 'Immediate once the fee is paid.',
  restrictions = 'NFR licenses, software given free with hardware, Prime/demo/free/beta versions and perpetual licenses left over from a yearly subscription can''t be transferred. Licenses linked by an upgrade move together as one. Transfers are permanent. Bundled third-party software (e.g. Melodyne) isn''t covered: transfer it separately with its own developer.',
  source_url = 'https://support.presonus.com/hc/en-us/articles/360045106552-Fender-Software-License-Transfer',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'fender';
