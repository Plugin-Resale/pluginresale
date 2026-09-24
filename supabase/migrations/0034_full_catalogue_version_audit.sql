-- Step 34: full-catalogue sweep for the same paid-upgrade merge mistake (Victor asked to
-- check everything, 2026-09-24). Every past migration was scanned for a version number
-- changing inside a rename (the same shape as the FabFilter/Altiverb/Pianoteq mistakes
-- already fixed in 0032/0033). Out of 386 renames across the whole history, only 4 more
-- were real major-version merges (the rest were slug/spelling cleanups or fixing a
-- fabricated version number, not a version-to-version merge):
--   - Audio Ease Speakerphone 2 -> 3: confirmed paid (audioease.com own upgrade page,
--     same "any old version upgrades to the current one" program as Altiverb).
--   - Initial Audio Heat Up 2 -> 3, Tone2 Icarus 2 -> 3, Metric Halo ChannelStrip 3 -> v4:
--     no free-upgrade language found on their sites either way. Per the new Catalogue
--     maintenance rule (unconfirmed = keep separate), restored as their own entries.
-- Run once in Supabase > SQL Editor, after 0033.

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('audio-ease', 'Speakerphone 2', 'speakerphone-2', 'utilities'),
  ('tone2', 'Icarus 2', 'icarus-2', 'synths'),
  ('initial-audio', 'Heat Up 2', 'heat-up-2', 'saturation'),
  ('metric-halo', 'ChannelStrip 3', 'channelstrip-3', 'channel-strips')
) as p(dev_slug, name, slug, category), public.developers d
where d.slug = p.dev_slug
on conflict (developer_id, slug) do update set category = excluded.category;
