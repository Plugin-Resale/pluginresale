-- Step 16: bring 30 major developers to a complete or near-complete catalogue.
-- Also fixes a few outdated/incorrect entries found along the way (iZotope RX/Ozone
-- versions, a duplicate Neutron 4, Arturia instrument names that had a stray "4").
-- Checked against each developer's official pages on 2026-09-25/26.

-- iZotope: version bump (RX 11 -> 12, Ozone 11 -> 12) and drop the superseded Neutron 4.
update public.plugins set name = 'RX 12 Standard', slug = 'rx-12-standard'
where slug = 'rx-11-standard' and developer_id = (select id from public.developers where slug = 'izotope');
update public.plugins set name = 'RX 12 Advanced', slug = 'rx-12-advanced'
where slug = 'rx-11-advanced' and developer_id = (select id from public.developers where slug = 'izotope');
update public.plugins set name = 'Ozone 12 Standard', slug = 'ozone-12-standard'
where slug = 'ozone-11-standard' and developer_id = (select id from public.developers where slug = 'izotope');
update public.plugins set name = 'Ozone 12 Advanced', slug = 'ozone-12-advanced'
where slug = 'ozone-11-advanced' and developer_id = (select id from public.developers where slug = 'izotope');
delete from public.plugins
where slug = 'neutron-4' and developer_id = (select id from public.developers where slug = 'izotope');

-- Arturia: these three had an incorrect "4" in the name/slug (Arturia's own naming has no number here).
update public.plugins set name = 'Mini V', slug = 'mini-v'
where slug = 'mini-v4' and developer_id = (select id from public.developers where slug = 'arturia');
update public.plugins set name = 'Jup-8 V', slug = 'jup-8-v'
where slug = 'jup-8-v4' and developer_id = (select id from public.developers where slug = 'arturia');
update public.plugins set name = 'CS-80 V', slug = 'cs-80-v'
where slug = 'cs-80-v4' and developer_id = (select id from public.developers where slug = 'arturia');
update public.plugins set name = 'V Collection 11 Pro', slug = 'v-collection-11-pro'
where slug = 'v-collection-x' and developer_id = (select id from public.developers where slug = 'arturia');

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  -- iZotope
  ('izotope', 'Insight 2', 'insight-2', 'utilities'),
  ('izotope', 'Tonal Balance Control 3', 'tonal-balance-control-3', 'utilities'),
  ('izotope', 'RX Post Production Suite 9', 'rx-post-production-suite-9', 'bundles'),
  ('izotope', 'Equinox', 'equinox', 'reverb-delay'),

  -- Arturia (V Collection 11 instruments not yet in the catalogue)
  ('arturia', 'Piano V', 'piano-v', 'sample-libraries'),
  ('arturia', 'B-3 V', 'b-3-v', 'synths'),
  ('arturia', 'Synclavier V', 'synclavier-v', 'synths'),
  ('arturia', 'Clavinet V', 'clavinet-v', 'synths'),
  ('arturia', 'DX7 V', 'dx7-v', 'synths'),
  ('arturia', 'Matrix-12 V', 'matrix-12-v', 'synths'),
  ('arturia', 'Wurli V', 'wurli-v', 'synths'),
  ('arturia', 'ARP 2600 V', 'arp-2600-v', 'synths'),
  ('arturia', 'VOX Continental V', 'vox-continental-v', 'synths'),
  ('arturia', 'Modular V', 'modular-v', 'synths'),
  ('arturia', 'MiniFreak V', 'minifreak-v', 'synths'),
  ('arturia', 'Buchla Easel V', 'buchla-easel-v', 'synths'),
  ('arturia', 'Jun-6 V', 'jun-6-v', 'synths'),
  ('arturia', 'Korg MS-20 V', 'korg-ms-20-v', 'synths'),
  ('arturia', 'Prophet-VS V', 'prophet-vs-v', 'synths'),
  ('arturia', 'Augmented Brass', 'augmented-brass', 'sample-libraries'),
  ('arturia', 'Augmented Woodwinds', 'augmented-woodwinds', 'sample-libraries'),

  -- u-he
  ('u-he', 'Protoverb', 'protoverb', 'reverb-delay'),

  -- Valhalla DSP
  ('valhalla-dsp', 'Supermassive', 'supermassive', 'reverb-delay'),
  ('valhalla-dsp', 'VintageVibe', 'vintagevibe', 'utilities'),

  -- Xfer Records
  ('xfer-records', 'OTT', 'ott', 'compression'),
  ('xfer-records', 'Dimension Expander', 'dimension-expander', 'utilities'),

  -- Kilohearts
  ('kilohearts', 'Vinyl', 'vinyl', 'utilities'),
  ('kilohearts', 'Vocode', 'vocode', 'utilities'),

  -- Sonnox
  ('sonnox', 'Oxford Transient Modulator', 'oxford-transient-modulator', 'compression'),

  -- DMG Audio
  ('dmg-audio', 'EQuick', 'equick', 'eq'),
  ('dmg-audio', 'NyquistX', 'nyquistx', 'mastering'),
  ('dmg-audio', 'Chorum', 'chorum', 'utilities'),
  ('dmg-audio', 'StereoTools', 'stereotools', 'utilities'),

  -- D16 Group
  ('d16-group', 'Antresol', 'antresol', 'reverb-delay'),
  ('d16-group', 'Fazortan 2', 'fazortan-2', 'utilities'),
  ('d16-group', 'Godfazer', 'godfazer', 'utilities'),
  ('d16-group', 'Redoptor 2', 'redoptor-2', 'saturation'),
  ('d16-group', 'Syntorus 2', 'syntorus-2', 'utilities'),

  -- Slate Digital
  ('slate-digital', 'ML-1', 'ml-1', 'mastering'),
  ('slate-digital', 'ML-2', 'ml-2', 'mastering'),

  -- McDSP
  ('mcdsp', 'Revolver', 'revolver', 'reverb-delay'),
  ('mcdsp', 'Channel G', 'channel-g', 'channel-strips'),

  -- Softube
  ('softube', 'Console 1', 'console-1', 'channel-strips'),
  ('softube', 'Volume 4', 'volume-4', 'mastering'),
  ('softube', 'Bass Amp Room', 'bass-amp-room', 'guitar-amps'),

  -- MeldaProduction
  ('meldaproduction', 'MEqualizer', 'mequalizer', 'eq'),
  ('meldaproduction', 'MCompressor', 'mcompressor', 'compression'),
  ('meldaproduction', 'MAutoPitch', 'mautopitch', 'utilities'),
  ('meldaproduction', 'MAnalyzer', 'manalyzer', 'utilities'),
  ('meldaproduction', 'MAutoAlign', 'mautoalign', 'utilities'),
  ('meldaproduction', 'MSaturator', 'msaturator', 'saturation'),
  ('meldaproduction', 'MStereoExpander', 'mstereoexpander', 'utilities'),
  ('meldaproduction', 'MCharmVerb', 'mcharmverb', 'reverb-delay'),
  ('meldaproduction', 'MXXX', 'mxxx', 'channel-strips'),

  -- Boz Digital Labs
  ('boz-digital-labs', 'Transgressor', 'transgressor', 'utilities'),
  ('boz-digital-labs', 'Sasquatch Kick Machine', 'sasquatch-kick-machine', 'utilities'),
  ('boz-digital-labs', 'Big Beautiful Door', 'big-beautiful-door', 'utilities'),
  ('boz-digital-labs', 'The Hoser XT', 'the-hoser-xt', 'eq'),
  ('boz-digital-labs', 'Mongoose', 'mongoose', 'utilities'),

  -- Klanghelm
  ('klanghelm', 'IVGI', 'ivgi', 'saturation'),

  -- Voxengo
  ('voxengo', 'CurveEQ', 'curveeq', 'eq'),
  ('voxengo', 'Deft Compressor', 'deft-compressor', 'compression'),
  ('voxengo', 'Redunoise', 'redunoise', 'utilities'),
  ('voxengo', 'Crunchessor', 'crunchessor', 'compression'),
  ('voxengo', 'Drumformer', 'drumformer', 'utilities'),
  ('voxengo', 'HarmoniEQ', 'harmonieq', 'eq'),

  -- TAL Software
  ('tal-software', 'TAL-Chorus-LX', 'tal-chorus-lx', 'utilities'),
  ('tal-software', 'TAL-Reverb-4', 'tal-reverb-4', 'reverb-delay'),

  -- GForce Software
  ('gforce-software', 'ImperialGT', 'imperialgt', 'synths'),

  -- Cherry Audio
  ('cherry-audio', 'Eight Voice', 'eight-voice', 'synths'),
  ('cherry-audio', 'Memorymode', 'memorymode', 'synths'),
  ('cherry-audio', 'GX-80', 'gx-80', 'synths'),

  -- Sugar Bytes
  ('sugar-bytes', 'Consequence', 'consequence', 'utilities'),
  ('sugar-bytes', 'Artillery 2', 'artillery-2', 'synths'),

  -- Applied Acoustics Systems
  ('applied-acoustics-systems', 'Objeq Delay', 'objeq-delay', 'reverb-delay'),

  -- Synthogy
  ('synthogy', 'Ivory 3 Italian D', 'ivory-3-italian-d', 'sample-libraries'),

  -- Sonic Academy
  ('sonic-academy', 'Bassline', 'bassline', 'synths'),

  -- Klevgrand
  ('klevgrand', 'Korvpressor', 'korvpressor', 'compression'),
  ('klevgrand', 'Kleverb', 'kleverb', 'reverb-delay'),
  ('klevgrand', 'Scandal', 'scandal', 'channel-strips'),

  -- Goodhertz
  ('goodhertz', 'Panpot', 'panpot', 'utilities'),
  ('goodhertz', 'Good Dither', 'good-dither', 'utilities')
) as p(dev_slug, name, slug, category)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
