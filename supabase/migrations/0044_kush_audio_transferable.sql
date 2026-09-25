-- Step 44: Kush Audio transfer policy confirmed (Victor, 2026-09-25).
-- Kush Audio support (Nathan Daniel, ticket ZLRE0M-R269W) replied by email on 2026-09-25:
-- Kush is not involved in transfers, the owner goes through PACE (iLok, support@paceap.com)
-- for the procedure and fees, Kush charges nothing on top, NFR licenses can not be resold
-- or transferred. The official source is therefore the iLok license-transfer page, which
-- states the iLok fee (25 USD for one license or bundle, 50 USD for several) and the 90-day
-- rule (help.ilok.com/faq_licenses.html, section License Transfer to Another Account).
-- Replaces the unverified entry from step 13: transferable becomes true.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = 'iLok transfer fee: $25 for one license or bundle, $50 for several licenses in one transaction. Kush Audio charges nothing on top.',
  who_pays = null,
  process = 'Kush Audio isn''t involved: the seller transfers the license to the buyer''s iLok User ID in iLok License Manager. For help, contact PACE (iLok) support at support@paceap.com. Transfers can''t be reversed: double-check the buyer''s iLok User ID.',
  typical_delay = null,
  restrictions = 'NFR (Not For Resale) licenses can''t be resold or transferred. iLok doesn''t allow a transfer within 90 days of the license being deposited, or from an account less than 90 days old.',
  source_url = 'https://help.ilok.com/faq_licenses.html#transfer_between_accounts',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'kush-audio';
