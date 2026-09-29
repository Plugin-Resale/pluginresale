-- Step 54: Serato policy answered by email (Victor, 2026-09-29).
--
-- Serato Sales (Brad D, request 1218217, 2026-09-29) replied that Serato does not support
-- transferring software to another user account. Serato only moves software from an old
-- account to a new account of the same person, on request from the email address of the
-- account that holds it. Nothing published on the Serato website, the terms of sale only
-- cover moving a license between your own computers and stay the cited source.
-- Written refusal from the developer itself, enough to mark it not transferable (step 50).
-- Covers Serato DJ Pro, Serato Sample and Serato Studio.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer to another person: Serato told us it does not move software to another user''s account. It only moves software from an old account to a new account of the same owner, on request from the account''s email address.',
  typical_delay = null,
  restrictions = 'Stated by Serato support in writing (September 2026). Not published on its website, whose terms of sale only cover moving a license between your own computers.',
  source_url = 'https://serato.com/legal/terms-of-sale',
  last_verified = '2026-09-29',
  no_fee = false
where slug = 'serato';
