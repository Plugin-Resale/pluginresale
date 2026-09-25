-- Step 39: Sonarworks transfer policy verified from official pages (Victor, 2026-09-25).
-- Victor asked the Sonarworks support chat, which pointed to the EULA and the help center.
-- Checked on the official pages, not the chat answer:
-- 1. EULA section 4 License Ownership Transfer (sonarworks.com/legal/eula): the seller and
--    the new owner contact the Support Team, Sonarworks gives its consent, the old license
--    ends and a new one is issued to the new owner. Sonarworks may refuse consent if the
--    transfer breaks the law or its terms. Trial licenses are non-transferable.
-- 2. Help center article How to activate and manage a SoundID Reference license, section
--    License ownership transfer: the only legitimate way to sell or give away a license.
--    Both owners each submit a separate support request with both full names, both email
--    addresses and the activation key. Removing the license from the account is not a
--    valid ownership transfer. EDU licenses have a single activation seat.
-- Neither page mentions a fee or a delay, so fee, who_pays and typical_delay stay empty
-- (shown as Not stated) and no_fee stays false.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = null,
  who_pays = null,
  process = 'The seller and the buyer each submit their own support request to Sonarworks (support.sonarworks.com), both including the full name and email address of the seller and of the buyer, plus the license activation key. Once Sonarworks approves, the seller''s license ends and a new license is issued to the buyer.',
  typical_delay = null,
  restrictions = 'Sonarworks has to approve every ownership transfer and can refuse it if it breaks the law or its terms. Removing the license from your Sonarworks account is not a valid transfer: only the support procedure counts. Trial licenses can''t be transferred. EDU licenses work on one computer only (up to three for most other licenses). If calibrated headphones are sold with the license, the seller can give the buyer the profile ID printed on the headphones.',
  source_url = 'https://support.sonarworks.com/hc/en-us/articles/4405063023634-License-ownership-transfer-to-another-person',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'sonarworks';
