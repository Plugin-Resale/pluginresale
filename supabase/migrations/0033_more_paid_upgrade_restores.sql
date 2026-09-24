-- Step 33: restore 4 more paid-upgrade products merged away in 0024 (Victor, 2026-09-24).
-- Same issue as FabFilter Pro-Q 3 / Pro-C 2 (0032): these were renamed into their current
-- major version under the "keep only current version" rule, but every one of them charges
-- for a major-version upgrade, so the old and new versions are different, separately
-- resellable products. New standing rule: never merge major versions unless the developer
-- confirms the upgrade is free (see Catalogue maintenance rules in CLAUDE.md).
--   - Altiverb: audioease.com own upgrade page lists paid upgrades from any old version.
--   - Pianoteq: modartt.com/buy lists a paid $29 upgrade fee to Pianoteq 9 (plus separate
--     paid fees to move between the Stage/Standard/Pro editions).
--   - Music Production Suite (iZotope) and FX Collection (Arturia): both show a priced
--     crossgrade/upgrade offer for existing owners, not a free update, on their own store
--     pages (exact price is behind a sign-in / JS-rendered store, but the offer itself is
--     a paid tier, never described as free).
-- Run once in Supabase > SQL Editor, after 0032.

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('audio-ease', 'Altiverb 7 XL', 'altiverb-7-xl', 'reverb-delay'),
  ('audio-ease', 'Altiverb 7 Regular', 'altiverb-7-regular', 'reverb-delay'),
  ('izotope', 'Music Production Suite 7', 'music-production-suite-7', 'bundles'),
  ('arturia', 'FX Collection 5', 'fx-collection-5', 'bundles'),
  ('modartt', 'Pianoteq 8 Pro', 'pianoteq-8-pro', 'synths'),
  ('modartt', 'Pianoteq 8 Standard', 'pianoteq-8-standard', 'synths'),
  ('modartt', 'Pianoteq 8 Stage', 'pianoteq-8-stage', 'synths'),
  ('steinberg', 'SpectraLayers Pro 11', 'spectralayers-pro-11', 'utilities')
) as p(dev_slug, name, slug, category), public.developers d
where d.slug = p.dev_slug
on conflict (developer_id, slug) do update set category = excluded.category;
