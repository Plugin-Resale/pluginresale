-- Step 36: fill in what is known about the Neural DSP transfer policy (Victor, 2026-09-24).
-- The source cited since 0019 (support.neuraldsp.com/help/can-i-sell-my-licenses) no longer
-- exists, the support site now only has activation articles, and the terms of service
-- (neuraldsp.com/pages/terms-of-service) say nothing about license transfers.
-- The only details come from Neural DSP official forum, thread "Are plugins sellable?"
-- (July 2025): a user quotes an email from Neural DSP support (transfer to another user
-- possible, 25 USD admin fee per license, reduced rate for several, free promotional
-- licenses such as the ones bundled with a Quad Cortex excluded), and a second user
-- confirms having transferred a license. No Neural DSP staff post confirms it.
-- Project rule: forum-only info stays unverified, so transferable stays null and
-- last_verified stays empty. The forum thread replaces the dead link as source_url.
-- Run once in Supabase > SQL Editor.

update public.developers set
  restrictions = 'Neural DSP licenses live in iLok (one license = 3 simultaneous activations on the same iLok account). Neural DSP has no public resale page, but a user reported on its official forum (July 2025) that Neural DSP support confirmed by email that a license can be transferred to another user, for a $25 administrative fee per license (reduced rate for several licenses). Licenses received free as a promotion (for example with a Quad Cortex) can''t be transferred. Not confirmed on an official page: email support@neuraldsp.com before buying or selling.',
  source_url = 'https://unity.neuraldsp.com/t/are-plugins-sellable/19012',
  last_verified = null
where slug = 'neural-dsp';
