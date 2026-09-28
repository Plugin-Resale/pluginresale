-- Step 50: three developer policies answered by email (Victor, 2026-09-28).
--
-- Metric Halo
-- Metric Halo Sales Support replied by email on 2026-09-25: the plug-ins are activated
-- through iLok and licenses are transferred directly in iLok License Manager with the
-- transfer tools PACE provides, any purchased license or upgrade is eligible, NFR licenses
-- and licenses bundled with a hardware purchase are generally not transferable, Metric Halo
-- charges no fee, a fee and a waiting period after activation may apply on the iLok side.
-- The official Metric Halo license activation page (mhsecure.com/LicenseActivation) confirms
-- iLok licensing, so the source is the iLok license-transfer page, same as Kush Audio (step 44).
-- Replaces the unverified entry based on the older Metric Halo EULA: transferable becomes true.
-- Run once in Supabase > SQL Editor.

update public.developers set
  transferable = true,
  fee = 'iLok transfer fee: $25 for one license or bundle, $50 for several licenses in one transaction. Metric Halo charges nothing on top.',
  who_pays = null,
  process = 'The seller transfers the license to the buyer''s iLok User ID in iLok License Manager (transfer icon, top right). Any purchased license or upgrade can be transferred. Transfers can''t be reversed: double-check the buyer''s iLok User ID.',
  typical_delay = null,
  restrictions = 'NFR licenses and licenses bundled with a hardware purchase are generally not transferable. iLok doesn''t allow a transfer within 90 days of the license being deposited, or from an account less than 90 days old.',
  source_url = 'https://help.ilok.com/faq_licenses.html#transfer_between_accounts',
  last_verified = '2026-09-28',
  no_fee = false
where slug = 'metric-halo';

-- Xhun Audio and Mercuriall Audio
-- Both replied by email that their licenses can not be transferred or resold. Xhun Audio
-- (Bruno Bordi, 2026-09-26): a license is issued individually at registration and can not be
-- resold. Mercuriall Audio (2026-09-28): the end-user license agreement accepted at
-- installation explicitly prohibits the transfer or resale of licenses for all products, NFR
-- handled case by case. Neither publishes this on its website (no online EULA or FAQ found),
-- so there is no source_url. Victor decided to mark them not transferable anyway: a written
-- refusal from the developer itself is safe to follow, while the unverified status let their
-- plugins be listed and a buyer could pay for a license the developer refuses to move.
-- Exception to the rule that an email alone is not a source, valid for refusals only.

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer process: Xhun Audio told us a license is issued individually to the person who registers it and can''t be resold.',
  typical_delay = null,
  restrictions = 'Stated by Xhun Audio in writing (email to Plugin Resale, September 2026). Not published on its website.',
  source_url = null,
  last_verified = '2026-09-28',
  no_fee = false
where slug = 'xhun-audio';

update public.developers set
  transferable = false,
  fee = null,
  who_pays = null,
  process = 'No transfer process: Mercuriall Audio told us its end-user license agreement, accepted when installing any of its products, prohibits transferring or reselling licenses.',
  typical_delay = null,
  restrictions = 'Stated by Mercuriall Audio in writing (email to Plugin Resale, September 2026). The agreement is shown at installation, not published on its website.',
  source_url = null,
  last_verified = '2026-09-28',
  no_fee = false
where slug = 'mercuriall-audio';
