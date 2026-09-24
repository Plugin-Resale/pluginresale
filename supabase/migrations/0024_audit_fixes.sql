-- Step 24: catalogue audit, part 1 of 3 (paste 0024, then 0025, then 0026).
-- Audit run on 2026-09-24 against the catalogue as built by migrations 0003-0023
-- (191 developers, 4324 plugins). Every change below was checked against the developer’s
-- own site (product pages, store, EULA, support KB), the source is given on each line.
--
-- This file: the smaller developers added in 0011/0013 and deepened in 0016/0017, plus
-- version and developer-record fixes.
--   - Product names that don’t exist at that developer (fabricated, or another company’s
--     product): deleted, and replaced by real products from the official catalogue where
--     that was the only content of the developer (Aaron Venture, Auddict, Fracture Sounds,
--     Rast Sound, Cinematique Instruments, Denise, Wave Alchemy, Precisionsound...).
--   - Free products (nothing to resell): OTT, Supermassive, TAL-Chorus-LX, IVGI...
--   - Hardware listed as software: Slate ML-1/ML-2 microphones, Positive Grid Spark amp.
--   - Outdated versions renamed to the current one (Altiverb 8, Pianoteq 9, Heat Up 3,
--     Music Production Suite 9, FX Collection 6, SpectraLayers Pro 13...), and old-version
--     duplicates merged into the current product (Pro-Q 3 -> Pro-Q 4...): the version a
--     seller owns goes in the listing’s own "version" field.
--   - Duplicates (same product under two slugs), wrong categories, developer records
--     (missing/unofficial policy source, last_verified on unverified policies).
--
-- Idempotent: renames/merges only act while the old slug still exists, inserts use
-- on conflict do nothing, and a product is never deleted if a listing points at it
-- (listings of a merged duplicate are moved to the kept product first).


-- Wrong name or outdated version -> official current name (49)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('sample-logic', 'cinematic-guitars', 'Cinematic Guitars ULTRA', 'cinematic-guitars-ultra', null::text), -- https://www.samplelogic.com/products/
  ('wusik', 'wusikstation', 'Wusik Station', 'wusik-station', null::text), -- https://www.kvraudio.com/product/wusik-station-by-wusik
  ('black-rooster-audio', 'vla-2a', 'VLA-2A Mark II', 'vla-2a-mark-ii', null::text), -- https://blackroosteraudio.com/en/products
  ('kush-audio', 'clariphonic-dsp', 'Clariphonic Mk3', 'clariphonic-mk3', null::text), -- https://thehouseofkush.com
  ('kush-audio', 'electra', 'Electra DSP', 'electra-dsp', null::text), -- https://thehouseofkush.com
  ('initial-audio', 'heat-up-2', 'Heat Up 3', 'heat-up-3', 'synths'::text), -- https://initialaudio.com
  ('mercuriall-audio', 'u530', 'Tube Amp U530', 'tube-amp-u530', null::text), -- http://mercuriall.com/cms/
  ('two-notes', 'wall-of-sound', 'Genome', 'genome', null::text), -- https://www.two-notes.com/en/torpedo-series/torpedo-wall-of-sound/
  ('audiothing', 'valve', 'Valves', 'valves', null::text), -- https://www.audiothing.net/plugins/
  ('audiothing', 'outer-space', 'Outer Space 2', 'outer-space-2', null::text), -- https://www.audiothing.net/plugins/
  ('metric-halo', 'channelstrip-3', 'ChannelStrip v4', 'channelstrip-v4', null::text), -- https://mhsecure.com/metric_halo
  ('metric-halo', 'multiband', 'Multiband Dynamics v4', 'multiband-dynamics-v4', null::text), -- https://mhsecure.com/metric_halo
  ('metric-halo', 'production-bundle', 'MH Production Bundle v4', 'mh-production-bundle-v4', null::text), -- https://mhsecure.com/metric_halo
  ('audio-damage', 'kombinat-xl', 'Kombinat4', 'kombinat4', 'saturation'::text), -- https://www.audiodamage.com/collections/all
  ('audio-damage', 'discord-4', 'Discord4', 'discord4', null::text), -- https://www.audiodamage.com/collections/all
  ('tone2', 'icarus-2', 'Icarus 3', 'icarus-3', null::text), -- https://www.tone2.com
  ('vengeance-sound', 'vps-avenger', 'VPS Avenger 2', 'vps-avenger-2', null::text), -- https://www.vengeance-sound.com
  ('synapse-audio', 'antidote-2', 'Antidote RE', 'antidote-re', 'synths'::text), -- https://www.synapse-audio.com/products.html
  ('kuassa', 'cerberus-bass-amp', 'Cerberus Bass Amplifikation', 'cerberus-bass-amplifikation', null::text), -- https://www.kuassa.com/products/
  ('kuassa', 'creme', 'Amplifikation Creme', 'amplifikation-creme', 'guitar-amps'::text), -- https://www.kuassa.com/products/
  ('hofa', 'iq-eq', 'IQ-Series EQ V3', 'iq-series-eq-v3', null::text), -- http://hofa-plugins.de/en/
  ('hofa', 'iq-limiter', 'IQ-Series Limiter V2', 'iq-series-limiter-v2', null::text), -- http://hofa-plugins.de/en/
  ('audio-ease', 'altiverb-7-xl', 'Altiverb 8 XL', 'altiverb-8-xl', null::text), -- https://audioease.com/
  ('audio-ease', 'altiverb-7-regular', 'Altiverb 8 Regular', 'altiverb-8-regular', null::text), -- https://audioease.com/
  ('audio-ease', 'speakerphone-2', 'Speakerphone 3', 'speakerphone-3', null::text), -- https://audioease.com/
  ('audio-ease', 'cabinet-suite', 'Cabinet', 'cabinet', null::text), -- https://www.kvraudio.com/news/audio_ease_releases_cabinet_11872 (discontinued per audioease.com)
  ('rob-papen', 'quadrant', 'Quad', 'quad', null::text), -- https://www.robpapen.com/Quad-vst.html
  ('projectsam', 'symphobia-3', 'Symphobia 3: Lumina', 'symphobia-3-lumina', null::text), -- https://projectsam.com/libraries/
  ('tokyo-dawn-records', 'molotok', 'Molot GE', 'molot-ge', null::text), -- https://www.tokyodawn.net/tokyo-dawn-labs/ (TDR Molotok is the free edition)
  ('neural-dsp', 'archetype-abasi-x', 'Archetype: Abasi', 'archetype-abasi', null::text), -- https://neuraldsp.com/plugins/archetype-abasi
  ('soundiron', 'olympus-elements', 'Olympus Choir Elements', 'olympus-choir-elements', null::text), -- https://soundiron.com/collections/kontakt-player-edition-collection
  ('ample-sound', 'ample-guitar-m-iii', 'Ample Guitar M', 'ample-guitar-m', null::text), -- https://www.amplesound.net/en/index.asp
  ('ample-sound', 'ample-bass-p-iii', 'Ample Bass P', 'ample-bass-p', null::text), -- https://www.amplesound.net/en/index.asp
  ('ample-sound', 'agt-guitar-taylor', 'Ample Guitar T', 'ample-guitar-t', null::text), -- https://www.amplesound.net/en/index.asp
  ('orange-tree-samples', 'evolution-steel-string', 'Evolution Steel Strings', 'evolution-steel-strings', null::text), -- https://www.orangetreesamples.com/products/evolution-acoustic-guitar-steel-strings
  ('sample-modeling', 'samplemodeling-brass-bundle', 'Brass Bundle v3', 'brass-bundle-v3', 'bundles'::text), -- https://www.samplemodeling.com/
  ('sample-modeling', 'the-horn', 'French Horn & Tuba v3', 'french-horn-tuba-v3', null::text), -- https://www.samplemodeling.com/
  ('musical-sampling', 'atelier-series-amy', 'Amy', 'amy', null::text), -- https://musicalsampling.com/
  ('u-he', 'zebra2', 'Zebra Legacy', 'zebra-legacy', null::text), -- https://u-he.com/products/ (Zebra2 is now sold as Zebra Legacy)
  ('u-he', 'uhbik', 'Uhbik 2', 'uhbik-2', null::text), -- https://u-he.com/products/
  ('rob-papen', 'raw', 'RAW-2', 'raw-2', null::text), -- https://www.robpapen.com/
  ('dmg-audio', 'trackcomp', 'TrackComp 2', 'trackcomp-2', null::text), -- https://dmgaudio.com/products.php
  ('izotope', 'music-production-suite-7', 'Music Production Suite 9', 'music-production-suite-9', null::text), -- https://www.izotope.com/en/products.html
  ('arturia', 'fx-collection-5', 'FX Collection 6 Pro', 'fx-collection-6-pro', null::text), -- https://www.arturia.com/products
  ('modartt', 'pianoteq-8-pro', 'Pianoteq 9 PRO', 'pianoteq-9-pro', null::text), -- https://www.modartt.com/pianoteq_overview
  ('modartt', 'pianoteq-8-standard', 'Pianoteq 9 Standard', 'pianoteq-9-standard', null::text), -- https://www.modartt.com/pianoteq_overview
  ('modartt', 'pianoteq-8-stage', 'Pianoteq 9 Stage', 'pianoteq-9-stage', null::text), -- https://www.modartt.com/pianoteq_overview
  ('kazrog', 'kclip-4', 'KClip 3', 'kclip-3', null::text), -- https://kazrog.com/ (KClip 4 does not exist)
  ('steinberg', 'spectralayers-pro-11', 'SpectraLayers Pro 13', 'spectralayers-pro-13', null::text) -- https://www.steinberg.net/spectralayers/new-features/ ("What is new in SpectraLayers 13")
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Duplicates / old versions merged into the kept product (28)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('kuassa', 'amplifikation-cerberus', 'kuassa', 'cerberus-bass-amplifikation'), -- https://www.kuassa.com/products/
  ('audio-ease', 'altiverb-7', 'audio-ease', 'altiverb-8-regular'), -- https://audioease.com/
  ('sound-radix', 'surfer-eq-2', 'sound-radix', 'surfereq-2'), -- https://www.soundradix.com/
  ('projectsam', 'lumina', 'projectsam', 'symphobia-3-lumina'), -- https://projectsam.com/libraries/
  ('cinematic-studio-series', 'cs-strings', 'cinematic-studio-series', 'cinematic-studio-strings'), -- https://cinematicstudioseries.com/
  ('cinematic-studio-series', 'cs-brass', 'cinematic-studio-series', 'cinematic-studio-brass'), -- https://cinematicstudioseries.com/
  ('cinematic-studio-series', 'cs-piano', 'cinematic-studio-series', 'cinematic-studio-piano'), -- https://cinematicstudioseries.com/
  ('cinematic-studio-series', 'cs-woodwinds', 'cinematic-studio-series', 'cinematic-studio-woodwinds'), -- https://cinematicstudioseries.com/
  ('tokyo-dawn-records', 'tdr-limiter-6', 'tokyo-dawn-records', 'limiter-6-ge'), -- https://www.tokyodawn.net/tokyo-dawn-labs/
  ('neural-dsp', 'parallax', 'neural-dsp', 'parallax-x'), -- https://neuraldsp.com/plugins
  ('liquidsonics', 'cinematic-rooms-pro', 'liquidsonics', 'cinematic-rooms-professional'), -- https://www.liquidsonics.com/software/
  ('korg', 'korg-collection', 'korg', 'korg-collection-6'), -- https://www.korg.com/us/products/software/korg_collection/
  ('garritan', 'garritan-personal-orchestra-5', 'garritan', 'personal-orchestra-5'), -- https://www.garritan.com/
  ('soundiron', 'apocalypse-percussion', 'soundiron', 'apocalypse-percussion-ensemble'), -- https://soundiron.com/collections/all
  ('ample-sound', 'abp-bass-precision', 'ample-sound', 'ample-bass-p'), -- https://www.amplesound.net/en/index.asp
  ('strezov-sampling', 'afflatus-strings', 'strezov-sampling', 'afflatus-chapter-i-strings'), -- https://www.strezov-sampling.com/products/
  ('fabfilter', 'pro-q-3', 'fabfilter', 'pro-q-4'), -- https://www.fabfilter.com/products (old version, version goes in the listing)
  ('fabfilter', 'pro-c-2', 'fabfilter', 'pro-c-3'), -- https://www.fabfilter.com/products
  ('rob-papen', 'predator-2', 'rob-papen', 'predator-3'), -- https://www.robpapen.com/
  ('rob-papen', 'subboombass-3', 'rob-papen', 'subboombass-2'), -- https://www.robpapen.com/ (SubBoomBass 3 doesn’t exist, current is SubBoomBass 2)
  ('sonible', 'smart-eq-3', 'sonible', 'smart-eq-4'), -- https://www.sonible.com (old version)
  ('acon-digital', 'restoration-suite-2', 'acon-digital', 'restoration-suite-3'), -- old version
  ('uvi', 'falcon', 'uvi', 'falcon-3'), -- duplicate of Falcon 3
  ('sonuscore', 'the-orchestra-complete', 'sonuscore', 'the-orchestra-complete-3'), -- old version
  ('air-music-technology', 'loom', 'air-music-technology', 'loom-ii'), -- old version
  ('mastering-the-mix', 'expose', 'mastering-the-mix', 'expose-2'), -- old version
  ('eventide', 'physion', 'eventide', 'physion-mk-ii'), -- old version
  ('ik-multimedia', 'modo-drum', 'ik-multimedia', 'modo-drum-2') -- old version
), pairs as (
  select s.id as source_id, t.id as target_id
  from v
  join public.developers sd on sd.slug = v.dev
  join public.plugins s on s.developer_id = sd.id and s.slug = v.slug
  join public.developers td on td.slug = v.target_dev
  join public.plugins t on t.developer_id = td.id and t.slug = v.target_slug
)
update public.listings l set plugin_id = pairs.target_id from pairs where l.plugin_id = pairs.source_id;

delete from public.plugins p
using public.developers d, (values
  ('kuassa', 'amplifikation-cerberus', 'kuassa', 'cerberus-bass-amplifikation'), -- https://www.kuassa.com/products/
  ('audio-ease', 'altiverb-7', 'audio-ease', 'altiverb-8-regular'), -- https://audioease.com/
  ('sound-radix', 'surfer-eq-2', 'sound-radix', 'surfereq-2'), -- https://www.soundradix.com/
  ('projectsam', 'lumina', 'projectsam', 'symphobia-3-lumina'), -- https://projectsam.com/libraries/
  ('cinematic-studio-series', 'cs-strings', 'cinematic-studio-series', 'cinematic-studio-strings'), -- https://cinematicstudioseries.com/
  ('cinematic-studio-series', 'cs-brass', 'cinematic-studio-series', 'cinematic-studio-brass'), -- https://cinematicstudioseries.com/
  ('cinematic-studio-series', 'cs-piano', 'cinematic-studio-series', 'cinematic-studio-piano'), -- https://cinematicstudioseries.com/
  ('cinematic-studio-series', 'cs-woodwinds', 'cinematic-studio-series', 'cinematic-studio-woodwinds'), -- https://cinematicstudioseries.com/
  ('tokyo-dawn-records', 'tdr-limiter-6', 'tokyo-dawn-records', 'limiter-6-ge'), -- https://www.tokyodawn.net/tokyo-dawn-labs/
  ('neural-dsp', 'parallax', 'neural-dsp', 'parallax-x'), -- https://neuraldsp.com/plugins
  ('liquidsonics', 'cinematic-rooms-pro', 'liquidsonics', 'cinematic-rooms-professional'), -- https://www.liquidsonics.com/software/
  ('korg', 'korg-collection', 'korg', 'korg-collection-6'), -- https://www.korg.com/us/products/software/korg_collection/
  ('garritan', 'garritan-personal-orchestra-5', 'garritan', 'personal-orchestra-5'), -- https://www.garritan.com/
  ('soundiron', 'apocalypse-percussion', 'soundiron', 'apocalypse-percussion-ensemble'), -- https://soundiron.com/collections/all
  ('ample-sound', 'abp-bass-precision', 'ample-sound', 'ample-bass-p'), -- https://www.amplesound.net/en/index.asp
  ('strezov-sampling', 'afflatus-strings', 'strezov-sampling', 'afflatus-chapter-i-strings'), -- https://www.strezov-sampling.com/products/
  ('fabfilter', 'pro-q-3', 'fabfilter', 'pro-q-4'), -- https://www.fabfilter.com/products (old version, version goes in the listing)
  ('fabfilter', 'pro-c-2', 'fabfilter', 'pro-c-3'), -- https://www.fabfilter.com/products
  ('rob-papen', 'predator-2', 'rob-papen', 'predator-3'), -- https://www.robpapen.com/
  ('rob-papen', 'subboombass-3', 'rob-papen', 'subboombass-2'), -- https://www.robpapen.com/ (SubBoomBass 3 doesn’t exist, current is SubBoomBass 2)
  ('sonible', 'smart-eq-3', 'sonible', 'smart-eq-4'), -- https://www.sonible.com (old version)
  ('acon-digital', 'restoration-suite-2', 'acon-digital', 'restoration-suite-3'), -- old version
  ('uvi', 'falcon', 'uvi', 'falcon-3'), -- duplicate of Falcon 3
  ('sonuscore', 'the-orchestra-complete', 'sonuscore', 'the-orchestra-complete-3'), -- old version
  ('air-music-technology', 'loom', 'air-music-technology', 'loom-ii'), -- old version
  ('mastering-the-mix', 'expose', 'mastering-the-mix', 'expose-2'), -- old version
  ('eventide', 'physion', 'eventide', 'physion-mk-ii'), -- old version
  ('ik-multimedia', 'modo-drum', 'ik-multimedia', 'modo-drum-2') -- old version
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (107)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('aaron-venture', 'the-elements'), -- not on official site (only Infinite Brass/Woodwinds) | https://www.aaronventure.com
  ('aaron-venture', 'true-keys'), -- https://www.aaronventure.com
  ('aaron-venture', 'hybrid-tools-2'), -- (8dio product) | https://www.aaronventure.com
  ('auddict', 'modern-scoring-strings'), -- (Audiobro product) | https://auddict.com
  ('auddict', 'rock-strings'), -- https://auddict.com
  ('cinematique-instruments', 'fractured'), -- https://cinematique-instruments.com
  ('cinematique-instruments', 'fluid-piano'), -- https://cinematique-instruments.com
  ('cinematique-instruments', 'damage'), -- (Heavyocity product) | https://cinematique-instruments.com
  ('big-fish-audio', 'vintage-instruments'), -- no such product | https://www.bigfishaudio.com
  ('fracture-sounds', 'iceni-viola'), -- https://fracturesounds.com
  ('fracture-sounds', 'vermeer-cello'), -- https://fracturesounds.com
  ('fracture-sounds', 'string-sketches'), -- https://fracturesounds.com
  ('soniccouture', 'tank-3'), -- https://www.soniccouture.com/en/products/
  ('soniccouture', 'attic-grand-piano'), -- https://www.soniccouture.com/en/products/
  ('rast-sound', 'ethnic-voices'), -- https://rastsound.com
  ('rast-sound', 'zeynel'), -- https://rastsound.com
  ('rast-sound', 'anatolian-instruments'), -- https://rastsound.com
  ('zero-g', 'tao'), -- not found | https://zero-g.co.uk
  ('zero-g', 'tribal-spirit'), -- not found | https://zero-g.co.uk
  ('zero-g', 'datafile-series'), -- 1990s sample CD-ROM trilogy, not a plugin license | https://en.wikipedia.org/wiki/Zero-G_Ltd
  ('sample-logic', 'trailer-hits-2'), -- https://www.samplelogic.com/products/
  ('sample-logic', 'rhythmic-impulse'), -- https://www.samplelogic.com/products/
  ('in-session-audio', 'percussive-adventures-2'), -- https://insessionaudio.com
  ('in-session-audio', 'ashen-choir'), -- https://insessionaudio.com
  ('precision-sound', 'hybrid-factory'), -- https://store.precisionsound.net
  ('precision-sound', 'cinematic-series'), -- https://store.precisionsound.net
  ('wave-alchemy', 'space'), -- https://www.wavealchemy.co.uk/effects/
  ('wave-alchemy', 'transform'), -- https://www.wavealchemy.co.uk/effects/
  ('wave-alchemy', 'phatmatik'), -- https://www.wavealchemy.co.uk/effects/
  ('wusik', 'wusik-string-machine'), -- not found
  ('denise-audio', 'bandsaw'), -- https://www.deniseaudio.com/plugins/bad-tape-2
  ('denise-audio', 'sidechain'), -- https://www.deniseaudio.com/plugins/bad-tape-2
  ('denise-audio', 'bloom'), -- (oeksound product) | https://www.deniseaudio.com/plugins/bad-tape-2
  ('nomad-factory', 'magnetic-ii'), -- (real: Magnetics Bundle v3) | https://www.nomadfactory.com
  ('nomad-factory', 'bus-driver'), -- https://www.nomadfactory.com
  ('black-rooster-audio', 'ariva-n'), -- https://blackroosteraudio.com/en/products
  ('kush-audio', 'ubk-fatso-jr'), -- (Fatso Jr is Empirical Labs/UAD, Kush sells UBK-2) | https://thehouseofkush.com
  ('ddmf', 'nyq'), -- https://ddmf.eu
  ('initial-audio', 'poly-verse'), -- https://initialaudio.com
  ('initial-audio', 'dirty-tape'), -- https://initialaudio.com
  ('wa-production', 'abl3'), -- (AudioRealism product) | https://audiorealism.se/products/audiorealism-bass-line-3
  ('wa-production', 'imagewide'), -- not found | https://www.waproduction.com/plugins
  ('sonimus', 'british-channel'), -- (real: Satson CS) | https://sonimus.com/products?product_view=list
  ('nembrini-audio', 'british-lead'), -- https://www.nembriniaudio.com/collections/all
  ('nembrini-audio', 'fireclaw'), -- https://www.nembriniaudio.com/collections/all
  ('nembrini-audio', 'mercury-tube-preamp'), -- https://www.nembriniaudio.com/collections/all
  ('mercuriall-audio', 'spinaltap'), -- http://mercuriall.com/cms/
  ('audio-assault', 'amplifikation'), -- (Kuassa product line) | https://audioassault.mx
  ('audio-assault', 'cab-devil'), -- https://audioassault.mx
  ('two-notes', 'torpedo-remote'), -- free control software for Two Notes hardware, not a sellable license | https://www.two-notes.com/en/downloads/
  ('two-notes', 'gojira-suite'), -- (Gojira = Neural DSP Archetype) | https://www.two-notes.com
  ('klevgrand', 'chubby-tubes'), -- https://klevgrand.com/products
  ('klevgrand', 'scandal'), -- https://klevgrand.com/products
  ('auburn-sounds', 'spaceship'), -- https://www.auburnsounds.com
  ('wavesfactory', 'spring-reverb'), -- https://www.wavesfactory.com/audio-plugins/
  ('wavesfactory', 'trombone'), -- https://www.wavesfactory.com/audio-plugins/
  ('audiothing', 'bassment'), -- https://www.audiothing.net/plugins/
  ('audio-damage', 'fluid'), -- https://www.audiodamage.com/collections/all
  ('tone2', 'firebird-2'), -- not listed (discontinued) | https://www.tone2.com
  ('vengeance-sound', 'vps-multiband-distortion-2'), -- https://www.vengeance-sound.com
  ('overloud', 'gem'), -- product line, not a product | https://www.overloud.com/products
  ('overloud', 'bass-collection'), -- https://www.overloud.com/products
  ('positive-grid', 'spark'), -- hardware amplifier, not a software license | https://www.positivegrid.com/
  ('sound-radix', 'dirty-tricks'), -- not a Sound Radix product | https://www.soundradix.com/
  ('projectsam', 'forzo'), -- (Heavyocity product, already listed there) | https://heavyocity.com/products/forzo
  ('projectsam', 'animato'), -- not a ProjectSAM library | https://projectsam.com/libraries/
  ('heavyocity', 'aeon'), -- https://heavyocity.com/products/
  ('tokyo-dawn-records', 'tdr-nova'), -- free version (cannot be resold), paid Nova GE already listed | https://www.tokyodawn.net/tokyo-dawn-labs/
  ('tokyo-dawn-records', 'tdr-kotelnikov'), -- free version, Kotelnikov GE already listed | https://www.tokyodawn.net/tokyo-dawn-labs/
  ('tokyo-dawn-records', 'tdr-vos-slickeq'), -- free version, SlickEQ GE already listed | https://www.tokyodawn.net/tokyo-dawn-labs/
  ('ujam', 'virtual-guitarist'), -- product family, only sold as editions (IRON 2 etc.) | https://www.ujam.com/
  ('ujam', 'virtual-bassist'), -- product family, only sold as editions | https://www.ujam.com/
  ('ujam', 'virtual-drummer'), -- product family, only sold as editions | https://www.ujam.com/
  ('ujam', 'usynth-rise'), -- no such Usynth edition | https://www.ujam.com/
  ('garritan', 'jazz-and-big-band-4'), -- current version is Jazz & Big Band 3 | https://www.garritan.com/
  ('impact-soundworks', 'shreddage-3'), -- not a product, sold as Shreddage 3 Stratus/Hydra/Argent/Darkwall | https://impactsoundworks.com/products/
  ('getgood-drums', 'elevate-drums'), -- https://ggd.co/collections/all
  ('sonic-academy', 'bassline'), -- not a Sonic Academy product | https://www.sonicacademy.com/products
  ('polyverse-music', 'wider'), -- free plugin, nothing to resell | https://polyversemusic.com/products/wider/
  ('ample-sound', 'agf-guitar-fingerstyle'), -- no such product | https://www.amplesound.net/en/index.asp
  ('orange-tree-samples', 'world-guitarist'), -- https://www.orangetreesamples.com
  ('sample-modeling', 'the-saxes'), -- https://www.samplemodeling.com/
  ('musical-sampling', 'boutique-drums-ruby'), -- https://musicalsampling.com/
  ('realitone', 'realistrings'), -- not a Realitone product | https://realitone.com
  ('tal-software', 'tal-chorus-lx'), -- free plugin | https://tal-software.com/products
  ('tal-software', 'tal-reverb-4'), -- free plugin | https://tal-software.com/products
  ('u-he', 'protoverb'), -- free plugin | https://u-he.com/products/
  ('valhalla-dsp', 'supermassive'), -- free plugin | https://valhalladsp.com/demos-downloads/
  ('valhalla-dsp', 'space-modulator'), -- free plugin | https://valhalladsp.com/shop/modulation/valhalla-space-modulator/
  ('valhalla-dsp', 'vintagevibe'), -- no such product (VintageVerb already listed) | https://valhalladsp.com/shop/reverb/valhalla-vintage-verb/
  ('xfer-records', 'ott'), -- free plugin | https://xferrecords.com/freeware
  ('xfer-records', 'dimension-expander'), -- free plugin | https://xferrecords.com/freeware
  ('kilohearts', 'snap-heap'), -- now free | https://kilohearts.com/products/snap_heap
  ('kilohearts', 'vinyl'), -- not a Kilohearts paid product | https://kilohearts.com/shop
  ('kilohearts', 'vocode'), -- not a Kilohearts paid product | https://kilohearts.com/shop
  ('dmg-audio', 'trackcontrol'), -- free plugin | https://dmgaudio.com/products.php
  ('dmg-audio', 'nyquistx'), -- not a DMG product | https://dmgaudio.com/products.php
  ('dmg-audio', 'chorum'), -- not a DMG product | https://dmgaudio.com/products.php
  ('dmg-audio', 'stereotools'), -- not a DMG product | https://dmgaudio.com/products.php
  ('slate-digital', 'ml-1'), -- hardware microphone (VMS) | https://slatedigital.com/virtual-microphone-system/
  ('slate-digital', 'ml-2'), -- hardware microphone (VMS) | https://slatedigital.com/virtual-microphone-system/
  ('klanghelm', 'ivgi'), -- free plugin | https://klanghelm.com/contents/products/IVGI
  ('celemony', 'melodyne-capture'), -- no such product | https://www.celemony.com/en/melodyne/what-is-melodyne
  ('kiive-audio', 'warmy-ep1a-tube-eq'), -- free plugin | https://www.kiiveaudio.com/products/warmy-ep1a-v2
  ('kiive-audio', 'v3-tape-machine'), -- not a Kiive product | https://www.kiiveaudio.com/collections/all-plugins
  ('d16-group', 'frontier'), -- free plugin | https://d16.pl/frontier
  ('gforce-software', 'imperialgt') -- no such GForce product | https://www.kvraudio.com/developer/gforce-software
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Category fixes (2)
update public.plugins p set category = v.category
from public.developers d, (values
  ('softube', 'volume-4', 'bundles'), -- plugin bundle, not a mastering tool | https://musictech.com/news/softube-volume-4-plug-in-collection/
  ('fuse-audio-labs', 'vpre-562a', 'saturation') -- vintage tube amplifier emulation, not an EQ | https://www.kvraudio.com/product/vpre-562a-vintage-tube-amplifier-by-fuse-audio-labs
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Real products from the official catalogue, replacing fabricated ones (51)
insert into public.plugins (developer_id, name, slug, category)
select d.id, v.name, v.slug, v.category
from (values
  ('aaron-venture', 'Infinite Brass', 'infinite-brass', 'sample-libraries'), -- https://www.aaronventure.com
  ('aaron-venture', 'Infinite Woodwinds', 'infinite-woodwinds', 'sample-libraries'), -- https://www.aaronventure.com
  ('auddict', 'Rampage Electric Cello', 'rampage-electric-cello', 'sample-libraries'), -- https://auddict.com
  ('auddict', 'Drums of the Deep III', 'drums-of-the-deep-iii', 'sample-libraries'), -- https://auddict.com
  ('auddict', 'Virtuoso Cello', 'virtuoso-cello', 'sample-libraries'), -- https://auddict.com
  ('auddict', 'Prestige Violin', 'prestige-violin', 'sample-libraries'), -- https://auddict.com
  ('cinematique-instruments', 'Deconstructed Piano', 'deconstructed-piano', 'sample-libraries'), -- https://cinematique-instruments.com/pages_instr/inst_decon_piano.php
  ('cinematique-instruments', 'Stringed', 'stringed', 'sample-libraries'), -- https://cinematique-instruments.com
  ('cinematique-instruments', 'Mosaic', 'mosaic', 'sample-libraries'), -- https://cinematique-instruments.com
  ('fracture-sounds', 'Soft String Soloists', 'soft-string-soloists', 'sample-libraries'), -- https://fracturesounds.com/product/soft-string-soloists/
  ('fracture-sounds', 'Solo String Formations', 'solo-string-formations', 'sample-libraries'), -- https://fracturesounds.com/product/solo-string-formations/
  ('fracture-sounds', 'Trails', 'trails', 'sample-libraries'), -- https://fracturesounds.com/product/trails/
  ('fracture-sounds', 'Zen', 'zen', 'sample-libraries'), -- https://fracturesounds.com/product/zen/
  ('soniccouture', 'The Attic 3', 'the-attic-3', 'sample-libraries'), -- https://www.soniccouture.com/en/products/34-new/g47-the-attic-3/
  ('rast-sound', 'Anatolian Percussion V2', 'anatolian-percussion-v2', 'sample-libraries'), -- https://rastsound.com/downloads/anatolian-percussion/
  ('sample-logic', 'Trailer Xpressions IV', 'trailer-xpressions-iv', 'sample-libraries'), -- https://www.samplelogic.com/products/
  ('sample-logic', 'Morphestra ULTRA', 'morphestra-ultra', 'sample-libraries'), -- https://www.samplelogic.com/products/
  ('in-session-audio', 'Taiko Creator', 'taiko-creator', 'sample-libraries'), -- https://insessionaudio.com
  ('in-session-audio', 'Riff Generation', 'riff-generation', 'sample-libraries'), -- https://insessionaudio.com
  ('in-session-audio', 'Shimmer Shake Strike 2', 'shimmer-shake-strike-2', 'sample-libraries'), -- https://insessionaudio.com
  ('precision-sound', 'Bergman Klavitron', 'bergman-klavitron', 'sample-libraries'), -- https://store.precisionsound.net
  ('precision-sound', 'Knutby Church Organ', 'knutby-church-organ', 'sample-libraries'), -- https://store.precisionsound.net
  ('wave-alchemy', 'Triaz', 'triaz', 'sample-libraries'), -- https://www.wavealchemy.co.uk/effects/
  ('wave-alchemy', 'Tapewave', 'tapewave', 'saturation'), -- https://www.wavealchemy.co.uk/effects/
  ('wave-alchemy', 'Radiance', 'radiance', 'reverb-delay'), -- https://www.wavealchemy.co.uk/effects/
  ('wave-alchemy', 'Magic7', 'magic7', 'reverb-delay'), -- https://www.wavealchemy.co.uk/effects/
  ('denise-audio', 'Perfect Room 2', 'perfect-room-2', 'reverb-delay'), -- https://www.deniseaudio.com/plugins/bad-tape-2
  ('denise-audio', 'Bad Tape 2', 'bad-tape-2', 'saturation'), -- https://www.deniseaudio.com/plugins/bad-tape-2
  ('denise-audio', 'Motion Filter', 'motion-filter', 'utilities'), -- https://www.deniseaudio.com/plugins/bad-tape-2
  ('nomad-factory', 'Magnetics Bundle v3', 'magnetics-bundle-v3', 'bundles'), -- https://www.nomadfactory.com
  ('nomad-factory', 'Pulse-Tec EQs v2', 'pulse-tec-eqs-v2', 'eq'), -- https://www.nomadfactory.com
  ('black-rooster-audio', 'VLA-FET', 'vla-fet', 'compression'), -- https://blackroosteraudio.com/en/products
  ('initial-audio', 'Sektor', 'sektor', 'synths'), -- https://initialaudio.com
  ('wa-production', 'DYNAWIDE', 'dynawide', 'utilities'), -- https://www.waproduction.com/plugins/view/dynawide
  ('sonimus', 'Satson CS', 'satson-cs', 'channel-strips'), -- https://sonimus.com/products/satsoncs
  ('nembrini-audio', 'BST100 V2 Super Overdrive Guitar Amplifier', 'bst100-v2-super-overdrive-guitar-amplifier', 'guitar-amps'), -- https://www.nembriniaudio.com/collections/all
  ('nembrini-audio', 'Cali Dual Three Channels Guitar Amplifier', 'cali-dual-three-channels-guitar-amplifier', 'guitar-amps'), -- https://www.nembriniaudio.com/collections/all
  ('nembrini-audio', '8180 Monster Tube Guitar Amplifier', '8180-monster-tube-guitar-amplifier', 'guitar-amps'), -- https://www.nembriniaudio.com/collections/all
  ('mercuriall-audio', 'Mercuriall Ampbox', 'ampbox', 'guitar-amps'), -- http://mercuriall.com/cms/
  ('audio-assault', 'Amp Locker', 'amp-locker', 'guitar-amps'), -- https://audioassault.mx
  ('audio-assault', 'Berserk', 'berserk', 'guitar-amps'), -- https://audioassault.mx
  ('auburn-sounds', 'Graillon', 'graillon', 'utilities'), -- https://www.auburnsounds.com
  ('wavesfactory', 'Trackspacer', 'trackspacer', 'utilities'), -- https://www.wavesfactory.com/audio-plugins/
  ('wavesfactory', 'Spectre', 'spectre', 'saturation'), -- https://www.wavesfactory.com/audio-plugins/
  ('wavesfactory', 'Echo Cat', 'echo-cat', 'reverb-delay'), -- https://www.wavesfactory.com/audio-plugins/
  ('positive-grid', 'BIAS X', 'bias-x', 'guitar-amps'), -- https://www.positivegrid.com/
  ('projectsam', 'Symphobia 4: Pandora', 'symphobia-4-pandora', 'sample-libraries'), -- https://projectsam.com/libraries/
  ('projectsam', 'Lineage Strings', 'lineage-strings', 'sample-libraries'), -- https://projectsam.com/libraries/
  ('projectsam', 'Swing More!', 'swing-more', 'sample-libraries'), -- https://projectsam.com/libraries/
  ('getgood-drums', 'Modern & Massive 2', 'modern-massive-2', 'sample-libraries'), -- https://ggd.co/products/modern-and-massive-2
  ('u-he', 'Zebra 3', 'zebra-3', 'synths') -- https://u-he.com/products/
) as v(dev, name, slug, category)
join public.developers d on d.slug = v.dev
on conflict (developer_id, slug) do nothing;

-- Developer records ---------------------------------------------------------

-- Adobe: "not transferable" had no source. Adobe General Terms, section 18.4 (Non-Assignment):
-- rights under the Terms can’t be transferred without Adobe’s written consent.
update public.developers set source_url = 'https://www.adobe.com/legal/terms.html'
where slug = 'adobe' and source_url is null;

-- Audio Modeling: the policy was sourced from a reseller FAQ (ilio.com). The official EULA says
-- transfer is allowed only for licenses authorized online, on request to Audio Modeling
-- support, and never for NFR licenses. It states no fee or delay, so those are cleared.
update public.developers set
  source_url = 'https://support.audiomodeling.com/guides/Audio_Modeling-EULA_SWAM_products-v1.pdf',
  fee = null, no_fee = false, typical_delay = null,
  restrictions = 'Only licenses authorized online can be transferred, on request to Audio Modeling support. NFR licenses can''t be transferred. Renting or lending the software is forbidden.',
  last_verified = '2026-09-24'
where slug = 'audio-modeling';

-- Exponential Audio’s own domain no longer resolves, the products are now sold by iZotope.
update public.developers set website = 'https://www.izotope.com'
where slug = 'exponential-audio' and website = 'https://www.exponentialaudio.com';

-- Project rule: an unverified policy (transferable = null) carries no last_verified date.
update public.developers set last_verified = null
where transferable is null and last_verified is not null;

