-- Step 70: BOOM Library policy answered by email (Victor, 2026-11-05).
--
-- BOOM Library support (Frank Marsilio, Sales and Support, ticket BOOM_7809, 2026-11-05) replied
-- that BOOM sells a personal usage right, not the software, and that a license may not be
-- transferred or sold, as the plugin EULA (section 5) says. Exceptions are only considered
-- case by case (hacked iLok account, company liquidation), never a sale to another person.
-- Licenses live in iLok License Manager, where a transfer would cost at least 25 USD, but
-- BOOM does not allow it. Written refusal from the developer itself, enough to mark it
-- not transferable (step 50). The EULA stays the cited source.
-- Covers StereoLab, Enforcer, DeBird, LiftFX (moved from Eventide in step 69).
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer to another person: BOOM Library told us it sells a personal usage right, not the software, and that a license may not be sold or given to someone else, as its plugin EULA (section 5) says. Exceptions are only considered case by case (a hacked iLok account, a company closing down), never a sale.',
  typical_delay = null,
  restrictions = 'Stated by BOOM Library support in writing (November 2026), in line with the plugin license agreement, section 5. Licenses are managed in iLok License Manager, but BOOM Library does not allow transfers between users.',
  source_url = 'https://www.boomlibrary.com/terms-conditions-regular/',
  last_verified = '2026-11-05',
  no_fee = false
where slug = 'boom-library';
