-- Step 42: HOFA transfer policy confirmed (Victor, 2026-09-25).
-- HOFA support (Buddy Clements, ticket 27577) replied by email on 2026-09-25: transfers to
-- other customers are allowed, 20 EUR per plugin up to 50 EUR, the seller tells HOFA which
-- plugin goes to which customer account. The official page they linked states the same
-- fee, that licenses must be deactivated first, that the transfer is done manually, and that
-- EDU products and parts of bundles can not be resold.
-- Replaces the unverified entry from step 13: transferable becomes true.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = '€20 per product, up to €50 for several products.',
  who_pays = null,
  process = 'The seller deactivates the license on their computers, then emails HOFA support with the plugin and the buyer''s HOFA account email (the buyer creates a free HOFA account first). HOFA moves the license by hand.',
  typical_delay = null,
  restrictions = 'Single plugins and full bundles can be resold. Educational (EDU) licenses and parts of a bundle can''t.',
  source_url = 'https://support.hofa-plugins.de/portal/en/kb/articles/resell-hofa-plugins',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'hofa';
