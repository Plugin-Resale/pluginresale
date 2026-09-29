-- Step 55: clean up two plugins added by sellers from the Sell form (Victor, 2026-09-29).
-- Their all-caps names showed up as-is in page titles and in Google.
-- 1. Steinberg STEINBERG WAVELAB PRO 13 becomes WaveLab Pro 13, the official name on
--    steinberg.net/wavelab. Kept as its own row next to WaveLab Pro 12 (major versions stay
--    separate). Category mastering, like WaveLab Pro 12. The slug is kept so its page URL does not change.
-- 2. Newfangled Audio NEWFLANGED ELEVATE MASTERING BUNDLE is the catalogue row Elevate Mastering
--    Bundle typed again. Listings and alerts move to the catalogue row first, then the duplicate
--    is removed (never delete a plugin while a listing points at it).
-- Run once in Supabase > SQL Editor.

update public.plugins set name = 'WaveLab Pro 13', category = 'mastering'
where slug = 'steinberg-wavelab-pro-13'
  and developer_id = (select id from public.developers where slug = 'steinberg');

update public.listings set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'newfangled-audio' and p.slug = 'elevate-mastering-bundle')
where plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'newfangled-audio' and p.slug = 'newflanged-elevate-mastering-bundle');

update public.listing_alerts a set plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'newfangled-audio' and p.slug = 'elevate-mastering-bundle')
where a.plugin_id = (
  select p.id from public.plugins p join public.developers d on d.id = p.developer_id
  where d.slug = 'newfangled-audio' and p.slug = 'newflanged-elevate-mastering-bundle')
  and not exists (
    select 1 from public.listing_alerts b
    where b.user_id = a.user_id and b.plugin_id = (
      select p.id from public.plugins p join public.developers d on d.id = p.developer_id
      where d.slug = 'newfangled-audio' and p.slug = 'elevate-mastering-bundle'));

delete from public.plugins p
using public.developers d
where d.id = p.developer_id
  and d.slug = 'newfangled-audio'
  and p.slug = 'newflanged-elevate-mastering-bundle'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
