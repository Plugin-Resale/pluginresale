-- Step 53: Boris FX policy answered by email (Victor, 2026-09-28).
--
-- Boris FX Support (ticket 115931, 2026-09-28) replied that Boris FX licenses are not
-- transferable between users, resale or transfer to another customer is not supported, and
-- this applies to every license type (NFR, educational, bundle, upgrade, promotional, free),
-- so there is no transfer fee or process. Consistent with the Boris FX license agreement
-- (no transfer without prior written consent), which stays the cited source.
-- Written refusal from the developer itself, enough to mark it not transferable (step 50).
-- Covers Sound Forge, Acid Pro, Samplitude and Sequoia.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer process: Boris FX told us its licenses can''t be transferred or resold to another customer.',
  typical_delay = null,
  restrictions = 'Applies to every license type, including NFR, educational, bundle, upgrade, promotional and free licenses. Stated by Boris FX support in writing (September 2026), in line with its license agreement, which forbids transfers without Boris FX''s prior written consent.',
  source_url = 'https://borisfx.com/store/eula/',
  last_verified = '2026-09-28',
  no_fee = false
where slug = 'boris-fx';
