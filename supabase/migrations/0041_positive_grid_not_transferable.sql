-- Step 41: Positive Grid transfer policy confirmed (Victor, 2026-09-25).
-- Positive Grid support replied by email to Victor on 2026-09-25 (request 599279): software
-- licenses are non-transferable and cannot be resold or given to another user once
-- activated, for every license type (NFR, education, bundle, upgrade, promotional, free), with
-- no transfer process or fee. The official source is the Positive Grid Terms and Conditions,
-- section 10: software licenses are non-transferable and remain tied to the original
-- purchaser account, and you may not transfer the Software. Only hardware can change owner,
-- once the seller unregisters it (same section).
-- Replaces the unverified entry from step 11: transferable becomes false.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer process: Positive Grid support confirmed that transfers aren''t supported, for any license type. To give the software to someone, buy a license with their email address or a Positive Grid gift card instead.',
  typical_delay = null,
  restrictions = 'Positive Grid''s terms (section 10) state that software licenses are non-transferable and remain tied to the original purchaser''s account, and that you may not transfer the software. This applies to every license type, including NFR, education, bundle, upgrade, promotional and free licenses. Only hardware (such as a Spark amp) can change owner, once the seller unregisters it.',
  source_url = 'https://www.positivegrid.com/pages/terms-and-conditions',
  last_verified = '2026-09-25',
  no_fee = false
where slug = 'positive-grid';
