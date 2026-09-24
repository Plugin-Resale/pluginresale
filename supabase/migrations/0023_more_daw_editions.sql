-- Step 23: more DAW editions/tiers for developers already in the `daw` category, plus one
-- more real DAW maker (Bremmers Audio Design / MultitrackStudio). There is a hard ceiling
-- on how many genuinely distinct commercial DAWs exist, so this widens coverage rather
-- than doubling it outright. Also corrects two product names to their current version
-- (Samplitude Pro X -> X8, Mixcraft -> 10.6) and reclassifies Serato Studio as a DAW
-- (it's marketed as a full beat-making DAW, not just a utility). Checked 2026-09-26.

update public.plugins set name = 'Samplitude Pro X8', slug = 'samplitude-pro-x8'
where slug = 'samplitude-pro-x' and developer_id = (select id from public.developers where slug = 'magix');
update public.plugins set name = 'Mixcraft 10.6', slug = 'mixcraft-10-6'
where slug = 'mixcraft' and developer_id = (select id from public.developers where slug = 'acoustica');

update public.plugins set category = 'daw'
where slug = 'serato-studio' and developer_id = (select id from public.developers where slug = 'serato');

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Bremmers Audio Design', 'bremmers-audio-design', 'https://www.multitrackstudio.com', null,
 null, null, null, null,
 'Bremmers Audio Design (MultitrackStudio) doesn''t publish a clear resale/transfer policy. Ask their support before buying or selling.',
 null, null, false);

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, 'daw'
from (values
  ('magix', 'Samplitude Pro X8 Suite', 'samplitude-pro-x8-suite'),
  ('steinberg', 'Cubase Elements 15', 'cubase-elements-15'),
  ('steinberg', 'Dorico Elements 6', 'dorico-elements-6'),
  ('harrison-audio', 'Mixbus32C', 'mixbus32c'),
  ('n-track', 'n-Track Studio Suite', 'n-track-studio-suite'),
  ('n-track', 'n-Track Studio Extended', 'n-track-studio-extended'),
  ('acoustica', 'Mixcraft 10.6 Pro Studio', 'mixcraft-10-6-pro-studio'),
  ('bremmers-audio-design', 'MultitrackStudio 11', 'multitrackstudio-11')
) as p(dev_slug, name, slug)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
