-- Step 45: Minimal Audio transfer policy confirmed (Victor, 2026-09-25).
-- Minimal Audio Support replied by email on 2026-09-25 and pointed to its official
-- License Transfer Policy and Guide page, which states: transfer after six months of
-- ownership, done by the owner from the Downloads section of the account page, the buyer
-- needs a Minimal Audio account, not reversible, a license can only be transferred once,
-- transfers can be denied in certain cases such as NFRs. The page lists no fee and the
-- support email confirms there is none.
-- Replaces the unverified entry from step 11: transferable becomes true.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = 'Free',
  who_pays = null,
  process = 'The seller logs in to their Minimal Audio account, goes to Downloads, clicks Transfer next to the product and enters the buyer''s email. The buyer needs a Minimal Audio account first. Transfers can''t be reversed.',
  typical_delay = null,
  restrictions = 'Only after 6 months of ownership (licenses bought from Minimal Audio or a third-party store). A license can only be transferred once: a license received through a transfer can''t be resold. Minimal Audio can refuse some transfers, for example NFR licenses.',
  source_url = 'https://support.minimal.audio/en/help/articles/28544554565275-license-transfer-policy-and-guide',
  last_verified = '2026-09-25',
  no_fee = true
where slug = 'minimal-audio';
