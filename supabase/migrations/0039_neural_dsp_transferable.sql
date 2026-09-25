-- Step 39: Neural DSP transfer policy confirmed in writing (Victor, 2026-09-25).
-- Neural DSP Support Team replied by email to Victor on 2026-09-25: paid perpetual plugin
-- licenses can be transferred to another person through iLok License Manager, the current
-- owner starts the transfer to the buyer iLok User ID and pays the iLok transfer fee
-- (25 USD for one license or eligible bundle, 50 USD maximum per transaction), no need to
-- contact Neural DSP, trials, NFR and some complimentary or promotional licenses are excluded
-- (no transfer option in iLok License Manager means not eligible), and iLok may restrict
-- recently deposited licenses or new accounts for 90 days. Neural DSP pointed to the iLok
-- license-transfer page as the official source, and it states the same fee and 90-day rule
-- (help.ilok.com/faq_licenses.html, section Transferring Licenses to Another Account).
-- This replaces the forum-only information from step 36: transferable becomes true.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = 'iLok transfer fee: $25 for one license or eligible bundle, $50 maximum for several licenses in one transaction.',
  who_pays = 'Seller',
  process = 'The seller transfers the license to the buyer''s iLok User ID in iLok License Manager. No need to contact Neural DSP support. Transfers can''t be reversed: double-check the buyer''s iLok User ID.',
  typical_delay = null,
  restrictions = 'Only paid perpetual licenses can be transferred. Trials, NFR licenses and some complimentary or promotional licenses can''t: if the transfer option isn''t available in iLok License Manager, the license isn''t eligible. iLok doesn''t allow a transfer within 90 days of the license being deposited, or from an account less than 90 days old.',
  source_url = 'https://help.ilok.com/faq_licenses.html#transfer_between_accounts',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'neural-dsp';
