-- Step 46: Synchro Arts transfer policy confirmed (Victor, 2026-09-25).
-- Synchro Arts support (Nick, request 2332948) replied by email on 2026-09-25: licenses
-- can not be transferred to another person, for every license type (full, upgrade,
-- education, NFR, bundle, promotional), a license stays with its original buyer, only moving
-- it between the owner computers is possible. The basis they gave is the General Provisions
-- section of the Synchro Arts terms (no assignment or transfer to a third party without the
-- prior written consent of LANDR, at its sole discretion), checked on the official page.
-- A follow-up question about EU customers (UsedSoft v Oracle) was passed to LANDR, no answer yet.
-- Replaces the unverified entry from step 15: transferable becomes false.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer process: Synchro Arts support confirmed that a license stays with the person who bought it, for every license type. You can only move it between your own computers (deactivate it in the plugin, then activate it on the new one).',
  typical_delay = null,
  restrictions = 'Synchro Arts'' terms (General Provisions) forbid transferring the agreement or its rights to anyone without LANDR''s prior written consent, at its sole discretion. Support confirmed this covers full, upgrade, education, NFR, bundle and promotional licenses.',
  source_url = 'https://www.synchroarts.com/terms-and-conditions',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'synchro-arts';
