-- Step 64: Three-Body Technology not transferable (Victor, 2026-10-02).
-- TBTECH Support (Arthur) replied by email on 2026-10-02 that license transfer is not supported.
-- Nothing is published on threebodytech.com, so there is no source_url. Same rule as Xhun Audio
-- and Mercuriall (step 50): a written refusal from the developer itself is enough to mark a
-- developer not transferable. Replaces the unverified entry (transferable = null).
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer process: Three-Body Technology support told us license transfer is not supported.',
  typical_delay = null,
  restrictions = 'Stated by Three-Body Technology support in writing (email to Plugin Resale, October 2026). Not published on its website.',
  source_url = null,
  last_verified = '2026-10-02',
  no_fee = false
where slug = 'three-body-technology';
