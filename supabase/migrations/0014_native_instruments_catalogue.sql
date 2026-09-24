-- Step 14: complete the Native Instruments catalogue (was 18 products, mostly outdated versions).
-- Checked against native-instruments.com and the Komplete 26 release (May 2026) on 2026-09-25.

-- Outdated bundle versions: drop the discontinued one, rename the others to Komplete 26.
delete from public.plugins
where slug = 'komplete-14-standard' and developer_id = (select id from public.developers where slug = 'native-instruments');

update public.plugins set name = 'Komplete 26 Standard', slug = 'komplete-26-standard'
where slug = 'komplete-15-standard' and developer_id = (select id from public.developers where slug = 'native-instruments');
update public.plugins set name = 'Komplete 26 Ultimate', slug = 'komplete-26-ultimate'
where slug = 'komplete-15-ultimate' and developer_id = (select id from public.developers where slug = 'native-instruments');

-- Absynth was discontinued then relaunched as version 6 in Komplete 26.
update public.plugins set name = 'Absynth 6', slug = 'absynth-6'
where slug = 'absynth-5' and developer_id = (select id from public.developers where slug = 'native-instruments');

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('Komplete 26 Collector''s Edition', 'komplete-26-collectors-edition', 'bundles'),

  -- Synths
  ('Rounds', 'rounds', 'synths'),
  ('Reaktor Prism', 'reaktor-prism', 'synths'),
  ('Flesh', 'flesh', 'synths'),
  ('Razor', 'razor', 'synths'),
  ('Skanner XT', 'skanner-xt', 'synths'),
  ('Knifonium', 'knifonium', 'synths'),
  ('The Mouth', 'the-mouth', 'synths'),

  -- Effects
  ('Raum', 'raum', 'reverb-delay'),
  ('RC 24', 'rc-24', 'reverb-delay'),
  ('RC 48', 'rc-48', 'reverb-delay'),
  ('Solid Bus Comp', 'solid-bus-comp', 'compression'),
  ('Solid Dynamics', 'solid-dynamics', 'compression'),
  ('Solid EQ', 'solid-eq', 'eq'),
  ('Enhanced EQ', 'enhanced-eq', 'eq'),
  ('Passive EQ', 'passive-eq', 'eq'),
  ('VC 2A', 'vc-2a', 'compression'),
  ('VC 76', 'vc-76', 'compression'),
  ('VC 160', 'vc-160', 'compression'),
  ('Vari Comp', 'vari-comp', 'compression'),
  ('Driver', 'driver', 'saturation'),
  ('Molekular', 'molekular', 'utilities'),
  ('Phasis', 'phasis', 'utilities'),

  -- Play Series / Session Series / Scoring instruments
  ('Alicia''s Electric Keys', 'alicias-electric-keys', 'sample-libraries'),
  ('Ashlight', 'ashlight', 'sample-libraries'),
  ('Action Woodwinds', 'action-woodwinds', 'sample-libraries'),
  ('Kithara', 'kithara', 'sample-libraries'),
  ('Fables', 'fables', 'sample-libraries'),
  ('Valves Pro', 'valves-pro', 'sample-libraries'),
  ('Nacht', 'nacht', 'sample-libraries'),
  ('Bouquet', 'bouquet', 'sample-libraries'),
  ('Duets', 'duets', 'sample-libraries'),
  ('Glaze 2', 'glaze-2', 'sample-libraries'),
  ('Claire', 'claire', 'sample-libraries'),
  ('Claire: Avant', 'claire-avant', 'sample-libraries'),
  ('Moments: Vocal Clouds', 'moments-vocal-clouds', 'sample-libraries'),
  ('Cremona Quartet Ensemble', 'cremona-quartet-ensemble', 'sample-libraries'),
  ('Erosia', 'erosia', 'sample-libraries'),
  ('LCO Producer Strings', 'lco-producer-strings', 'sample-libraries'),
  ('Jam Bass', 'jam-bass', 'sample-libraries'),
  ('Electric Ruby', 'electric-ruby', 'sample-libraries'),
  ('Electric Neon Essential', 'electric-neon-essential', 'sample-libraries'),
  ('Electric Storm', 'electric-storm', 'sample-libraries'),
  ('Marco Polo Drums', 'marco-polo-drums', 'sample-libraries'),
  ('Abbey Road 60s Drummer', 'abbey-road-60s-drummer', 'sample-libraries'),
  ('Abbey Road Drummer Collection', 'abbey-road-drummer-collection', 'bundles'),

  -- Production tools
  ('Traktor Pro 4', 'traktor-pro-4', 'utilities'),
  ('Maschine 3', 'maschine-3', 'utilities')
) as p(name, slug, category)
join public.developers d on d.slug = 'native-instruments'
on conflict (developer_id, slug) do nothing;
