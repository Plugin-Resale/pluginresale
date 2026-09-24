-- Step 24: catalogue audit, part 3 of 3 (run after 0025).
-- Native Instruments, checked product by product against the official NI store
-- (native-instruments.com, which gives each product’s publisher, price and type).
-- About 600 of the ~1,090 "Native Instruments" products imported from the NI sitemap in
-- 0022 are sold on the NI store but published by other companies (Heavyocity, Orchestral
-- Tools, ProjectSAM, Soniccouture, iZotope, u-he, Strezov, Sonokinetic...). Their transfer
-- rules are the publisher’s, not NI’s, so:
--   - publisher already in the catalogue and product already listed there -> merged,
--   - publisher already in the catalogue, product not listed yet -> moved to that publisher
--     under its official name,
--   - publisher not in the catalogue -> removed (they can be re-added under their own
--     developer page once its transfer policy is checked).
-- Also removed: NI hardware and accessories (Komplete Kontrol keyboards, Maschine,
-- Traktor controllers, audio interfaces, cables, cases), free products (Kontakt Player,
-- Reaktor Player, Komplete Start, free expansions...), an upgrade SKU, version duplicates
-- merged (Kontakt -> Kontakt 8, Komplete Standard -> Komplete 26 Standard...), names and
-- categories aligned with the store (e.g. Session Guitarist instruments were "guitar-amps").
-- Idempotent, same rules as 0024.


-- Duplicates / old versions merged into the kept product (23)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('native-instruments', 'solid-bus-comp', 'native-instruments', 'solid-mix-series'), -- not sold on its own: only available inside Solid Mix Series | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'solid-dynamics', 'native-instruments', 'solid-mix-series'), -- not sold on its own: only available inside Solid Mix Series | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'solid-eq', 'native-instruments', 'solid-mix-series'), -- not sold on its own: only available inside Solid Mix Series | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'vc-2a', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'vc-76', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'vc-160', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'vari-comp', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'rc-24', 'native-instruments', 'reverb-classics'), -- not sold on its own: only available inside Reverb Classics | https://www.native-instruments.com/products/reverb-classics
  ('native-instruments', 'rc-48', 'native-instruments', 'reverb-classics'), -- not sold on its own: only available inside Reverb Classics | https://www.native-instruments.com/products/reverb-classics
  ('native-instruments', 'phasis', 'native-instruments', 'effects-series-mod-pack'), -- not sold on its own: only available inside Effects Series Mod Pack | https://www.native-instruments.com/products/effects-series-mod-pack
  ('native-instruments', 'jam-bass', 'native-instruments', 'session-bassist-jam-bass'), -- duplicate of Session Bassist Jam Bass | https://www.native-instruments.com/products/session-bassist-jam-bass
  ('native-instruments', 'electric-neon-essential', 'native-instruments', 'session-guitarist-electric-neon-essentials'), -- duplicate of Session Guitarist Electric Neon Essentials | https://www.native-instruments.com/products/session-guitarist-electric-neon-essentials
  ('native-instruments', 'electric-ruby', 'native-instruments', 'session-guitarist-electric-ruby-deluxe'), -- duplicate of Session Guitarist Electric Ruby Deluxe | https://www.native-instruments.com/products/session-guitarist-electric-ruby-deluxe
  ('native-instruments', 'electric-storm', 'native-instruments', 'session-guitarist-electric-storm-deluxe'), -- duplicate of Session Guitarist Electric Storm Deluxe | https://www.native-instruments.com/products/session-guitarist-electric-storm-deluxe
  ('native-instruments', 'absynth', 'native-instruments', 'absynth-6'), -- duplicate of Absynth 6 | https://www.native-instruments.com/products/absynth
  ('native-instruments', 'battery', 'native-instruments', 'battery-4'), -- duplicate of Battery 4 | https://www.native-instruments.com/products/battery
  ('native-instruments', 'guitar-rig-pro', 'native-instruments', 'guitar-rig-7-pro'), -- duplicate of Guitar Rig 7 Pro | https://www.native-instruments.com/products/guitar-rig-pro
  ('native-instruments', 'komplete-collectors-edition', 'native-instruments', 'komplete-26-collectors-edition'), -- duplicate of Komplete 26 Collector’s Edition | https://www.native-instruments.com/products/komplete-collectors-edition
  ('native-instruments', 'komplete-standard', 'native-instruments', 'komplete-26-standard'), -- duplicate of Komplete 26 Standard | https://www.native-instruments.com/products/komplete-standard
  ('native-instruments', 'komplete-ultimate', 'native-instruments', 'komplete-26-ultimate'), -- duplicate of Komplete 26 Ultimate | https://www.native-instruments.com/products/komplete-ultimate
  ('native-instruments', 'kontakt', 'native-instruments', 'kontakt-8'), -- duplicate of Kontakt 8 | https://www.native-instruments.com/products/kontakt
  ('native-instruments', 'reaktor', 'native-instruments', 'reaktor-6'), -- duplicate of Reaktor 6 | https://www.native-instruments.com/products/reaktor
  ('native-instruments', 'traktor-pro', 'native-instruments', 'traktor-pro-4') -- duplicate of Traktor Pro 4 | https://www.native-instruments.com/products/traktor-pro
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
  ('native-instruments', 'solid-bus-comp', 'native-instruments', 'solid-mix-series'), -- not sold on its own: only available inside Solid Mix Series | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'solid-dynamics', 'native-instruments', 'solid-mix-series'), -- not sold on its own: only available inside Solid Mix Series | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'solid-eq', 'native-instruments', 'solid-mix-series'), -- not sold on its own: only available inside Solid Mix Series | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'vc-2a', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'vc-76', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'vc-160', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'vari-comp', 'native-instruments', 'vintage-compressors'), -- not sold on its own: only available inside Vintage Compressors | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'rc-24', 'native-instruments', 'reverb-classics'), -- not sold on its own: only available inside Reverb Classics | https://www.native-instruments.com/products/reverb-classics
  ('native-instruments', 'rc-48', 'native-instruments', 'reverb-classics'), -- not sold on its own: only available inside Reverb Classics | https://www.native-instruments.com/products/reverb-classics
  ('native-instruments', 'phasis', 'native-instruments', 'effects-series-mod-pack'), -- not sold on its own: only available inside Effects Series Mod Pack | https://www.native-instruments.com/products/effects-series-mod-pack
  ('native-instruments', 'jam-bass', 'native-instruments', 'session-bassist-jam-bass'), -- duplicate of Session Bassist Jam Bass | https://www.native-instruments.com/products/session-bassist-jam-bass
  ('native-instruments', 'electric-neon-essential', 'native-instruments', 'session-guitarist-electric-neon-essentials'), -- duplicate of Session Guitarist Electric Neon Essentials | https://www.native-instruments.com/products/session-guitarist-electric-neon-essentials
  ('native-instruments', 'electric-ruby', 'native-instruments', 'session-guitarist-electric-ruby-deluxe'), -- duplicate of Session Guitarist Electric Ruby Deluxe | https://www.native-instruments.com/products/session-guitarist-electric-ruby-deluxe
  ('native-instruments', 'electric-storm', 'native-instruments', 'session-guitarist-electric-storm-deluxe'), -- duplicate of Session Guitarist Electric Storm Deluxe | https://www.native-instruments.com/products/session-guitarist-electric-storm-deluxe
  ('native-instruments', 'absynth', 'native-instruments', 'absynth-6'), -- duplicate of Absynth 6 | https://www.native-instruments.com/products/absynth
  ('native-instruments', 'battery', 'native-instruments', 'battery-4'), -- duplicate of Battery 4 | https://www.native-instruments.com/products/battery
  ('native-instruments', 'guitar-rig-pro', 'native-instruments', 'guitar-rig-7-pro'), -- duplicate of Guitar Rig 7 Pro | https://www.native-instruments.com/products/guitar-rig-pro
  ('native-instruments', 'komplete-collectors-edition', 'native-instruments', 'komplete-26-collectors-edition'), -- duplicate of Komplete 26 Collector’s Edition | https://www.native-instruments.com/products/komplete-collectors-edition
  ('native-instruments', 'komplete-standard', 'native-instruments', 'komplete-26-standard'), -- duplicate of Komplete 26 Standard | https://www.native-instruments.com/products/komplete-standard
  ('native-instruments', 'komplete-ultimate', 'native-instruments', 'komplete-26-ultimate'), -- duplicate of Komplete 26 Ultimate | https://www.native-instruments.com/products/komplete-ultimate
  ('native-instruments', 'kontakt', 'native-instruments', 'kontakt-8'), -- duplicate of Kontakt 8 | https://www.native-instruments.com/products/kontakt
  ('native-instruments', 'reaktor', 'native-instruments', 'reaktor-6'), -- duplicate of Reaktor 6 | https://www.native-instruments.com/products/reaktor
  ('native-instruments', 'traktor-pro', 'native-instruments', 'traktor-pro-4') -- duplicate of Traktor Pro 4 | https://www.native-instruments.com/products/traktor-pro
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Free products (nothing to resell) (24)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('native-instruments', 'acoustic-drums'), -- free product, nothing to resell | https://www.native-instruments.com/products/acoustic-drums
  ('native-instruments', 'analog-dreams'), -- free product, nothing to resell | https://www.native-instruments.com/products/analog-dreams
  ('native-instruments', 'bass-music-essentials'), -- free product, nothing to resell | https://www.native-instruments.com/products/bass-music-essentials
  ('native-instruments', 'community-drive-2020'), -- free product, nothing to resell | https://www.native-instruments.com/products/community-drive-2020
  ('native-instruments', 'community-drive-2021'), -- free product, nothing to resell | https://www.native-instruments.com/products/community-drive-2021
  ('native-instruments', 'creative-chords'), -- free product, nothing to resell | https://www.native-instruments.com/products/creative-chords
  ('native-instruments', 'ethereal-earth'), -- free product, nothing to resell | https://www.native-instruments.com/products/ethereal-earth
  ('native-instruments', 'guitar-rig-player'), -- free product, nothing to resell | https://www.native-instruments.com/products/guitar-rig-player
  ('native-instruments', 'hypha'), -- free product, nothing to resell | https://www.native-instruments.com/products/hypha
  ('native-instruments', 'irish-harp'), -- free product, nothing to resell | https://www.native-instruments.com/products/irish-harp
  ('native-instruments', 'jacob-collier-audience-choir'), -- free product, nothing to resell | https://www.native-instruments.com/products/jacob-collier-audience-choir
  ('native-instruments', 'komplete-kontrol'), -- free product, nothing to resell | https://www.native-instruments.com/products/komplete-kontrol
  ('native-instruments', 'komplete-start'), -- free product, nothing to resell | https://www.native-instruments.com/products/komplete-start
  ('native-instruments', 'kontakt-player'), -- free product, nothing to resell | https://www.native-instruments.com/products/kontakt-player
  ('native-instruments', 'massive-x-player'), -- free product, nothing to resell | https://www.native-instruments.com/products/massive-x-player
  ('native-instruments', 'ozone-eq'), -- free product, nothing to resell | https://www.native-instruments.com/products/ozone-eq
  ('native-instruments', 'ozone-imager'), -- free product, nothing to resell | https://www.native-instruments.com/products/ozone-imager
  ('native-instruments', 'raum'), -- free product, nothing to resell | https://www.native-instruments.com/products/raum
  ('native-instruments', 'reaktor-player'), -- free product, nothing to resell | https://www.native-instruments.com/products/reaktor-player
  ('native-instruments', 'replika'), -- free product, nothing to resell | https://www.native-instruments.com/products/replika
  ('native-instruments', 'supercharger'), -- free product, nothing to resell | https://www.native-instruments.com/products/supercharger
  ('native-instruments', 'trash-lite'), -- free product, nothing to resell | https://www.native-instruments.com/products/trash-lite
  ('native-instruments', 'vinyl'), -- free product, nothing to resell | https://www.native-instruments.com/products/vinyl
  ('native-instruments', 'yangqin') -- free product, nothing to resell | https://www.native-instruments.com/products/yangqin
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Hardware, accessories and upgrade SKUs (not software licences) (23)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('native-instruments', 'komplete-audio-1'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/komplete-audio-1
  ('native-instruments', 'komplete-audio-2'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/komplete-audio-2
  ('native-instruments', 'komplete-kontrol-a25'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/komplete-kontrol-a25
  ('native-instruments', 'komplete-kontrol-a49'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/komplete-kontrol-a49
  ('native-instruments', 'komplete-kontrol-a61'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/komplete-kontrol-a61
  ('native-instruments', 'komplete-kontrol-m32'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/komplete-kontrol-m32
  ('native-instruments', 'kontrol-s49'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/kontrol-s49
  ('native-instruments', 'kontrol-s61'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/kontrol-s61
  ('native-instruments', 'kontrol-s88'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/kontrol-s88
  ('native-instruments', 'maschine'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/maschine
  ('native-instruments', 'maschine-3-software-update'), -- upgrade SKU, not a product | https://www.native-instruments.com/products/maschine-3-software-update
  ('native-instruments', 'maschine-mikro'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/maschine-mikro
  ('native-instruments', 'maschine-plus'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/maschine-plus
  ('native-instruments', 'mk2-cd'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/mk2-cd
  ('native-instruments', 'power-supply-40-w'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/power-supply-40-w
  ('native-instruments', 'traktor-control-vinyl'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-control-vinyl
  ('native-instruments', 'traktor-dj-cable'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-dj-cable
  ('native-instruments', 'traktor-flight-case'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-flight-case
  ('native-instruments', 'traktor-modular-bag'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-modular-bag
  ('native-instruments', 'traktor-mx2'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-mx2
  ('native-instruments', 'traktor-x1'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-x1
  ('native-instruments', 'traktor-z1'), -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktor-z1
  ('native-instruments', 'traktorkontrols2mk3') -- hardware / accessory, not a software licence | https://www.native-instruments.com/products/traktorkontrols2mk3
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Third-party products whose publisher is not in the catalogue (277)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('native-instruments', '10-phantom-rooms-everything-bundle'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/10-phantom-rooms-everything-bundle
  ('native-instruments', '60s-guitar'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/60s-guitar
  ('native-instruments', '70-guitar-rock-pop-2'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/70-guitar-rock-pop-2
  ('native-instruments', 'abstract-experiments'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/abstract-experiments
  ('native-instruments', 'acousmatic-engine'), -- third-party product (publisher: Cymatic Form) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/acousmatic-engine
  ('native-instruments', 'acoustic-bundle'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/acoustic-bundle
  ('native-instruments', 'acoustic-guitar-melodies'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/acoustic-guitar-melodies
  ('native-instruments', 'altron-2'), -- third-party product (publisher: Beyron Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/altron-2
  ('native-instruments', 'ambient-signature-bundle'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/ambient-signature-bundle
  ('native-instruments', 'ambient-strings-bundle'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/ambient-strings-bundle
  ('native-instruments', 'ambient-woodwinds-bundle'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/ambient-woodwinds-bundle
  ('native-instruments', 'american-punk-rock-guitars'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/american-punk-rock-guitars
  ('native-instruments', 'americana-guitars'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/americana-guitars
  ('native-instruments', 'appex-modern-trailer-guitar'), -- third-party product (publisher: Keep Forest) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/appex-modern-trailer-guitar
  ('native-instruments', 'aria-vocalscapes'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/aria-vocalscapes
  ('native-instruments', 'asmr-choir'), -- third-party product (publisher: SRM Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/asmr-choir
  ('native-instruments', 'atlas-flutes'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/atlas-flutes
  ('native-instruments', 'auras'), -- third-party product (publisher: Slate + Ash) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/auras
  ('native-instruments', 'bagpipe'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/bagpipe
  ('native-instruments', 'bastian-emig-tama-starclassic-bubinga'), -- third-party product (publisher: Klangmacht) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/bastian-emig-tama-starclassic-bubinga
  ('native-instruments', 'battalion'), -- third-party product (publisher: Unfiltered Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/battalion
  ('native-instruments', 'berserkr-pro'), -- third-party product (publisher: Keep Forest) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/berserkr-pro
  ('native-instruments', 'big-bams'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/big-bams
  ('native-instruments', 'bioscape'), -- third-party product (publisher: Luftrum) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/bioscape
  ('native-instruments', 'bowed-metals'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/bowed-metals
  ('native-instruments', 'brass-swells-pro'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/brass-swells-pro
  ('native-instruments', 'cavaquinho'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/cavaquinho
  ('native-instruments', 'cello-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/cello-textures
  ('native-instruments', 'chamber-swells-bundle'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chamber-swells-bundle
  ('native-instruments', 'chip-osc'), -- third-party product (publisher: Clay and Kelsy Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chip-osc
  ('native-instruments', 'chronicles-brass-and-wood'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-brass-and-wood
  ('native-instruments', 'chronicles-bukhu'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-bukhu
  ('native-instruments', 'chronicles-inti'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-inti
  ('native-instruments', 'chronicles-mitra'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-mitra
  ('native-instruments', 'chronicles-miyabi'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-miyabi
  ('native-instruments', 'chronicles-tales-of-the-road-vol-1'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-tales-of-the-road-vol-1
  ('native-instruments', 'chronicles-tales-of-the-road-vol-2'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/chronicles-tales-of-the-road-vol-2
  ('native-instruments', 'clarinet-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/clarinet-textures
  ('native-instruments', 'colors-bowed-textures-collection'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/colors-bowed-textures-collection
  ('native-instruments', 'colors-expressive-winds-collection'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/colors-expressive-winds-collection
  ('native-instruments', 'colors-plucked-textures-collection'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/colors-plucked-textures-collection
  ('native-instruments', 'combobulator'), -- third-party product (publisher: DataMind Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/combobulator
  ('native-instruments', 'composer-essentials-bundle'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/composer-essentials-bundle
  ('native-instruments', 'concatenator'), -- third-party product (publisher: DataMind Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/concatenator
  ('native-instruments', 'country-electric-guitar'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/country-electric-guitar
  ('native-instruments', 'crosstalk-bundle'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/crosstalk-bundle
  ('native-instruments', 'crosstalk-guitars'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/crosstalk-guitars
  ('native-instruments', 'crosstalk-modular'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/crosstalk-modular
  ('native-instruments', 'crosstalk-piano'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/crosstalk-piano
  ('native-instruments', 'cycles'), -- third-party product (publisher: Slate + Ash) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/cycles
  ('native-instruments', 'dado-lilac-alloy'), -- third-party product (publisher: Tonal Forms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/dado-lilac-alloy
  ('native-instruments', 'dark-mandolin'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/dark-mandolin
  ('native-instruments', 'decadence-trailer-toms'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/decadence-trailer-toms
  ('native-instruments', 'desecrator'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/desecrator
  ('native-instruments', 'desolate-guitars'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/desolate-guitars
  ('native-instruments', 'desolate-velvet-guitars-bundle'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/desolate-velvet-guitars-bundle
  ('native-instruments', 'deviant-drums'), -- third-party product (publisher: Chaos Tones) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/deviant-drums
  ('native-instruments', 'digi-osc'), -- third-party product (publisher: Clay and Kelsy Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/digi-osc
  ('native-instruments', 'disco-guitars'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/disco-guitars
  ('native-instruments', 'distinction'), -- third-party product (publisher: blecksaudio.) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/distinction
  ('native-instruments', 'dobro-americana-and-country'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/dobro-americana-and-country
  ('native-instruments', 'dopamine'), -- third-party product (publisher: Drumasonic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/dopamine
  ('native-instruments', 'double-bass-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/double-bass-textures
  ('native-instruments', 'dulcitone-celesta'), -- third-party product (publisher: realsamples) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/dulcitone-celesta
  ('native-instruments', 'dystopia-diary'), -- third-party product (publisher: Ocean Swift Synthesis) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/dystopia-diary
  ('native-instruments', 'e-instruments-pro-bundle'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/e-instruments-pro-bundle
  ('native-instruments', 'early-pianoforte'), -- third-party product (publisher: realsamples) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/early-pianoforte
  ('native-instruments', 'eclipse'), -- third-party product (publisher: Wide Blue Sound) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/eclipse
  ('native-instruments', 'eclipser-hybrid-synth'), -- third-party product (publisher: Battersea Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/eclipser-hybrid-synth
  ('native-instruments', 'edda'), -- third-party product (publisher: Wavelet Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/edda
  ('native-instruments', 'eeyore'), -- third-party product (publisher: BioSoul Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/eeyore
  ('native-instruments', 'eloy-drums'), -- third-party product (publisher: Bogren Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/eloy-drums
  ('native-instruments', 'elysium'), -- third-party product (publisher: Wide Blue Sound) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/elysium
  ('native-instruments', 'emergence-audio-essentials-bundle'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/emergence-audio-essentials-bundle
  ('native-instruments', 'emergence-audio-infinite-suite'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/emergence-audio-infinite-suite
  ('native-instruments', 'emergent-drums-2'), -- third-party product (publisher: Audialab) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/emergent-drums-2
  ('native-instruments', 'emma-legato'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/emma-legato
  ('native-instruments', 'evolution-devastator-breakout-pro'), -- third-party product (publisher: Keep Forest) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/evolution-devastator-breakout-pro
  ('native-instruments', 'experiments-bundle'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/experiments-bundle
  ('native-instruments', 'extended-acoustic-guitar'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/extended-acoustic-guitar
  ('native-instruments', 'extended-electric-guitar'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/extended-electric-guitar
  ('native-instruments', 'extinction-level-event-master-kit'), -- third-party product (publisher: Spectre Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/extinction-level-event-master-kit
  ('native-instruments', 'fever-dreams'), -- third-party product (publisher: Fever Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/fever-dreams
  ('native-instruments', 'flow-and-motion-dombra'), -- third-party product (publisher: Wavelet Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/flow-and-motion-dombra
  ('native-instruments', 'flute-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/flute-textures
  ('native-instruments', 'folds'), -- third-party product (publisher: Void and Vista) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/folds
  ('native-instruments', 'folk-guitars'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/folk-guitars
  ('native-instruments', 'forge-horns'), -- third-party product (publisher: Filipe Leitao) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/forge-horns
  ('native-instruments', 'forge-low-strings'), -- third-party product (publisher: Filipe Leitao) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/forge-low-strings
  ('native-instruments', 'forge-trumpet'), -- third-party product (publisher: Filipe Leitao) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/forge-trumpet
  ('native-instruments', 'forged-keys-fk-1'), -- third-party product (publisher: Battersea Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/forged-keys-fk-1
  ('native-instruments', 'fractured-futures-bundle'), -- third-party product (publisher: Ocean Swift Synthesis) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/fractured-futures-bundle
  ('native-instruments', 'funk-guitars'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/funk-guitars
  ('native-instruments', 'funk-horns'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/funk-horns
  ('native-instruments', 'glencoeaudio-skyedrift'), -- third-party product (publisher: Glencoe Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/glencoeaudio-skyedrift
  ('native-instruments', 'gojira-mario-duplantier'), -- third-party product (publisher: Mixwave) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/gojira-mario-duplantier
  ('native-instruments', 'gorilla-drive'), -- third-party product (publisher: Safari Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/gorilla-drive
  ('native-instruments', 'gradient'), -- third-party product (publisher: Constructs Of Time) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/gradient
  ('native-instruments', 'groth'), -- third-party product (publisher: Wavelet Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/groth
  ('native-instruments', 'guitar-odyssey'), -- third-party product (publisher: Naroth Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/guitar-odyssey
  ('native-instruments', 'guitarocracy'), -- third-party product (publisher: DO Studios) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/guitarocracy
  ('native-instruments', 'gyro'), -- third-party product (publisher: 10K Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/gyro
  ('native-instruments', 'hammers-waves-acoustic'), -- third-party product (publisher: Skybox Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hammers-waves-acoustic
  ('native-instruments', 'hammers-waves-chime'), -- third-party product (publisher: Skybox Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hammers-waves-chime
  ('native-instruments', 'hammers-waves-electric'), -- third-party product (publisher: Skybox Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hammers-waves-electric
  ('native-instruments', 'hammers-waves-prepared'), -- third-party product (publisher: Skybox Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hammers-waves-prepared
  ('native-instruments', 'hang-drum-experiments'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hang-drum-experiments
  ('native-instruments', 'harmonic-bloom'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/harmonic-bloom
  ('native-instruments', 'helloween-drums'), -- third-party product (publisher: Klangmacht) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/helloween-drums
  ('native-instruments', 'heritage-cello'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/heritage-cello
  ('native-instruments', 'hurdy-gurdy'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hurdy-gurdy
  ('native-instruments', 'hybrid-studio-taiko'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/hybrid-studio-taiko
  ('native-instruments', 'icon-drums-classic-rock'), -- third-party product (publisher: Spectre Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/icon-drums-classic-rock
  ('native-instruments', 'infinite-bird-whistle'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/infinite-bird-whistle
  ('native-instruments', 'infinite-guitar'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/infinite-guitar
  ('native-instruments', 'infinite-steel-tongue'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/infinite-steel-tongue
  ('native-instruments', 'infinite-upright'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/infinite-upright
  ('native-instruments', 'intimate-legato-bundle'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/intimate-legato-bundle
  ('native-instruments', 'intimate-legato-cello'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/intimate-legato-cello
  ('native-instruments', 'intimate-legato-violin'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/intimate-legato-violin
  ('native-instruments', 'isbanjonksstore'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/isbanjonksstore
  ('native-instruments', 'isbluesguitarsnksstore'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/isbluesguitarsnksstore
  ('native-instruments', 'iscellofolkpopnksstore'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/iscellofolkpopnksstore
  ('native-instruments', 'iscinematicharpnksstore'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/iscinematicharpnksstore
  ('native-instruments', 'iscountryfiddlenksstore'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/iscountryfiddlenksstore
  ('native-instruments', 'jambalom-grand-cimbalom'), -- third-party product (publisher: Jambalom Ltd.) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/jambalom-grand-cimbalom
  ('native-instruments', 'jazz-guitar-acoustic'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/jazz-guitar-acoustic
  ('native-instruments', 'jazz-trumpet'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/jazz-trumpet
  ('native-instruments', 'jx-osc'), -- third-party product (publisher: Clay and Kelsy Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/jx-osc
  ('native-instruments', 'klangmacht-drums-2025'), -- third-party product (publisher: Klangmacht) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/klangmacht-drums-2025
  ('native-instruments', 'krimh-drums'), -- third-party product (publisher: Bogren Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/krimh-drums
  ('native-instruments', 'landforms'), -- third-party product (publisher: Slate + Ash) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/landforms
  ('native-instruments', 'louisa-arc'), -- third-party product (publisher: Wavelet Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/louisa-arc
  ('native-instruments', 'low-end-brass'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/low-end-brass
  ('native-instruments', 'low-end-bundle'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/low-end-bundle
  ('native-instruments', 'low-end-modular'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/low-end-modular
  ('native-instruments', 'low-end-strings'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/low-end-strings
  ('native-instruments', 'low-end-toys'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/low-end-toys
  ('native-instruments', 'luke-holland'), -- third-party product (publisher: Mixwave) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/luke-holland
  ('native-instruments', 'lunaris'), -- third-party product (publisher: Luftrum) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/lunaris
  ('native-instruments', 'lunaris-2'), -- third-party product (publisher: Luftrum) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/lunaris-2
  ('native-instruments', 'massive-gongs'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/massive-gongs
  ('native-instruments', 'max-richter-piano'), -- third-party product (publisher: SRM Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/max-richter-piano
  ('native-instruments', 'mega-bundle'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mega-bundle
  ('native-instruments', 'mega-bundle-vol-2'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mega-bundle-vol-2
  ('native-instruments', 'melodic-deathmetal-drums'), -- third-party product (publisher: Klangmacht) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/melodic-deathmetal-drums
  ('native-instruments', 'metal-pipes-and-plates'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/metal-pipes-and-plates
  ('native-instruments', 'mezza-coda'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mezza-coda
  ('native-instruments', 'micdrop-suite'), -- third-party product (publisher: Soundlabs.ai) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/micdrop-suite
  ('native-instruments', 'monolith'), -- third-party product (publisher: Artistry Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/monolith
  ('native-instruments', 'moo-osc'), -- third-party product (publisher: Clay and Kelsy Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/moo-osc
  ('native-instruments', 'motion'), -- third-party product (publisher: blecksaudio.) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/motion
  ('native-instruments', 'mr-bundle'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mr-bundle
  ('native-instruments', 'mr1-valve-data'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mr1-valve-data
  ('native-instruments', 'mr2-operator-871'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mr2-operator-871
  ('native-instruments', 'mr3-beta-tapes'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/mr3-beta-tapes
  ('native-instruments', 'neo-soul-guitar'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/neo-soul-guitar
  ('native-instruments', 'nisui-upright-piano'), -- third-party product (publisher: Battersea Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/nisui-upright-piano
  ('native-instruments', 'noams-mastering-console'), -- third-party product (publisher: Safari Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/noams-mastering-console
  ('native-instruments', 'nocturne-electric-piano'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/nocturne-electric-piano
  ('native-instruments', 'nylon-guitar-latin-music'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/nylon-guitar-latin-music
  ('native-instruments', 'obsidian-brass'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/obsidian-brass
  ('native-instruments', 'orbit'), -- third-party product (publisher: Wide Blue Sound) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/orbit
  ('native-instruments', 'origin-x'), -- third-party product (publisher: Artistry Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/origin-x
  ('native-instruments', 'originals-bundle'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/originals-bundle
  ('native-instruments', 'osc-collection'), -- third-party product (publisher: Clay and Kelsy Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/osc-collection
  ('native-instruments', 'oscillarys'), -- third-party product (publisher: Ocean Swift Synthesis) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/oscillarys
  ('native-instruments', 'pangea'), -- third-party product (publisher: Infinite Samples) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pangea
  ('native-instruments', 'panorama-acoustic'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/panorama-acoustic
  ('native-instruments', 'panorama-guitars'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/panorama-guitars
  ('native-instruments', 'panorama-whitekirk'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/panorama-whitekirk
  ('native-instruments', 'pedal-steel-guitar-2'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pedal-steel-guitar-2
  ('native-instruments', 'poiesis-cello'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/poiesis-cello
  ('native-instruments', 'polygrade-tape-synth'), -- third-party product (publisher: Battersea Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/polygrade-tape-synth
  ('native-instruments', 'porphyra-hybrid'), -- third-party product (publisher: Ocean Swift Synthesis) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/porphyra-hybrid
  ('native-instruments', 'prism-cinematic-dark-drums'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/prism-cinematic-dark-drums
  ('native-instruments', 'prism-modern-pop-drums'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/prism-modern-pop-drums
  ('native-instruments', 'prism-organic-lofi-drums'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/prism-organic-lofi-drums
  ('native-instruments', 'prism-retro-pop-drums'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/prism-retro-pop-drums
  ('native-instruments', 'prism-taped-indie-pop-drums'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/prism-taped-indie-pop-drums
  ('native-instruments', 'prism-urban-legends'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/prism-urban-legends
  ('native-instruments', 'pro-drums-leap-bundle'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pro-drums-leap-bundle
  ('native-instruments', 'pro-guitars-leap-bundle'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pro-guitars-leap-bundle
  ('native-instruments', 'pro-instrument-leap-bundle'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pro-instrument-leap-bundle
  ('native-instruments', 'pro-osc'), -- third-party product (publisher: Clay and Kelsy Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pro-osc
  ('native-instruments', 'pro-percussion-leap-bundle'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pro-percussion-leap-bundle
  ('native-instruments', 'pro-producer-kits-leap-bundle'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/pro-producer-kits-leap-bundle
  ('native-instruments', 'promo-horns'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/promo-horns
  ('native-instruments', 'psykkedelia'), -- third-party product (publisher: Beastsamples) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/psykkedelia
  ('native-instruments', 'quantum'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/quantum
  ('native-instruments', 'randy-black-drums'), -- third-party product (publisher: Klangmacht) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/randy-black-drums
  ('native-instruments', 'rathgar-pipe-organ'), -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/rathgar-pipe-organ
  ('native-instruments', 'ravenscroft-220-vi'), -- third-party product (publisher: Prime Studio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/ravenscroft-220-vi
  ('native-instruments', 'ravenscroft-220-vi-lite'), -- third-party product (publisher: Prime Studio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/ravenscroft-220-vi-lite
  ('native-instruments', 'redline-trailer-drums'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/redline-trailer-drums
  ('native-instruments', 'refraction-piano'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/refraction-piano
  ('native-instruments', 'reggae-horns'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/reggae-horns
  ('native-instruments', 'restrung-volume-1'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/restrung-volume-1
  ('native-instruments', 'royal-albert-hall-organ'), -- third-party product (publisher: Enigma Recordings) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/royal-albert-hall-organ
  ('native-instruments', 'rsi-1'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/rsi-1
  ('native-instruments', 'rsi-2'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/rsi-2
  ('native-instruments', 'rsi-bundle'), -- third-party product (publisher: 10 Phantom Rooms) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/rsi-bundle
  ('native-instruments', 'runa-elder-scoring-strings'), -- third-party product (publisher: Wavelet Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/runa-elder-scoring-strings
  ('native-instruments', 'safari-audio-x-ni-bundle'), -- third-party product (publisher: Safari Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/safari-audio-x-ni-bundle
  ('native-instruments', 'safari-pedals-everything-bundle'), -- third-party product (publisher: Safari Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/safari-pedals-everything-bundle
  ('native-instruments', 'scorpio'), -- third-party product (publisher: Artistry Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/scorpio
  ('native-instruments', 'secunda'), -- third-party product (publisher: Wavelet Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/secunda
  ('native-instruments', 'session-keys-electric-bundle'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-electric-bundle
  ('native-instruments', 'session-keys-electric-r'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-electric-r
  ('native-instruments', 'session-keys-electric-s'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-electric-s
  ('native-instruments', 'session-keys-electric-w'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-electric-w
  ('native-instruments', 'session-keys-grand-s'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-grand-s
  ('native-instruments', 'session-keys-grand-y'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-grand-y
  ('native-instruments', 'session-keys-upright'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/session-keys-upright
  ('native-instruments', 'slate-and-ash-collection'), -- third-party product (publisher: Slate + Ash) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/slate-and-ash-collection
  ('native-instruments', 'sleep-piano'), -- third-party product (publisher: SRM Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/sleep-piano
  ('native-instruments', 'slower'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/slower
  ('native-instruments', 'softstruck'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/softstruck
  ('native-instruments', 'soprano-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/soprano-textures
  ('native-instruments', 'soul-guitars'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/soul-guitars
  ('native-instruments', 'spat-curve'), -- third-party product (publisher: NAFF - 3D Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/spat-curve
  ('native-instruments', 'staccato'), -- third-party product (publisher: Artistry Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/staccato
  ('native-instruments', 'strands'), -- third-party product (publisher: Void and Vista) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/strands
  ('native-instruments', 'strike-strings'), -- third-party product (publisher: Filipe Leitao) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/strike-strings
  ('native-instruments', 'string-swells-pro'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/string-swells-pro
  ('native-instruments', 'studio-bundle'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/studio-bundle
  ('native-instruments', 'superball-experiments'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/superball-experiments
  ('native-instruments', 'swords-to-ploughshares'), -- third-party product (publisher: Mask Movement) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/swords-to-ploughshares
  ('native-instruments', 'tapes-01'), -- third-party product (publisher: THEPHONOLOOP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/tapes-01
  ('native-instruments', 'tenor-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/tenor-textures
  ('native-instruments', 'the-abyss'), -- third-party product (publisher: Infinite Samples) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/the-abyss
  ('native-instruments', 'the-clavinet-clone'), -- third-party product (publisher: Analog Came Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/the-clavinet-clone
  ('native-instruments', 'themkl'), -- third-party product (publisher: THEPHONOLOOP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/themkl
  ('native-instruments', 'time-crystals'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/time-crystals
  ('native-instruments', 'titan'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/titan
  ('native-instruments', 'tommee-profitt-percussion'), -- third-party product (publisher: Cinematic Tools) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/tommee-profitt-percussion
  ('native-instruments', 'toska'), -- third-party product (publisher: Noon Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/toska
  ('native-instruments', 'trailer-braams-ii'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/trailer-braams-ii
  ('native-instruments', 'trivium-drums'), -- third-party product (publisher: Bogren Digital) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/trivium-drums
  ('native-instruments', 'unblown'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unblown
  ('native-instruments', 'unity-electronic-era'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unity-electronic-era
  ('native-instruments', 'unity-modern-trailer-synth'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unity-modern-trailer-synth
  ('native-instruments', 'unity-nostalgic-synth'), -- third-party product (publisher: AVA MUSIC GROUP) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unity-nostalgic-synth
  ('native-instruments', 'unstrummed'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unstrummed
  ('native-instruments', 'unstrung-2'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unstrung-2
  ('native-instruments', 'unsung'), -- third-party product (publisher: Fallout Music Group) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/unsung
  ('native-instruments', 'valley-forge'), -- third-party product (publisher: SRM Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/valley-forge
  ('native-instruments', 'vela-woodwinds'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/vela-woodwinds
  ('native-instruments', 'velvet-guitars'), -- third-party product (publisher: e-instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/velvet-guitars
  ('native-instruments', 'verticale'), -- third-party product (publisher: Sonora Cinematic) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/verticale
  ('native-instruments', 'vessels'), -- third-party product (publisher: Noon Instruments) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/vessels
  ('native-instruments', 'viola-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/viola-textures
  ('native-instruments', 'violin-2-folk-and-pop'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/violin-2-folk-and-pop
  ('native-instruments', 'violin-textures'), -- third-party product (publisher: Emergence Audio) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/violin-textures
  ('native-instruments', 'vocal-choir-leap-bundle'), -- third-party product (publisher: Image Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/vocal-choir-leap-bundle
  ('native-instruments', 'watchkeeper'), -- third-party product (publisher: Keep Forest) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/watchkeeper
  ('native-instruments', 'wind-swells-pro'), -- third-party product (publisher: Sonixinema) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/wind-swells-pro
  ('native-instruments', 'world-percussion-africa'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-africa
  ('native-instruments', 'world-percussion-angklung'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-angklung
  ('native-instruments', 'world-percussion-asia'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-asia
  ('native-instruments', 'world-percussion-bundle'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-bundle
  ('native-instruments', 'world-percussion-ensembles'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-ensembles
  ('native-instruments', 'world-percussion-europe'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-europe
  ('native-instruments', 'world-percussion-mbira'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-mbira
  ('native-instruments', 'world-percussion-middle-east'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-middle-east
  ('native-instruments', 'world-percussion-oddities'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-oddities
  ('native-instruments', 'world-percussion-south-america'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-south-america
  ('native-instruments', 'world-percussion-taiko'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-taiko
  ('native-instruments', 'world-percussion-tuned'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-percussion-tuned
  ('native-instruments', 'world-reeds-harmonium'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-reeds-harmonium
  ('native-instruments', 'world-strings-guzheng'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-strings-guzheng
  ('native-instruments', 'world-strings-harp'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-strings-harp
  ('native-instruments', 'world-strings-oud'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-strings-oud
  ('native-instruments', 'world-strings-santur'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-strings-santur
  ('native-instruments', 'world-strings-saz'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-strings-saz
  ('native-instruments', 'world-strings-tanpura'), -- third-party product (publisher: Evolution Series) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/world-strings-tanpura
  ('native-instruments', 'zither') -- third-party product (publisher: Edu Prado Sounds) wrongly attributed to Native Instruments, publisher not in the catalogue | https://www.native-instruments.com/products/zither
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (256)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('native-instruments', '80', 'sonokinetic', '80', '80', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/80
  ('native-instruments', 'abstract-currents', 'wave-alchemy', 'Abstract Currents', 'abstract-currents', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/abstract-currents
  ('native-instruments', 'ac-dr-acoustic-drum-machine', 'soniccouture', 'AC-DR Acoustic Drum Machine', 'ac-dr-acoustic-drum-machine', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/ac-dr-acoustic-drum-machine
  ('native-instruments', 'aeris', 'vir2-instruments', 'Aeris: Hybrid Choir Designer', 'aeris-hybrid-choir-designer', null::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/aeris
  ('native-instruments', 'afropulse', 'wave-alchemy', 'AfroPulse', 'afropulse', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/afropulse
  ('native-instruments', 'all-saints-choir', 'soniccouture', 'All Saints Choir', 'all-saints-choir', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/all-saints-choir
  ('native-instruments', 'all-saints-organ', 'soniccouture', 'All Saints Organ', 'all-saints-organ', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/all-saints-organ
  ('native-instruments', 'allure-modern-upright', 'heavyocity', 'ALLURE Modern Upright', 'allure-modern-upright', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/allure-modern-upright
  ('native-instruments', 'ambient-minimalism', 'big-fish-audio', 'Ambient Minimalism', 'ambient-minimalism', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/ambient-minimalism
  ('native-instruments', 'array-mbira', 'soniccouture', 'Array Mbira', 'array-mbira', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/array-mbira
  ('native-instruments', 'arva-children-choir', 'strezov-sampling', 'Arva Children Choir', 'arva-children-choir', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/arva-children-choir
  ('native-instruments', 'ascend', 'heavyocity', 'Ascend Modern Grand', 'ascend-modern-grand', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/ascend
  ('native-instruments', 'aspire', 'heavyocity', 'Aspire - Modern Mallets', 'aspire-modern-mallets', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/aspire
  ('native-instruments', 'aura', 'vir2-instruments', 'Aura: Atmospheric Drone Builder', 'aura-atmospheric-drone-builder', null::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/aura
  ('native-instruments', 'aurora', 'izotope', 'Aurora', 'aurora', 'reverb-delay'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/aurora
  ('native-instruments', 'avant', 'heavyocity', 'Avant Modern Keys', 'avant-modern-keys', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/avant
  ('native-instruments', 'baby-audio-x-ni-bundle', 'baby-audio', 'Baby Audio x NI Bundle', 'baby-audio-x-ni-bundle', null::text), -- published by Baby Audio, sold on the NI store | https://www.native-instruments.com/products/baby-audio-x-ni-bundle
  ('native-instruments', 'balinese-flutes', 'soniccouture', 'Balinese Flutes', 'balinese-flutes', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/balinese-flutes
  ('native-instruments', 'balinese-gamelan-ii', 'soniccouture', 'Balinese Gamelan II', 'balinese-gamelan-ii', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/balinese-gamelan-ii
  ('native-instruments', 'balkan-ethnic-orchestra', 'strezov-sampling', 'Balkan Ethnic Orchestra', 'balkan-ethnic-orchestra', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/balkan-ethnic-orchestra
  ('native-instruments', 'bassynth', 'wave-alchemy', 'Bassynth', 'bassynth', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/bassynth
  ('native-instruments', 'bells-collection', 'sonokinetic', 'Bells Collection', 'bells-collection', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/bells-collection
  ('native-instruments', 'berlin-orchestra-inspire', 'orchestral-tools', 'Berlin Orchestra Inspire', 'berlin-orchestra-inspire', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/berlin-orchestra-inspire
  ('native-instruments', 'berlin-orchestra-inspire-1-2', 'orchestral-tools', 'Berlin Orchestra Inspire 1 & 2', 'berlin-orchestra-inspire-1-and-2', 'bundles'::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/berlin-orchestra-inspire-1-2
  ('native-instruments', 'berlin-orchestra-inspire-2', 'orchestral-tools', 'Berlin Orchestra Inspire 2', 'berlin-orchestra-inspire-2', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/berlin-orchestra-inspire-2
  ('native-instruments', 'berlin-percussion', 'orchestral-tools', 'Berlin Percussion', 'berlin-percussion', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/berlin-percussion
  ('native-instruments', 'boogie-bass', 'wave-alchemy', 'Boogie Bass', 'boogie-bass', 'sample-libraries'::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/boogie-bass
  ('native-instruments', 'box-of-tricks', 'soniccouture', 'Box of Tricks', 'box-of-tricks', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/box-of-tricks
  ('native-instruments', 'brass-bundle', 'sample-modeling', 'Brass Bundle', 'brass-bundle', null::text), -- published by Sample Modeling, sold on the NI store | https://www.native-instruments.com/products/brass-bundle
  ('native-instruments', 'brickwall-drums', 'heavyocity', 'Brickwall Drums', 'brickwall-drums', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/brickwall-drums
  ('native-instruments', 'broken-wurli', 'soniccouture', 'Broken Wurli', 'broken-wurli', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/broken-wurli
  ('native-instruments', 'capriccio', 'sonokinetic', 'Capriccio', 'capriccio', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/capriccio
  ('native-instruments', 'cascadia', 'izotope', 'Cascadia', 'cascadia', 'reverb-delay'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/cascadia
  ('native-instruments', 'celeste', 'soniccouture', 'Celeste', 'celeste', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/celeste
  ('native-instruments', 'century-ostinato-strings-ii', '8dio', 'Century Ostinato Strings II', 'century-ostinato-strings-ii', null::text), -- published by 8Dio, sold on the NI store | https://www.native-instruments.com/products/century-ostinato-strings-ii
  ('native-instruments', 'century-strings', '8dio', 'Century Strings', 'century-strings', null::text), -- published by 8Dio, sold on the NI store | https://www.native-instruments.com/products/century-strings
  ('native-instruments', 'chroma', 'sonuscore', 'Chroma', 'chroma', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/chroma
  ('native-instruments', 'chroma-bundle', 'sonuscore', 'Chroma Bundle', 'chroma-bundle', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/chroma-bundle
  ('native-instruments', 'chroma-upright-piano', 'sonuscore', 'Chroma - Upright Piano', 'chroma-upright-piano', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/chroma-upright-piano
  ('native-instruments', 'cinebrass-descant-horn', 'cinesamples', 'CineBrass Descant Horn', 'cinebrass-descant-horn', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinebrass-descant-horn
  ('native-instruments', 'cinebrass-pro', 'cinesamples', 'CineBrass PRO', 'cinebrass-pro', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinebrass-pro
  ('native-instruments', 'cinebrass-sonore', 'cinesamples', 'CineBrass Sonore', 'cinebrass-sonore', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinebrass-sonore
  ('native-instruments', 'cineharps', 'cinesamples', 'CineHarps', 'cineharps', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cineharps
  ('native-instruments', 'cinepiano', 'cinesamples', 'CinePiano', 'cinepiano', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinepiano
  ('native-instruments', 'cinestrings-solo', 'cinesamples', 'CineStrings Solo', 'cinestrings-solo', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinestrings-solo
  ('native-instruments', 'cinesymphony-lite', 'cinesamples', 'CineSymphony LITE', 'cinesymphony-lite', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinesymphony-lite
  ('native-instruments', 'cinewinds-monster-low-winds', 'cinesamples', 'CineWinds Monster Low Winds', 'cinewinds-monster-low-winds', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinewinds-monster-low-winds
  ('native-instruments', 'cinewinds-pro', 'cinesamples', 'CineWinds PRO', 'cinewinds-pro', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/cinewinds-pro
  ('native-instruments', 'colours-animator', 'projectsam', 'Colours: Animator', 'colours-animator', null::text), -- published by ProjectSAM, sold on the NI store | https://www.native-instruments.com/products/colours-animator
  ('native-instruments', 'colours-orchestrator', 'projectsam', 'Colours: Orchestrator', 'colours-orchestrator', null::text), -- published by ProjectSAM, sold on the NI store | https://www.native-instruments.com/products/colours-orchestrator
  ('native-instruments', 'convergence', 'heavyocity', 'Convergence', 'convergence', 'synths'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/convergence
  ('native-instruments', 'creator-bundle', 'wave-alchemy', 'Creator Bundle', 'creator-bundle', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/creator-bundle
  ('native-instruments', 'crystal', 'soundiron', 'Crystal', 'crystal', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/crystal
  ('native-instruments', 'damage-analog-hybrid-drums', 'heavyocity', 'Damage: Analog Hybrid Drums', 'damage-analog-hybrid-drums', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/damage-analog-hybrid-drums
  ('native-instruments', 'damage-drum-kit', 'heavyocity', 'Damage Drum Kit', 'damage-drum-kit', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/damage-drum-kit
  ('native-instruments', 'damage-guitars', 'heavyocity', 'Damage Guitars', 'damage-guitars', 'sample-libraries'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/damage-guitars
  ('native-instruments', 'damage-rock-grooves', 'heavyocity', 'Damage Rock Grooves', 'damage-rock-grooves', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/damage-rock-grooves
  ('native-instruments', 'deep-felt', 'soniccouture', 'Deep Felt', 'deep-felt', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/deep-felt
  ('native-instruments', 'deep-percussion-beds-1', 'cinesamples', 'Deep Percussion Beds 1', 'deep-percussion-beds-1', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/deep-percussion-beds-1
  ('native-instruments', 'deep-percussion-beds-2', 'cinesamples', 'Deep Percussion Beds 2', 'deep-percussion-beds-2', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/deep-percussion-beds-2
  ('native-instruments', 'deep-solo-violin', '8dio', 'Deep Solo Violin', 'deep-solo-violin', null::text), -- published by 8Dio, sold on the NI store | https://www.native-instruments.com/products/deep-solo-violin
  ('native-instruments', 'diamond-jazz-orchestra', 'strezov-sampling', 'Diamond Jazz Orchestra', 'diamond-jazz-orchestra', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/diamond-jazz-orchestra
  ('native-instruments', 'djembe-x3m', 'strezov-sampling', 'Djembe X3M', 'djembe-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/djembe-x3m
  ('native-instruments', 'drip', 'soundiron', 'Drip', 'drip', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/drip
  ('native-instruments', 'dystropia', 'heavyocity', 'Dystropia', 'dystropia', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/dystropia
  ('native-instruments', 'electric-soul', 'wave-alchemy', 'Electric Soul', 'electric-soul', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/electric-soul
  ('native-instruments', 'electro-acoustic', 'soniccouture', 'Electro-Acoustic', 'electro-acoustic', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/electro-acoustic
  ('native-instruments', 'elements-suite-12', 'izotope', 'Elements Suite 12', 'elements-suite-12', 'bundles'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/elements-suite-12
  ('native-instruments', 'epic-symphony-bundle', '8dio', 'Epic Symphony Bundle', 'epic-symphony-bundle', null::text), -- published by 8Dio, sold on the NI store | https://www.native-instruments.com/products/epic-symphony-bundle
  ('native-instruments', 'espressivo', 'sonokinetic', 'Espressivo', 'espressivo', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/espressivo
  ('native-instruments', 'evolution-flatwound-bass', 'orange-tree-samples', 'Evolution Flatwound Bass', 'evolution-flatwound-bass', 'sample-libraries'::text), -- published by Orange Tree Samples, sold on the NI store | https://www.native-instruments.com/products/evolution-flatwound-bass
  ('native-instruments', 'evolution-roundwound-bass', 'orange-tree-samples', 'Evolution Roundwound Bass', 'evolution-roundwound-bass', 'sample-libraries'::text), -- published by Orange Tree Samples, sold on the NI store | https://www.native-instruments.com/products/evolution-roundwound-bass
  ('native-instruments', 'exclusive-choir-bundle', 'strezov-sampling', 'Choir Bundle', 'choir-bundle', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/exclusive-choir-bundle
  ('native-instruments', 'first-call-horns', 'big-fish-audio', 'First Call Horns', 'first-call-horns', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/first-call-horns
  ('native-instruments', 'flowstate', 'soniccouture', 'Flowstate', 'flowstate', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/flowstate
  ('native-instruments', 'forzo-essentials', 'heavyocity', 'FORZO Essentials', 'forzo-essentials', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/forzo-essentials
  ('native-instruments', 'fragments-modern-percussion', 'sonuscore', 'Fragments', 'fragments', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/fragments-modern-percussion
  ('native-instruments', 'frame-drum-x3m', 'strezov-sampling', 'Frame Drum X3M', 'frame-drum-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/frame-drum-x3m
  ('native-instruments', 'freyja-female-choir', 'strezov-sampling', 'Freyja Female Choir', 'freyja-female-choir', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/freyja-female-choir
  ('native-instruments', 'fxeq', 'izotope', 'FXEQ', 'fxeq', 'reverb-delay'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/fxeq
  ('native-instruments', 'genesis-childrens-choir', 'audiobro', 'Genesis Children''s Choir', 'genesis-children-s-choir', null::text), -- published by Audiobro, sold on the NI store | https://www.native-instruments.com/products/genesis-childrens-choir
  ('native-instruments', 'grand-marimba', 'soniccouture', 'Grand Marimba', 'grand-marimba', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/grand-marimba
  ('native-instruments', 'gravity-2', 'heavyocity', 'Gravity 2', 'gravity-2', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/gravity-2
  ('native-instruments', 'guzheng', 'soniccouture', 'Guzheng', 'guzheng', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/guzheng
  ('native-instruments', 'haunted-spaces', 'soniccouture', 'Haunted Spaces', 'haunted-spaces', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/haunted-spaces
  ('native-instruments', 'haunted-spaces-2', 'soniccouture', 'Haunted Spaces 2', 'haunted-spaces-2', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/haunted-spaces-2
  ('native-instruments', 'hollywoodwinds', 'cinesamples', 'Hollywoodwinds', 'hollywoodwinds', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/hollywoodwinds
  ('native-instruments', 'hooked-up', 'wave-alchemy', 'Hooked Up', 'hooked-up', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/hooked-up
  ('native-instruments', 'hopkin-lamellophones', 'soundiron', 'Hopkin Lamellophones', 'hopkin-lamellophones', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/hopkin-lamellophones
  ('native-instruments', 'horns-bundle', 'big-fish-audio', 'Horns Bundle', 'horns-bundle', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/horns-bundle
  ('native-instruments', 'hyperion-strings-ensemble', 'soundiron', 'Hyperion Strings Ensemble', 'hyperion-strings-ensemble', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/hyperion-strings-ensemble
  ('native-instruments', 'ibrido-cinematica', 'sonokinetic', 'Ibrido Cinematica', 'ibrido-cinematica', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/ibrido-cinematica
  ('native-instruments', 'indie', 'sonokinetic', 'Indie', 'indie', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/indie
  ('native-instruments', 'instruments-of-antiquity', 'big-fish-audio', 'Ancient World: Instruments of Antiquity', 'ancient-world-instruments-of-antiquity', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/instruments-of-antiquity
  ('native-instruments', 'intimate-textures', 'heavyocity', 'Intimate Textures', 'intimate-textures', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/intimate-textures
  ('native-instruments', 'izotope-everything-bundle', 'izotope', 'iZotope Everything Bundle', 'izotope-everything-bundle', null::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/izotope-everything-bundle
  ('native-instruments', 'jade-ethnic-orchestra', 'strezov-sampling', 'Jade Ethnic Orchestra', 'jade-ethnic-orchestra', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/jade-ethnic-orchestra
  ('native-instruments', 'kambanite-church-bells', 'strezov-sampling', 'Kambanite Church Bells', 'kambanite-church-bells', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/kambanite-church-bells
  ('native-instruments', 'kim', 'soniccouture', 'Kim', 'kim', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/kim
  ('native-instruments', 'kora', 'soniccouture', 'Kora', 'kora', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/kora
  ('native-instruments', 'largo', 'sonokinetic', 'Largo', 'largo', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/largo
  ('native-instruments', 'lightning-x3m', 'strezov-sampling', 'Lightning X3M', 'lightning-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/lightning-x3m
  ('native-instruments', 'lineage-percussion-core', 'projectsam', 'Lineage Percussion Core', 'lineage-percussion-core', null::text), -- published by ProjectSAM, sold on the NI store | https://www.native-instruments.com/products/lineage-percussion-core
  ('native-instruments', 'lux-orchestral-strings-essentials', 'sonuscore', 'Lux Orchestral Strings Essentials', 'lux-orchestral-strings-essentials', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/lux-orchestral-strings-essentials
  ('native-instruments', 'machina', 'heavyocity', 'Machina', 'machina', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/machina
  ('native-instruments', 'majestica-professional', '8dio', 'Majestica Professional', 'majestica-professional', null::text), -- published by 8Dio, sold on the NI store | https://www.native-instruments.com/products/majestica-professional
  ('native-instruments', 'maximo', 'sonokinetic', 'Maximo', 'maximo', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/maximo
  ('native-instruments', 'metropolis-ark-1-2', 'orchestral-tools', 'Metropolis Ark 1 & 2', 'metropolis-ark-1-and-2', 'bundles'::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/metropolis-ark-1-2
  ('native-instruments', 'metropolis-ark-2', 'orchestral-tools', 'Metropolis Ark 2', 'metropolis-ark-2', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/metropolis-ark-2
  ('native-instruments', 'metropolis-ark-3', 'orchestral-tools', 'Metropolis Ark 3', 'metropolis-ark-3', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/metropolis-ark-3
  ('native-instruments', 'metropolis-ark-3-4', 'orchestral-tools', 'Metropolis Ark 3 & 4', 'metropolis-ark-3-and-4', 'bundles'::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/metropolis-ark-3-4
  ('native-instruments', 'metropolis-ark-4', 'orchestral-tools', 'Metropolis Ark 4', 'metropolis-ark-4', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/metropolis-ark-4
  ('native-instruments', 'metropolis-ark-5', 'orchestral-tools', 'Metropolis Ark 5', 'metropolis-ark-5', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/metropolis-ark-5
  ('native-instruments', 'midnight-mirage', 'wave-alchemy', 'Midnight Mirage', 'midnight-mirage', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/midnight-mirage
  ('native-instruments', 'mimi-page-light-shadow', 'soundiron', 'Mimi Page Light & Shadow', 'mimi-page-light-and-shadow', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/mimi-page-light-shadow
  ('native-instruments', 'mix-master-bundle-advanced', 'izotope', 'Mix & Master Bundle Advanced', 'mix-and-master-bundle-advanced', null::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/mix-master-bundle-advanced
  ('native-instruments', 'mix-master-bundle-standard', 'izotope', 'Mix & Master Bundle Standard', 'mix-and-master-bundle-standard', null::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/mix-master-bundle-standard
  ('native-instruments', 'modal-runs', 'sonokinetic', 'Modal Runs', 'modal-runs', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/modal-runs
  ('native-instruments', 'modern-drip', 'wave-alchemy', 'Modern Drip', 'modern-drip', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/modern-drip
  ('native-instruments', 'modern-harpejji', 'impact-soundworks', 'Modern Harpejji', 'modern-harpejji', null::text), -- published by Impact Soundworks, sold on the NI store | https://www.native-instruments.com/products/modern-harpejji
  ('native-instruments', 'modern-scoring-bundle', '8dio', 'Modern Scoring Bundle', 'modern-scoring-bundle', null::text), -- published by 8Dio, sold on the NI store | https://www.native-instruments.com/products/modern-scoring-bundle
  ('native-instruments', 'mojo-2-horn-section', 'vir2-instruments', 'MOJO 2: Horn Selection', 'mojo-2-horn-selection', null::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/mojo-2-horn-section
  ('native-instruments', 'mojo-upright-bass', 'vir2-instruments', 'MOJO - Upright Bass', 'mojo-upright-bass', 'sample-libraries'::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/mojo-upright-bass
  ('native-instruments', 'moonkits', 'soniccouture', 'Moonkits', 'moonkits', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/moonkits
  ('native-instruments', 'morpheus', 'soniccouture', 'Morpheus', 'morpheus', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/morpheus
  ('native-instruments', 'mosaic-bass', 'heavyocity', 'Mosaic Bass', 'mosaic-bass', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-bass
  ('native-instruments', 'mosaic-keys', 'heavyocity', 'Mosaic Keys', 'mosaic-keys', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-keys
  ('native-instruments', 'mosaic-leads', 'heavyocity', 'Mosaic Leads', 'mosaic-leads', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-leads
  ('native-instruments', 'mosaic-neon', 'heavyocity', 'Mosaic Neon', 'mosaic-neon', 'synths'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-neon
  ('native-instruments', 'mosaic-pads', 'heavyocity', 'Mosaic Pads', 'mosaic-pads', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-pads
  ('native-instruments', 'mosaic-pluck', 'heavyocity', 'Mosaic Pluck', 'mosaic-pluck', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-pluck
  ('native-instruments', 'mosaic-tape', 'heavyocity', 'Mosaic Tape', 'mosaic-tape', 'synths'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/mosaic-tape
  ('native-instruments', 'natural-forces', 'heavyocity', 'Natural Forces', 'natural-forces', 'synths'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/natural-forces
  ('native-instruments', 'nectar-elements', 'izotope', 'Nectar 4 Elements', 'nectar-4-elements', 'utilities'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/nectar-elements
  ('native-instruments', 'nectar-standard', 'izotope', 'Nectar 4 Standard', 'nectar-4-standard', 'utilities'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/nectar-standard
  ('native-instruments', 'neutron-elements', 'izotope', 'Neutron 5 Elements', 'neutron-5-elements', 'reverb-delay'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/neutron-elements
  ('native-instruments', 'noir', 'sonokinetic', 'Noir', 'noir', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/noir
  ('native-instruments', 'nordic-spheres', 'sonuscore', 'Nordic Spheres', 'nordic-spheres', 'synths'::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/nordic-spheres
  ('native-instruments', 'novachord', 'soniccouture', 'Novachord', 'novachord', 'synths'::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/novachord
  ('native-instruments', 'nyckelharpas', 'soniccouture', 'Nyckelharpas', 'nyckelharpas', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/nyckelharpas
  ('native-instruments', 'o-forbes-pipe-organ', 'cinesamples', 'O: Forbes Pipe Organ', 'o-forbes-pipe-organ', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/o-forbes-pipe-organ
  ('native-instruments', 'oblivion', 'heavyocity', 'OBLIVION', 'oblivion', 'synths'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/oblivion
  ('native-instruments', 'oblivion-drums', 'heavyocity', 'Oblivion Drums', 'oblivion-drums', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/oblivion-drums
  ('native-instruments', 'omega-keys-anthology', 'soundiron', 'Omega Keys Anthology', 'omega-keys-anthology', 'bundles'::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/omega-keys-anthology
  ('native-instruments', 'omnium-piano-collection', 'soundiron', 'Omnium Piano Collection', 'omnium-piano-collection', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/omnium-piano-collection
  ('native-instruments', 'ondes', 'soniccouture', 'Ondes', 'ondes', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/ondes
  ('native-instruments', 'ondioline', 'soniccouture', 'Ondioline', 'ondioline', 'synths'::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/ondioline
  ('native-instruments', 'orchestral-chimes-collection', 'soniccouture', 'Orchestral Chimes Collection', 'orchestral-chimes-collection', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/orchestral-chimes-collection
  ('native-instruments', 'orchestral-percussion-x3m', 'strezov-sampling', 'Orchestral Percussion X3M', 'orchestral-percussion-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/orchestral-percussion-x3m
  ('native-instruments', 'orchestral-strings', 'sonokinetic', 'Orchestral Strings', 'orchestral-strings', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/orchestral-strings
  ('native-instruments', 'ostinato', 'sonokinetic', 'Ostinato', 'ostinato', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/ostinato
  ('native-instruments', 'ostinato-brass', 'sonokinetic', 'Ostinato Brass', 'ostinato-brass', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/ostinato-brass
  ('native-instruments', 'ostinato-noir', 'sonokinetic', 'Ostinato Noir', 'ostinato-noir', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/ostinato-noir
  ('native-instruments', 'ostinato-woodwinds', 'sonokinetic', 'Ostinato Woodwinds', 'ostinato-woodwinds', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/ostinato-woodwinds
  ('native-instruments', 'output-essential-engines', 'output', 'Output Essentials Engines', 'output-essentials-engines', 'bundles'::text), -- published by Output, sold on the NI store | https://www.native-instruments.com/products/output-essential-engines
  ('native-instruments', 'ozone-elements', 'izotope', 'Ozone 12 Elements', 'ozone-12-elements', 'eq'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/ozone-elements
  ('native-instruments', 'pan-drums-ii', 'soniccouture', 'Pan Drums II', 'pan-drums-ii', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/pan-drums-ii
  ('native-instruments', 'percussion-essentials', 'strezov-sampling', 'Percussion Essentials', 'percussion-essentials', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/percussion-essentials
  ('native-instruments', 'phoenix', 'vir2-instruments', 'Phoenix: Rise, Hit & Whoosh Builder', 'phoenix-rise-hit-and-whoosh-builder', null::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/phoenix
  ('native-instruments', 'plasma', 'izotope', 'Plasma', 'plasma', 'saturation'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/plasma
  ('native-instruments', 'polarity-modular', 'soniccouture', 'Polarity Modular', 'polarity-modular', 'synths'::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/polarity-modular
  ('native-instruments', 'polarity-tension', 'soniccouture', 'Polarity Tension', 'polarity-tension', 'synths'::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/polarity-tension
  ('native-instruments', 'pro-tools-factory-essentials-instrument-library', 'avid', 'Pro Tools Factory Essentials', 'pro-tools-factory-essentials', null::text), -- published by Avid Technology, sold on the NI store | https://www.native-instruments.com/products/pro-tools-factory-essentials-instrument-library
  ('native-instruments', 'randys-prepared-piano', 'cinesamples', 'Randy''s Prepared Piano', 'randy-s-prepared-piano', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/randys-prepared-piano
  ('native-instruments', 'requiem-light-symphonic-choir', 'soundiron', 'Requiem Light Symphonic Choir', 'requiem-light-symphonic-choir', 'sample-libraries'::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/requiem-light-symphonic-choir
  ('native-instruments', 'rev-x-loops', 'output', 'Rev X-Loops', 'rev-x-loops', 'synths'::text), -- published by Output Audio, sold on the NI store | https://www.native-instruments.com/products/rev-x-loops
  ('native-instruments', 'rhodope-2-ethnic-bulgarian-choir', 'strezov-sampling', 'Rhodope 2 Ethnic Bulgarian Choir', 'rhodope-2-ethnic-bulgarian-choir', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/rhodope-2-ethnic-bulgarian-choir
  ('native-instruments', 'rhythmic-odyssey-vol-1', 'soundiron', 'Rhythmic Odyssey Vol 1', 'rhythmic-odyssey-vol-1', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/rhythmic-odyssey-vol-1
  ('native-instruments', 'rhythmic-odyssey-vol-2', 'soundiron', 'Rhythmic Odyssey Vol 2', 'rhythmic-odyssey-vol-2', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/rhythmic-odyssey-vol-2
  ('native-instruments', 'rhythmic-odyssey-vol-3', 'soundiron', 'Rhythmic Odyssey Vol 3', 'rhythmic-odyssey-vol-3', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/rhythmic-odyssey-vol-3
  ('native-instruments', 'rhythmic-odyssey-vol-4', 'soundiron', 'Rhythmic Odyssey Vol 4', 'rhythmic-odyssey-vol-4', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/rhythmic-odyssey-vol-4
  ('native-instruments', 'rhythmic-odyssey-vol-5', 'soundiron', 'Rhythmic Odyssey Vol 5', 'rhythmic-odyssey-vol-5', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/rhythmic-odyssey-vol-5
  ('native-instruments', 'rhythmic-textures', 'heavyocity', 'Rhythmic Textures', 'rhythmic-textures', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/rhythmic-textures
  ('native-instruments', 'rx-elements', 'izotope', 'RX 12 Elements', 'rx-12-elements', 'utilities'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/rx-elements
  ('native-instruments', 'saecula-organ-collection', 'soundiron', 'Saecula Organ Collection', 'saecula-organ-collection', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/saecula-organ-collection
  ('native-instruments', 'samulnori-percussion', 'soniccouture', 'Samulnori Percussion', 'samulnori-percussion', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/samulnori-percussion
  ('native-instruments', 'scoring-acoustic-guitars', 'heavyocity', 'Scoring Acoustic Guitars', 'scoring-acoustic-guitars', 'sample-libraries'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/scoring-acoustic-guitars
  ('native-instruments', 'scoring-bass', 'heavyocity', 'Scoring Bass', 'scoring-bass', 'sample-libraries'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/scoring-bass
  ('native-instruments', 'scoring-guitars', 'heavyocity', 'Scoring Guitars', 'scoring-guitars', 'sample-libraries'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/scoring-guitars
  ('native-instruments', 'scoring-guitars-2', 'heavyocity', 'Scoring Guitars 2', 'scoring-guitars-2', 'sample-libraries'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/scoring-guitars-2
  ('native-instruments', 'session-beats', 'wave-alchemy', 'Session Beats', 'session-beats', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/session-beats
  ('native-instruments', 'sheng-khaen-sho', 'soniccouture', 'Sheng Khaen Sho', 'sheng-khaen-sho', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/sheng-khaen-sho
  ('native-instruments', 'shimmer', 'soundiron', 'Shimmer', 'shimmer', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/shimmer
  ('native-instruments', 'shreddage-3-abyss', 'impact-soundworks', 'Shreddage 3 Abyss', 'shreddage-3-abyss', null::text), -- published by Impact Soundworks, sold on the NI store | https://www.native-instruments.com/products/shreddage-3-abyss
  ('native-instruments', 'skiddaw-stones', 'soniccouture', 'Skiddaw Stones', 'skiddaw-stones', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/skiddaw-stones
  ('native-instruments', 'solo-chamber-ensemble-strings', 'sample-modeling', 'Solo and Ensemble Strings', 'solo-and-ensemble-strings', 'bundles'::text), -- published by Sample Modeling, sold on the NI store | https://www.native-instruments.com/products/solo-chamber-ensemble-strings
  ('native-instruments', 'solo-textures', 'heavyocity', 'Solo Textures', 'solo-textures', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/solo-textures
  ('native-instruments', 'sonara', 'heavyocity', 'Sonara', 'sonara', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/sonara
  ('native-instruments', 'sordino-strings', 'sonokinetic', 'Sordino Strings', 'sordino-strings', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/sordino-strings
  ('native-instruments', 'soundiron-3', 'soundiron', 'Soundiron 3', 'soundiron-3', 'bundles'::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/soundiron-3
  ('native-instruments', 'soundiron-collection-2', 'soundiron', 'Soundiron Collection 2', 'soundiron-collection-2', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/soundiron-collection-2
  ('native-instruments', 'soundiron-vocal-3', 'soundiron', 'Soundiron Vocal 3', 'soundiron-vocal-3', 'bundles'::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/soundiron-vocal-3
  ('native-instruments', 'soundiron-vocal-suite-2', 'soundiron', 'Soundiron Vocal Suite 2', 'soundiron-vocal-suite-2', 'bundles'::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/soundiron-vocal-suite-2
  ('native-instruments', 'special-bows-i', 'orchestral-tools', 'Special Bows I', 'special-bows-i', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/special-bows-i
  ('native-instruments', 'special-bows-ii', 'orchestral-tools', 'Special Bows II', 'special-bows-ii', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/special-bows-ii
  ('native-instruments', 'street-percussion', 'big-fish-audio', 'Street Percussion', 'street-percussion', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/street-percussion
  ('native-instruments', 'sultan-drums', 'sonokinetic', 'Sultan Drums', 'sultan-drums', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/sultan-drums
  ('native-instruments', 'sun-drums', 'soniccouture', 'Sun Drums', 'sun-drums', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/sun-drums
  ('native-instruments', 'symphobia-4-pandora-core', 'projectsam', 'Symphobia 4 Pandora Core', 'symphobia-4-pandora-core', null::text), -- published by ProjectSAM, sold on the NI store | https://www.native-instruments.com/products/symphobia-4-pandora-core
  ('native-instruments', 'symphonic-destruction', 'heavyocity', 'Symphonic Destruction', 'symphonic-destruction', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/symphonic-destruction
  ('native-instruments', 'symphonic-destruction-redux', 'heavyocity', 'Symphonic Destruction Redux', 'symphonic-destruction-redux', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/symphonic-destruction-redux
  ('native-instruments', 'synthetic-strings', 'heavyocity', 'Synthetic Strings', 'synthetic-strings', 'sample-libraries'::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/synthetic-strings
  ('native-instruments', 'taikos-x3m', 'strezov-sampling', 'Taikos X3M', 'taikos-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/taikos-x3m
  ('native-instruments', 'taylor-davis', 'cinesamples', 'Taylor Davis', 'taylor-davis', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/taylor-davis
  ('native-instruments', 'texture-rhythm-bundle', 'sonuscore', 'Texture & Rhythm Bundle', 'texture-and-rhythm-bundle', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/texture-rhythm-bundle
  ('native-instruments', 'the-attic-2', 'soniccouture', 'The Attic 2', 'the-attic-2', 'synths'::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/the-attic-2
  ('native-instruments', 'the-canterbury-suitcase', 'soniccouture', 'The Canterbury Suitcase', 'the-canterbury-suitcase', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/the-canterbury-suitcase
  ('native-instruments', 'the-felt-seiler-pro', 'strezov-sampling', 'The Felt Seiler Pro', 'the-felt-seiler-pro', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/the-felt-seiler-pro
  ('native-instruments', 'the-performers-anonym-gregorian-choir', 'strezov-sampling', 'The Performers Anonym Gregorian Choir', 'the-performers-anonym-gregorian-choir', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/the-performers-anonym-gregorian-choir
  ('native-instruments', 'the-performers-anonym-orthodox-choir', 'strezov-sampling', 'The Performers Anonym Orthodox Choir', 'the-performers-anonym-orthodox-choir', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/the-performers-anonym-orthodox-choir
  ('native-instruments', 'the-performers-mountain-girl', 'strezov-sampling', 'The Performers Mountain Girl', 'the-performers-mountain-girl', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/the-performers-mountain-girl
  ('native-instruments', 'the-pulse', 'sonuscore', 'The Pulse', 'the-pulse', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/the-pulse
  ('native-instruments', 'the-scoring-collection', 'heavyocity', 'The Scoring Collection', 'the-scoring-collection', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/the-scoring-collection
  ('native-instruments', 'the-scoring-collection-2', 'heavyocity', 'The Scoring Collection 2', 'the-scoring-collection-2', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/the-scoring-collection-2
  ('native-instruments', 'the-watchmaker', 'sonokinetic', 'The Watchmaker', 'the-watchmaker', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/the-watchmaker
  ('native-instruments', 'theremin-plus', 'soundiron', 'Theremin Plus', 'theremin-plus', 'synths'::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/theremin-plus
  ('native-instruments', 'threnody-strings', 'soniccouture', 'Threnody Strings', 'threnody-strings', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/threnody-strings
  ('native-instruments', 'thunder-x3m', 'strezov-sampling', 'Thunder X3M', 'thunder-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/thunder-x3m
  ('native-instruments', 'time-macro', 'orchestral-tools', 'Time Macro', 'time-macro', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/time-macro
  ('native-instruments', 'time-micro', 'orchestral-tools', 'Time Micro', 'time-micro', null::text), -- published by Orchestral Tools, sold on the NI store | https://www.native-instruments.com/products/time-micro
  ('native-instruments', 'time-textures-expanded', 'sonuscore', 'Time Textures Expanded', 'time-textures-expanded', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/time-textures-expanded
  ('native-instruments', 'tina-guo-acoustic-cello-legato', 'cinesamples', 'Tina Guo Acoustic Cello Legato', 'tina-guo-acoustic-cello-legato', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/tina-guo-acoustic-cello-legato
  ('native-instruments', 'tina-guo-vol-2', 'cinesamples', 'Tina Guo Vol 2', 'tina-guo-vol-2', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/tina-guo-vol-2
  ('native-instruments', 'tingklik', 'soniccouture', 'Tingklik', 'tingklik', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/tingklik
  ('native-instruments', 'toccata', 'sonokinetic', 'Toccata', 'toccata', null::text), -- published by Sonokinetic, sold on the NI store | https://www.native-instruments.com/products/toccata
  ('native-instruments', 'toms-x3m', 'strezov-sampling', 'Toms X3M', 'toms-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/toms-x3m
  ('native-instruments', 'tonal-drums', 'soniccouture', 'Tonal Drums', 'tonal-drums', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/tonal-drums
  ('native-instruments', 'trinity-drums-2', 'sonuscore', 'Trinity Drums 2', 'trinity-drums-2', null::text), -- published by Sonuscore, sold on the NI store | https://www.native-instruments.com/products/trinity-drums-2
  ('native-instruments', 'tropar', 'strezov-sampling', 'Tropar', 'tropar', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/tropar
  ('native-instruments', 'tupans-x3m', 'strezov-sampling', 'Tupans X3M', 'tupans-x3m', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/tupans-x3m
  ('native-instruments', 'uncharted-88', 'heavyocity', 'UNCHARTED 88', 'uncharted-88', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/uncharted-88
  ('native-instruments', 'vea', 'izotope', 'VEA', 'vea', 'utilities'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/vea
  ('native-instruments', 'velvet', 'izotope', 'Velvet', 'velvet', 'utilities'::text), -- published by iZotope, sold on the NI store | https://www.native-instruments.com/products/velvet
  ('native-instruments', 'velvet-vibes', 'wave-alchemy', 'Velvet Vibes', 'velvet-vibes', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/velvet-vibes
  ('native-instruments', 'vento-essentials', 'heavyocity', 'Vento Essentials', 'vento-essentials', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/vento-essentials
  ('native-instruments', 'vibraphone', 'soniccouture', 'Vibraphone', 'vibraphone', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/vibraphone
  ('native-instruments', 'vintage-horns', 'big-fish-audio', 'Vintage Horns', 'vintage-horns', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/vintage-horns
  ('native-instruments', 'vintage-horns-2', 'big-fish-audio', 'Vintage Horns 2', 'vintage-horns-2', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/vintage-horns-2
  ('native-instruments', 'vintage-keys-collection', 'soundiron', 'Vintage Keys Collection', 'vintage-keys-collection', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/vintage-keys-collection
  ('native-instruments', 'vintage-vocals', 'big-fish-audio', 'Vintage Vocals', 'vintage-vocals', null::text), -- published by BIG FISH AUDIO, sold on the NI store | https://www.native-instruments.com/products/vintage-vocals
  ('native-instruments', 'vital-series-mallets', 'vir2-instruments', 'Vital Series: Mallets', 'vital-series-mallets', null::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/vital-series-mallets
  ('native-instruments', 'vital-series-sticks', 'vir2-instruments', 'Vital Series: Sticks', 'vital-series-sticks', null::text), -- published by Vir2 Instruments, sold on the NI store | https://www.native-instruments.com/products/vital-series-sticks
  ('native-instruments', 'vocalise', 'heavyocity', 'Vocalise', 'vocalise', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/vocalise
  ('native-instruments', 'vocalise-2', 'heavyocity', 'Vocalise 2', 'vocalise-2', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/vocalise-2
  ('native-instruments', 'vocalise-3', 'heavyocity', 'Vocalise 3', 'vocalise-3', null::text), -- published by Heavyocity Media, sold on the NI store | https://www.native-instruments.com/products/vocalise-3
  ('native-instruments', 'vocoflex', 'dreamtonics', 'Vocoflex', 'vocoflex', 'utilities'::text), -- published by Dreamtonics, sold on the NI store | https://www.native-instruments.com/products/vocoflex
  ('native-instruments', 'voice-of-wind-adey', 'soundiron', 'Voice Of Wind: Adey', 'voice-of-wind-adey', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/voice-of-wind-adey
  ('native-instruments', 'voices-of-gaia', 'soundiron', 'Voices Of Gaia', 'voices-of-gaia', null::text), -- published by Soundiron, sold on the NI store | https://www.native-instruments.com/products/voices-of-gaia
  ('native-instruments', 'voices-of-rhodope-anna', 'strezov-sampling', 'Voices of Rhodope - Anna', 'voices-of-rhodope-anna', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/voices-of-rhodope-anna
  ('native-instruments', 'voices-of-war-men-of-the-north', 'cinesamples', 'Voices of War - Men of the North', 'voices-of-war-men-of-the-north', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/voices-of-war-men-of-the-north
  ('native-instruments', 'voltage-pop', 'wave-alchemy', 'Voltage Pop', 'voltage-pop', null::text), -- published by Wave Alchemy, sold on the NI store | https://www.native-instruments.com/products/voltage-pop
  ('native-instruments', 'voxos-epic-choirs', 'cinesamples', 'VOXOS Epic Choir', 'voxos-epic-choir', null::text), -- published by Cinesamples, sold on the NI store | https://www.native-instruments.com/products/voxos-epic-choirs
  ('native-instruments', 'wassolou-balafon', 'soniccouture', 'Wassolou Balafon', 'wassolou-balafon', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/wassolou-balafon
  ('native-instruments', 'waterphone', 'soniccouture', 'Waterphone', 'waterphone', null::text), -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/waterphone
  ('native-instruments', 'wotan-male-choir', 'strezov-sampling', 'Wotan Male Choir', 'wotan-male-choir', null::text), -- published by Strezov Sampling, sold on the NI store | https://www.native-instruments.com/products/wotan-male-choir
  ('native-instruments', 'xtended-piano', 'soniccouture', 'Xtended Piano', 'xtended-piano', null::text) -- published by Soniccouture, sold on the NI store | https://www.native-instruments.com/products/xtended-piano
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (87)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('native-instruments', 'afflatus-chapter-i-strings', 'strezov-sampling', 'afflatus-chapter-i-strings'), -- already listed under Strezov Sampling (its real publisher) | https://www.native-instruments.com/products/afflatus-chapter-i-strings
  ('native-instruments', 'analog-brass-and-winds', 'output', 'analog-brass-winds'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/analog-brass-and-winds
  ('native-instruments', 'analog-strings', 'output', 'analog-strings'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/analog-strings
  ('native-instruments', 'anthology-strings', '8dio', 'anthology-strings'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/anthology-strings
  ('native-instruments', 'berlin-brass', 'orchestral-tools', 'berlin-brass'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/berlin-brass
  ('native-instruments', 'berlin-strings', 'orchestral-tools', 'berlin-strings'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/berlin-strings
  ('native-instruments', 'berlin-woodwinds', 'orchestral-tools', 'berlin-woodwinds'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/berlin-woodwinds
  ('native-instruments', 'cage-bundle', '8dio', 'cage-bundle'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/cage-bundle
  ('native-instruments', 'century-ensemble-brass-bundle', '8dio', 'century-ensemble-brass-bundle'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/century-ensemble-brass-bundle
  ('native-instruments', 'century-ostinato-strings', '8dio', 'century-ostinato-strings'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/century-ostinato-strings
  ('native-instruments', 'cinebrass-core', 'cinesamples', 'cinebrass-core'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cinebrass-core
  ('native-instruments', 'cineperc', 'cinesamples', 'cineperc'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cineperc
  ('native-instruments', 'cinestrings-core', 'cinesamples', 'cinestrings-core'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cinestrings-core
  ('native-instruments', 'cinewinds-core', 'cinesamples', 'cinewinds-core'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cinewinds-core
  ('native-instruments', 'claire-woodwinds-bundle', '8dio', 'claire-woodwinds-bundle'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/claire-woodwinds-bundle
  ('native-instruments', 'colour-copy', 'u-he', 'colour-copy'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/colour-copy
  ('native-instruments', 'da-capo', 'sonokinetic', 'da-capo'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/da-capo
  ('native-instruments', 'damage-2', 'heavyocity', 'damage-2'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/damage-2
  ('native-instruments', 'darbuka-x3m', 'strezov-sampling', 'darbuka-x3m'), -- already listed under Strezov Sampling (its real publisher) | https://www.native-instruments.com/products/darbuka-x3m
  ('native-instruments', 'diva', 'u-he', 'diva'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/diva
  ('native-instruments', 'equinox', 'izotope', 'equinox'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/equinox
  ('native-instruments', 'exhale', 'output', 'exhale'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/exhale
  ('native-instruments', 'forzo', 'heavyocity', 'forzo'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/forzo
  ('native-instruments', 'gravity', 'heavyocity', 'gravity'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/gravity
  ('native-instruments', 'grosso', 'sonokinetic', 'grosso'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/grosso
  ('native-instruments', 'hive-2', 'u-he', 'hive-2'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/hive-2
  ('native-instruments', 'humanoid', 'baby-audio', 'humanoid'), -- already listed under Baby Audio (its real publisher) | https://www.native-instruments.com/products/humanoid
  ('native-instruments', 'hybrid-tools-4', '8dio', 'hybrid-tools-4'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/hybrid-tools-4
  ('native-instruments', 'hybrid-tools-neo', '8dio', 'hybrid-tools-neo'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/hybrid-tools-neo
  ('native-instruments', 'hybrid-tools-terminus', '8dio', 'hybrid-tools-terminus'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/hybrid-tools-terminus
  ('native-instruments', 'insight', 'izotope', 'insight-2'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/insight
  ('native-instruments', 'insolidus-choir', '8dio', 'insolidus-choir'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/insolidus-choir
  ('native-instruments', 'intimate-studio-strings', '8dio', 'intimate-studio-strings'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/intimate-studio-strings
  ('native-instruments', 'invasion', 'getgood-drums', 'invasion'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/invasion
  ('native-instruments', 'konkrete', 'soniccouture', 'konkrete-3'), -- already listed under Soniccouture (its real publisher) | https://www.native-instruments.com/products/konkrete
  ('native-instruments', 'lacrimosa-choir', '8dio', 'lacrimosa-choir'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/lacrimosa-choir
  ('native-instruments', 'legion-series-33-drummers-batucada', '8dio', 'legion-series-33-drummers-batucada'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/legion-series-33-drummers-batucada
  ('native-instruments', 'legion-series-66-cellos', '8dio', 'legion-series-66-cellos'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/legion-series-66-cellos
  ('native-instruments', 'legion-series-66-trombones', '8dio', 'legion-series-66-trombones'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/legion-series-66-trombones
  ('native-instruments', 'lineage-strings', 'projectsam', 'lineage-strings'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/lineage-strings
  ('native-instruments', 'matt-halpern-signature-pack', 'getgood-drums', 'matt-halpern-signature-pack'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/matt-halpern-signature-pack
  ('native-instruments', 'metropolis-ark-1', 'orchestral-tools', 'metropolis-ark-1'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/metropolis-ark-1
  ('native-instruments', 'minimal', 'sonokinetic', 'minimal'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/minimal
  ('native-instruments', 'modern-massive', 'getgood-drums', 'modern-massive'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/modern-massive
  ('native-instruments', 'mosaic-voices', 'heavyocity', 'mosaic-voices'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/mosaic-voices
  ('native-instruments', 'music-production-suite', 'izotope', 'music-production-suite-9'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/music-production-suite
  ('native-instruments', 'nectar-advanced', 'izotope', 'nectar-4-advanced'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/nectar-advanced
  ('native-instruments', 'neoverb', 'izotope', 'neoverb'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/neoverb
  ('native-instruments', 'neutron', 'izotope', 'neutron-5'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/neutron
  ('native-instruments', 'novo', 'heavyocity', 'novo'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/novo
  ('native-instruments', 'novo-essentials', 'heavyocity', 'novo-essentials'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/novo-essentials
  ('native-instruments', 'orchestral-essentials', 'projectsam', 'orchestral-essentials'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/orchestral-essentials
  ('native-instruments', 'orchestral-essentials-2', 'projectsam', 'orchestral-essentials-2'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/orchestral-essentials-2
  ('native-instruments', 'ozone-advanced', 'izotope', 'ozone-12-advanced'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/ozone-advanced
  ('native-instruments', 'ozone-standard', 'izotope', 'ozone-12-standard'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/ozone-standard
  ('native-instruments', 'p-iv-matt-halpern-signature-pack', 'getgood-drums', 'matt-halpern-signature-pack'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/p-iv-matt-halpern-signature-pack
  ('native-instruments', 'presswerk', 'u-he', 'presswerk'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/presswerk
  ('native-instruments', 'repro', 'u-he', 'repro'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/repro
  ('native-instruments', 'requiem-professional', '8dio', 'requiem-professional'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/requiem-professional
  ('native-instruments', 'rev', 'output', 'rev'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/rev
  ('native-instruments', 'rx-advanced', 'izotope', 'rx-12-advanced'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/rx-advanced
  ('native-instruments', 'rx-post-production-suite', 'izotope', 'rx-post-production-suite-9'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/rx-post-production-suite
  ('native-instruments', 'rx-standard', 'izotope', 'rx-12-standard'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/rx-standard
  ('native-instruments', 'satin', 'u-he', 'satin'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/satin
  ('native-instruments', 'signal', 'output', 'signal'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/signal
  ('native-instruments', 'sotto', 'sonokinetic', 'sotto'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/sotto
  ('native-instruments', 'stormchoir-ultimate', 'strezov-sampling', 'storm-choir-ultimate'), -- already listed under Strezov Sampling (its real publisher) | https://www.native-instruments.com/products/stormchoir-ultimate
  ('native-instruments', 'studio-sopranos', '8dio', 'studio-sopranos'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/studio-sopranos
  ('native-instruments', 'stutter-edit-2', 'izotope', 'stutter-edit-2'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/stutter-edit-2
  ('native-instruments', 'substance', 'output', 'substance'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/substance
  ('native-instruments', 'swing', 'projectsam', 'swing'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/swing
  ('native-instruments', 'swing-more', 'projectsam', 'swing-more'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/swing-more
  ('native-instruments', 'symphobia-1', 'projectsam', 'symphobia'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-1
  ('native-instruments', 'symphobia-2', 'projectsam', 'symphobia-2'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-2
  ('native-instruments', 'symphobia-3', 'projectsam', 'symphobia-3-lumina'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-3
  ('native-instruments', 'symphobia-4-pandora', 'projectsam', 'symphobia-4-pandora'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-4-pandora
  ('native-instruments', 'synthesizer-v-studio-2-pro', 'dreamtonics', 'synthesizer-v-studio-2-pro'), -- already listed under Dreamtonics (its real publisher) | https://www.native-instruments.com/products/synthesizer-v-studio-2-pro
  ('native-instruments', 'taip', 'baby-audio', 'taip'), -- already listed under Baby Audio (its real publisher) | https://www.native-instruments.com/products/taip
  ('native-instruments', 'tonal-balance-control-3', 'izotope', 'tonal-balance-control-3'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/tonal-balance-control-3
  ('native-instruments', 'transit-2', 'baby-audio', 'transit-2'), -- already listed under Baby Audio (its real publisher) | https://www.native-instruments.com/products/transit-2
  ('native-instruments', 'trash', 'izotope', 'trash'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/trash
  ('native-instruments', 'true-strike-1', 'projectsam', 'true-strike-1'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/true-strike-1
  ('native-instruments', 'tutti-vox', 'sonokinetic', 'tutti-vox'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/tutti-vox
  ('native-instruments', 'twangstrom', 'u-he', 'twangstrom'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/twangstrom
  ('native-instruments', 'vento', 'heavyocity', 'vento'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/vento
  ('native-instruments', 'vocalsynth', 'izotope', 'vocalsynth-2'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/vocalsynth
  ('native-instruments', 'voices-of-rapture', 'soundiron', 'voices-of-rapture') -- already listed under Soundiron (its real publisher) | https://www.native-instruments.com/products/voices-of-rapture
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
  ('native-instruments', 'afflatus-chapter-i-strings', 'strezov-sampling', 'afflatus-chapter-i-strings'), -- already listed under Strezov Sampling (its real publisher) | https://www.native-instruments.com/products/afflatus-chapter-i-strings
  ('native-instruments', 'analog-brass-and-winds', 'output', 'analog-brass-winds'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/analog-brass-and-winds
  ('native-instruments', 'analog-strings', 'output', 'analog-strings'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/analog-strings
  ('native-instruments', 'anthology-strings', '8dio', 'anthology-strings'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/anthology-strings
  ('native-instruments', 'berlin-brass', 'orchestral-tools', 'berlin-brass'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/berlin-brass
  ('native-instruments', 'berlin-strings', 'orchestral-tools', 'berlin-strings'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/berlin-strings
  ('native-instruments', 'berlin-woodwinds', 'orchestral-tools', 'berlin-woodwinds'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/berlin-woodwinds
  ('native-instruments', 'cage-bundle', '8dio', 'cage-bundle'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/cage-bundle
  ('native-instruments', 'century-ensemble-brass-bundle', '8dio', 'century-ensemble-brass-bundle'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/century-ensemble-brass-bundle
  ('native-instruments', 'century-ostinato-strings', '8dio', 'century-ostinato-strings'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/century-ostinato-strings
  ('native-instruments', 'cinebrass-core', 'cinesamples', 'cinebrass-core'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cinebrass-core
  ('native-instruments', 'cineperc', 'cinesamples', 'cineperc'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cineperc
  ('native-instruments', 'cinestrings-core', 'cinesamples', 'cinestrings-core'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cinestrings-core
  ('native-instruments', 'cinewinds-core', 'cinesamples', 'cinewinds-core'), -- already listed under Cinesamples (its real publisher) | https://www.native-instruments.com/products/cinewinds-core
  ('native-instruments', 'claire-woodwinds-bundle', '8dio', 'claire-woodwinds-bundle'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/claire-woodwinds-bundle
  ('native-instruments', 'colour-copy', 'u-he', 'colour-copy'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/colour-copy
  ('native-instruments', 'da-capo', 'sonokinetic', 'da-capo'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/da-capo
  ('native-instruments', 'damage-2', 'heavyocity', 'damage-2'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/damage-2
  ('native-instruments', 'darbuka-x3m', 'strezov-sampling', 'darbuka-x3m'), -- already listed under Strezov Sampling (its real publisher) | https://www.native-instruments.com/products/darbuka-x3m
  ('native-instruments', 'diva', 'u-he', 'diva'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/diva
  ('native-instruments', 'equinox', 'izotope', 'equinox'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/equinox
  ('native-instruments', 'exhale', 'output', 'exhale'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/exhale
  ('native-instruments', 'forzo', 'heavyocity', 'forzo'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/forzo
  ('native-instruments', 'gravity', 'heavyocity', 'gravity'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/gravity
  ('native-instruments', 'grosso', 'sonokinetic', 'grosso'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/grosso
  ('native-instruments', 'hive-2', 'u-he', 'hive-2'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/hive-2
  ('native-instruments', 'humanoid', 'baby-audio', 'humanoid'), -- already listed under Baby Audio (its real publisher) | https://www.native-instruments.com/products/humanoid
  ('native-instruments', 'hybrid-tools-4', '8dio', 'hybrid-tools-4'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/hybrid-tools-4
  ('native-instruments', 'hybrid-tools-neo', '8dio', 'hybrid-tools-neo'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/hybrid-tools-neo
  ('native-instruments', 'hybrid-tools-terminus', '8dio', 'hybrid-tools-terminus'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/hybrid-tools-terminus
  ('native-instruments', 'insight', 'izotope', 'insight-2'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/insight
  ('native-instruments', 'insolidus-choir', '8dio', 'insolidus-choir'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/insolidus-choir
  ('native-instruments', 'intimate-studio-strings', '8dio', 'intimate-studio-strings'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/intimate-studio-strings
  ('native-instruments', 'invasion', 'getgood-drums', 'invasion'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/invasion
  ('native-instruments', 'konkrete', 'soniccouture', 'konkrete-3'), -- already listed under Soniccouture (its real publisher) | https://www.native-instruments.com/products/konkrete
  ('native-instruments', 'lacrimosa-choir', '8dio', 'lacrimosa-choir'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/lacrimosa-choir
  ('native-instruments', 'legion-series-33-drummers-batucada', '8dio', 'legion-series-33-drummers-batucada'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/legion-series-33-drummers-batucada
  ('native-instruments', 'legion-series-66-cellos', '8dio', 'legion-series-66-cellos'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/legion-series-66-cellos
  ('native-instruments', 'legion-series-66-trombones', '8dio', 'legion-series-66-trombones'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/legion-series-66-trombones
  ('native-instruments', 'lineage-strings', 'projectsam', 'lineage-strings'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/lineage-strings
  ('native-instruments', 'matt-halpern-signature-pack', 'getgood-drums', 'matt-halpern-signature-pack'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/matt-halpern-signature-pack
  ('native-instruments', 'metropolis-ark-1', 'orchestral-tools', 'metropolis-ark-1'), -- already listed under Orchestral Tools (its real publisher) | https://www.native-instruments.com/products/metropolis-ark-1
  ('native-instruments', 'minimal', 'sonokinetic', 'minimal'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/minimal
  ('native-instruments', 'modern-massive', 'getgood-drums', 'modern-massive'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/modern-massive
  ('native-instruments', 'mosaic-voices', 'heavyocity', 'mosaic-voices'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/mosaic-voices
  ('native-instruments', 'music-production-suite', 'izotope', 'music-production-suite-9'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/music-production-suite
  ('native-instruments', 'nectar-advanced', 'izotope', 'nectar-4-advanced'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/nectar-advanced
  ('native-instruments', 'neoverb', 'izotope', 'neoverb'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/neoverb
  ('native-instruments', 'neutron', 'izotope', 'neutron-5'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/neutron
  ('native-instruments', 'novo', 'heavyocity', 'novo'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/novo
  ('native-instruments', 'novo-essentials', 'heavyocity', 'novo-essentials'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/novo-essentials
  ('native-instruments', 'orchestral-essentials', 'projectsam', 'orchestral-essentials'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/orchestral-essentials
  ('native-instruments', 'orchestral-essentials-2', 'projectsam', 'orchestral-essentials-2'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/orchestral-essentials-2
  ('native-instruments', 'ozone-advanced', 'izotope', 'ozone-12-advanced'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/ozone-advanced
  ('native-instruments', 'ozone-standard', 'izotope', 'ozone-12-standard'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/ozone-standard
  ('native-instruments', 'p-iv-matt-halpern-signature-pack', 'getgood-drums', 'matt-halpern-signature-pack'), -- already listed under GetGood Drums (its real publisher) | https://www.native-instruments.com/products/p-iv-matt-halpern-signature-pack
  ('native-instruments', 'presswerk', 'u-he', 'presswerk'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/presswerk
  ('native-instruments', 'repro', 'u-he', 'repro'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/repro
  ('native-instruments', 'requiem-professional', '8dio', 'requiem-professional'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/requiem-professional
  ('native-instruments', 'rev', 'output', 'rev'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/rev
  ('native-instruments', 'rx-advanced', 'izotope', 'rx-12-advanced'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/rx-advanced
  ('native-instruments', 'rx-post-production-suite', 'izotope', 'rx-post-production-suite-9'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/rx-post-production-suite
  ('native-instruments', 'rx-standard', 'izotope', 'rx-12-standard'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/rx-standard
  ('native-instruments', 'satin', 'u-he', 'satin'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/satin
  ('native-instruments', 'signal', 'output', 'signal'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/signal
  ('native-instruments', 'sotto', 'sonokinetic', 'sotto'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/sotto
  ('native-instruments', 'stormchoir-ultimate', 'strezov-sampling', 'storm-choir-ultimate'), -- already listed under Strezov Sampling (its real publisher) | https://www.native-instruments.com/products/stormchoir-ultimate
  ('native-instruments', 'studio-sopranos', '8dio', 'studio-sopranos'), -- already listed under 8Dio (its real publisher) | https://www.native-instruments.com/products/studio-sopranos
  ('native-instruments', 'stutter-edit-2', 'izotope', 'stutter-edit-2'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/stutter-edit-2
  ('native-instruments', 'substance', 'output', 'substance'), -- already listed under Output (its real publisher) | https://www.native-instruments.com/products/substance
  ('native-instruments', 'swing', 'projectsam', 'swing'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/swing
  ('native-instruments', 'swing-more', 'projectsam', 'swing-more'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/swing-more
  ('native-instruments', 'symphobia-1', 'projectsam', 'symphobia'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-1
  ('native-instruments', 'symphobia-2', 'projectsam', 'symphobia-2'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-2
  ('native-instruments', 'symphobia-3', 'projectsam', 'symphobia-3-lumina'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-3
  ('native-instruments', 'symphobia-4-pandora', 'projectsam', 'symphobia-4-pandora'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/symphobia-4-pandora
  ('native-instruments', 'synthesizer-v-studio-2-pro', 'dreamtonics', 'synthesizer-v-studio-2-pro'), -- already listed under Dreamtonics (its real publisher) | https://www.native-instruments.com/products/synthesizer-v-studio-2-pro
  ('native-instruments', 'taip', 'baby-audio', 'taip'), -- already listed under Baby Audio (its real publisher) | https://www.native-instruments.com/products/taip
  ('native-instruments', 'tonal-balance-control-3', 'izotope', 'tonal-balance-control-3'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/tonal-balance-control-3
  ('native-instruments', 'transit-2', 'baby-audio', 'transit-2'), -- already listed under Baby Audio (its real publisher) | https://www.native-instruments.com/products/transit-2
  ('native-instruments', 'trash', 'izotope', 'trash'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/trash
  ('native-instruments', 'true-strike-1', 'projectsam', 'true-strike-1'), -- already listed under ProjectSAM (its real publisher) | https://www.native-instruments.com/products/true-strike-1
  ('native-instruments', 'tutti-vox', 'sonokinetic', 'tutti-vox'), -- already listed under Sonokinetic (its real publisher) | https://www.native-instruments.com/products/tutti-vox
  ('native-instruments', 'twangstrom', 'u-he', 'twangstrom'), -- already listed under u-he (its real publisher) | https://www.native-instruments.com/products/twangstrom
  ('native-instruments', 'vento', 'heavyocity', 'vento'), -- already listed under Heavyocity (its real publisher) | https://www.native-instruments.com/products/vento
  ('native-instruments', 'vocalsynth', 'izotope', 'vocalsynth-2'), -- already listed under iZotope (its real publisher) | https://www.native-instruments.com/products/vocalsynth
  ('native-instruments', 'voices-of-rapture', 'soundiron', 'voices-of-rapture') -- already listed under Soundiron (its real publisher) | https://www.native-instruments.com/products/voices-of-rapture
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Spelling / official name (slug unchanged) (101)
update public.plugins p set name = v.name
from public.developers d, (values
  ('native-instruments', '24k-drums', '24K Drums'), -- official product name | https://www.native-instruments.com/products/24k-drums
  ('native-instruments', '24k-keys', '24K Keys'), -- official product name | https://www.native-instruments.com/products/24k-keys
  ('native-instruments', '40s-very-own-drums', '40''s Very Own Drums'), -- official product name | https://www.native-instruments.com/products/40s-very-own-drums
  ('native-instruments', '40s-very-own-keys', '40''s Very Own Keys'), -- official product name | https://www.native-instruments.com/products/40s-very-own-keys
  ('native-instruments', 'alicias-keys', 'Alicia''s Keys'), -- official product name | https://www.native-instruments.com/products/alicias-keys
  ('native-instruments', 'analog-dreams-mpc-edition', 'Analog Dreams MPC Edition'), -- official product name | https://www.native-instruments.com/products/analog-dreams-mpc-edition
  ('native-instruments', 'arkhis-sequis-bundle', 'Arkhis + Sequis Bundle'), -- official product name | https://www.native-instruments.com/products/arkhis-sequis-bundle
  ('native-instruments', 'artist-expansion-bazzazian', 'Bazzazian'), -- official product name | https://www.native-instruments.com/products/artist-expansion-bazzazian
  ('native-instruments', 'artist-expansion-dj-khalil', 'DJ Khalil'), -- official product name | https://www.native-instruments.com/products/artist-expansion-dj-khalil
  ('native-instruments', 'artist-expansion-sasha', 'Sasha'), -- official product name | https://www.native-instruments.com/products/artist-expansion-sasha
  ('native-instruments', 'artist-expansion-the-stereotypes', 'The Stereotypes'), -- official product name | https://www.native-instruments.com/products/artist-expansion-the-stereotypes
  ('native-instruments', 'brass-n-bounce', 'Brass n Bounce'), -- official product name | https://www.native-instruments.com/products/brass-n-bounce
  ('native-instruments', 'choir-omnia', 'Choir: Omnia'), -- official product name | https://www.native-instruments.com/products/choir-omnia
  ('native-instruments', 'choir-omnia-essentials', 'Choir: Omnia Essentials'), -- official product name | https://www.native-instruments.com/products/choir-omnia-essentials
  ('native-instruments', 'cloud-supply-mpc-edition', 'Cloud Supply MPC Edition'), -- official product name | https://www.native-instruments.com/products/cloud-supply-mpc-edition
  ('native-instruments', 'cremona-quartet', 'Cremona Quartet Solo'), -- official product name | https://www.native-instruments.com/products/cremona-quartet
  ('native-instruments', 'disco-funk', 'Disco and Funk'), -- official product name | https://www.native-instruments.com/products/disco-funk
  ('native-instruments', 'duets-mpc-edition', 'Duets MPC Edition'), -- official product name | https://www.native-instruments.com/products/duets-mpc-edition
  ('native-instruments', 'east-asia', 'Spotlight Collection: East Asia'), -- official product name | https://www.native-instruments.com/products/east-asia
  ('native-instruments', 'effects-series-crush-pack', 'Effects Series - Crush Pack'), -- official product name | https://www.native-instruments.com/products/effects-series-crush-pack
  ('native-instruments', 'effects-series-mod-pack', 'Effects Series - Mod Pack'), -- official product name | https://www.native-instruments.com/products/effects-series-mod-pack
  ('native-instruments', 'electric-keys-reeds-duo', 'Electric Keys - Reeds Duo'), -- official product name | https://www.native-instruments.com/products/electric-keys-reeds-duo
  ('native-instruments', 'electric-keys-timber-duo', 'Electric Keys - Timber Duo'), -- official product name | https://www.native-instruments.com/products/electric-keys-timber-duo
  ('native-instruments', 'electric-keys-tines-duo', 'Electric Keys - Tines Duo'), -- official product name | https://www.native-instruments.com/products/electric-keys-tines-duo
  ('native-instruments', 'feel-it-mpc-edition', 'Feel It MPC Edition'), -- official product name | https://www.native-instruments.com/products/feel-it-mpc-edition
  ('native-instruments', 'homage-mpc-edition', 'Homage MPC Edition'), -- official product name | https://www.native-instruments.com/products/homage-mpc-edition
  ('native-instruments', 'ignition-keys-mpc-edition', 'Ignition Keys MPC Edition'), -- official product name | https://www.native-instruments.com/products/ignition-keys-mpc-edition
  ('native-instruments', 'ireland', 'Spotlight Collection: Ireland'), -- official product name | https://www.native-instruments.com/products/ireland
  ('native-instruments', 'komplete-select-band', 'Komplete Select - Band'), -- official product name | https://www.native-instruments.com/products/komplete-select-band
  ('native-instruments', 'komplete-select-beats', 'Komplete Select - Beats'), -- official product name | https://www.native-instruments.com/products/komplete-select-beats
  ('native-instruments', 'komplete-select-electronic', 'Komplete Select - Electronic'), -- official product name | https://www.native-instruments.com/products/komplete-select-electronic
  ('native-instruments', 'light-trilogy', 'Straylight + Pharlight + Ashlight Bundle'), -- official product name | https://www.native-instruments.com/products/light-trilogy
  ('native-instruments', 'lo-fi-glow', 'Lo-fi Glow'), -- official product name | https://www.native-instruments.com/products/lo-fi-glow
  ('native-instruments', 'lo-fi-samples-bundle', 'Lo-fi Samples Bundle'), -- official product name | https://www.native-instruments.com/products/lo-fi-samples-bundle
  ('native-instruments', 'lofi-chill-plucks', 'Lo-fi & Chill Plucks'), -- official product name | https://www.native-instruments.com/products/lofi-chill-plucks
  ('native-instruments', 'luxa-mpc-edition', 'Luxa MPC Edition'), -- official product name | https://www.native-instruments.com/products/luxa-mpc-edition
  ('native-instruments', 'maschine-3', 'Maschine 3 including Maschine Central'), -- official product name | https://www.native-instruments.com/products/maschine-3
  ('native-instruments', 'melted-vibes-mpc-edition', 'Melted Vibes MPC Edition'), -- official product name | https://www.native-instruments.com/products/melted-vibes-mpc-edition
  ('native-instruments', 'mpc-expansion-drift-theory', 'Drift Theory MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-drift-theory
  ('native-instruments', 'mpc-expansion-faded-reels', 'Faded Reels MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-faded-reels
  ('native-instruments', 'mpc-expansion-global-shake', 'Global Shake MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-global-shake
  ('native-instruments', 'mpc-expansion-hazy-days', 'Hazy Days MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-hazy-days
  ('native-instruments', 'mpc-expansion-infinite-escape', 'Infinite Escape MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-infinite-escape
  ('native-instruments', 'mpc-expansion-lone-forest', 'Lone Forest MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-lone-forest
  ('native-instruments', 'mpc-expansion-queensbridge-story', 'Queensbridge Story MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-queensbridge-story
  ('native-instruments', 'mpc-expansion-rare-vibrations', 'Rare Vibrations MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-rare-vibrations
  ('native-instruments', 'mpc-expansion-rhythm-source', 'Rhythm Source MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-rhythm-source
  ('native-instruments', 'mpc-expansion-timeless-glow', 'Timeless Glow MPC Expansion'), -- official product name | https://www.native-instruments.com/products/mpc-expansion-timeless-glow
  ('native-instruments', 'nacht-mpc-edition', 'Nacht MPC Edition'), -- official product name | https://www.native-instruments.com/products/nacht-mpc-edition
  ('native-instruments', 'odes-fables-lores-bundle', 'Odes, Fables and Lores Bundle'), -- official product name | https://www.native-instruments.com/products/odes-fables-lores-bundle
  ('native-instruments', 'rb-licks', 'R&B Licks'), -- official product name | https://www.native-instruments.com/products/rb-licks
  ('native-instruments', 'retro-machines-mk2', 'Retro Machines MK2'), -- official product name | https://www.native-instruments.com/products/retro-machines-mk2
  ('native-instruments', 'rise-hit', 'Rise & Hit'), -- official product name | https://www.native-instruments.com/products/rise-hit
  ('native-instruments', 'scarbee-classic-ep-88s', 'Scarbee Classic EP-88s'), -- official product name | https://www.native-instruments.com/products/scarbee-classic-ep-88s
  ('native-instruments', 'scarbee-sun-bass-finger', 'Scarbee Sun Bass - Finger'), -- official product name | https://www.native-instruments.com/products/scarbee-sun-bass-finger
  ('native-instruments', 'scene-bloodplant', 'Scene: Bloodplant'), -- official product name | https://www.native-instruments.com/products/scene-bloodplant
  ('native-instruments', 'scene-lotus', 'Scene: Lotus'), -- official product name | https://www.native-instruments.com/products/scene-lotus
  ('native-instruments', 'scene-nightshade', 'Scene: Nightshade'), -- official product name | https://www.native-instruments.com/products/scene-nightshade
  ('native-instruments', 'scene-saffron', 'Scene: Saffron'), -- official product name | https://www.native-instruments.com/products/scene-saffron
  ('native-instruments', 'scene-willow', 'Scene: Willow'), -- official product name | https://www.native-instruments.com/products/scene-willow
  ('native-instruments', 'schema-dark', 'Schema: Dark'), -- official product name | https://www.native-instruments.com/products/schema-dark
  ('native-instruments', 'schema-dark-and-light-bundle', 'Schema: Dark & Light Bundle'), -- official product name | https://www.native-instruments.com/products/schema-dark-and-light-bundle
  ('native-instruments', 'schema-light', 'Schema: Light'), -- official product name | https://www.native-instruments.com/products/schema-light
  ('native-instruments', 'session-bassist-icon-bass', 'Session Bassist - Icon Bass'), -- official product name | https://www.native-instruments.com/products/session-bassist-icon-bass
  ('native-instruments', 'session-bassist-jam-bass', 'Session Bassist - Jam Bass'), -- official product name | https://www.native-instruments.com/products/session-bassist-jam-bass
  ('native-instruments', 'session-bassist-prime-bass', 'Session Bassist - Prime Bass'), -- official product name | https://www.native-instruments.com/products/session-bassist-prime-bass
  ('native-instruments', 'session-bassist-upright-bass', 'Session Bassist - Upright Bass'), -- official product name | https://www.native-instruments.com/products/session-bassist-upright-bass
  ('native-instruments', 'session-guitarist-acoustic-sunburst-deluxe', 'Session Guitarist - Acoustic Sunburst Deluxe'), -- official product name | https://www.native-instruments.com/products/session-guitarist-acoustic-sunburst-deluxe
  ('native-instruments', 'session-guitarist-electric-mint', 'Session Guitarist - Electric Mint'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-mint
  ('native-instruments', 'session-guitarist-electric-neon-deluxe', 'Session Guitarist - Electric Neon Deluxe'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-neon-deluxe
  ('native-instruments', 'session-guitarist-electric-neon-essentials', 'Session Guitarist - Electric Neon Essentials'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-neon-essentials
  ('native-instruments', 'session-guitarist-electric-ruby-deluxe', 'Session Guitarist - Electric Ruby Deluxe'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-ruby-deluxe
  ('native-instruments', 'session-guitarist-electric-storm-deluxe', 'Session Guitarist - Electric Storm Deluxe'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-storm-deluxe
  ('native-instruments', 'session-guitarist-electric-sunburst', 'Session Guitarist - Electric Sunburst'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-sunburst
  ('native-instruments', 'session-guitarist-electric-sunburst-deluxe', 'Session Guitarist - Electric Sunburst Deluxe'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-sunburst-deluxe
  ('native-instruments', 'session-guitarist-electric-vintage', 'Session Guitarist - Electric Vintage'), -- official product name | https://www.native-instruments.com/products/session-guitarist-electric-vintage
  ('native-instruments', 'session-guitarist-picked-acoustic', 'Session Guitarist - Picked Acoustic'), -- official product name | https://www.native-instruments.com/products/session-guitarist-picked-acoustic
  ('native-instruments', 'session-guitarist-picked-nylon', 'Session Guitarist - Picked Nylon'), -- official product name | https://www.native-instruments.com/products/session-guitarist-picked-nylon
  ('native-instruments', 'session-guitarist-strummed-acoustic', 'Session Guitarist - Strummed Acoustic'), -- official product name | https://www.native-instruments.com/products/session-guitarist-strummed-acoustic
  ('native-instruments', 'session-guitarist-strummed-acoustic-2', 'Session Guitarist - Strummed Acoustic 2'), -- official product name | https://www.native-instruments.com/products/session-guitarist-strummed-acoustic-2
  ('native-instruments', 'session-strings', 'Session Strings 2'), -- official product name | https://www.native-instruments.com/products/session-strings
  ('native-instruments', 'session-strings-pro', 'Session Strings Pro 2'), -- official product name | https://www.native-instruments.com/products/session-strings-pro
  ('native-instruments', 'soul-sessions-mpc-edition', 'Soul Sessions MPC Edition'), -- official product name | https://www.native-instruments.com/products/soul-sessions-mpc-edition
  ('native-instruments', 'spotlight-collection-balinese-gamelan', 'Spotlight Collection: Balinese Gamelan'), -- official product name | https://www.native-instruments.com/products/spotlight-collection-balinese-gamelan
  ('native-instruments', 'spotlight-collection-cuba', 'Spotlight Collection: Cuba'), -- official product name | https://www.native-instruments.com/products/spotlight-collection-cuba
  ('native-instruments', 'spotlight-collection-india', 'Spotlight Collection: India'), -- official product name | https://www.native-instruments.com/products/spotlight-collection-india
  ('native-instruments', 'spotlight-collection-middle-east', 'Spotlight Collection: Middle East'), -- official product name | https://www.native-instruments.com/products/spotlight-collection-middle-east
  ('native-instruments', 'spotlight-collection-west-africa', 'Spotlight Collection: West Africa'), -- official product name | https://www.native-instruments.com/products/spotlight-collection-west-africa
  ('native-instruments', 'superstarsaw', 'Super*Saw'), -- official product name | https://www.native-instruments.com/products/superstarsaw
  ('native-instruments', 'sway-mpc-edition', 'Sway MPC Edition'), -- official product name | https://www.native-instruments.com/products/sway-mpc-edition
  ('native-instruments', 'symphony-essentials-brass', 'Symphony Essentials - Brass'), -- official product name | https://www.native-instruments.com/products/symphony-essentials-brass
  ('native-instruments', 'symphony-essentials-collection', 'Symphony Essentials - Collection'), -- official product name | https://www.native-instruments.com/products/symphony-essentials-collection
  ('native-instruments', 'symphony-essentials-string-ensemble', 'Symphony Essentials - String Ensemble'), -- official product name | https://www.native-instruments.com/products/symphony-essentials-string-ensemble
  ('native-instruments', 'symphony-essentials-woodwind', 'Symphony Essentials - Woodwind'), -- official product name | https://www.native-instruments.com/products/symphony-essentials-woodwind
  ('native-instruments', 'symphony-series-brass', 'Symphony Series - Brass'), -- official product name | https://www.native-instruments.com/products/symphony-series-brass
  ('native-instruments', 'symphony-series-collection', 'Symphony Series - Collection'), -- official product name | https://www.native-instruments.com/products/symphony-series-collection
  ('native-instruments', 'symphony-series-string-ensemble', 'Symphony Series - String Ensemble'), -- official product name | https://www.native-instruments.com/products/symphony-series-string-ensemble
  ('native-instruments', 'symphony-series-woodwind', 'Symphony Series - Woodwind'), -- official product name | https://www.native-instruments.com/products/symphony-series-woodwind
  ('native-instruments', 'the-colors-bundle', 'The Colors bundle'), -- official product name | https://www.native-instruments.com/products/the-colors-bundle
  ('native-instruments', 'trk-01', 'TRK-01'), -- official product name | https://www.native-instruments.com/products/trk-01
  ('native-instruments', 'utopia-mpc-edition', 'Utopia MPC Edition') -- official product name | https://www.native-instruments.com/products/utopia-mpc-edition
) as v(dev, slug, name)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Category fixes (78)
update public.plugins p set category = v.category
from public.developers d, (values
  ('native-instruments', 'action-suite', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/action-suite
  ('native-instruments', 'ambient-atmospheres', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/ambient-atmospheres
  ('native-instruments', 'amplified-funk', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/amplified-funk
  ('native-instruments', 'ashlight', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/ashlight
  ('native-instruments', 'beam', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/beam
  ('native-instruments', 'blocks-primes', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/blocks-primes
  ('native-instruments', 'bounce', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/bounce
  ('native-instruments', 'bump', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/bump
  ('native-instruments', 'burnt-hues-samples', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/burnt-hues-samples
  ('native-instruments', 'charge', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/charge
  ('native-instruments', 'cinematic-hits', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/cinematic-hits
  ('native-instruments', 'cinematic-risers', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/cinematic-risers
  ('native-instruments', 'cinematic-soundscapes', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/cinematic-soundscapes
  ('native-instruments', 'conflux', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/conflux
  ('native-instruments', 'drift-theory-samples', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/drift-theory-samples
  ('native-instruments', 'drive', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/drive
  ('native-instruments', 'effects-series-crush-pack', 'saturation'), -- category from the NI store | https://www.native-instruments.com/products/effects-series-crush-pack
  ('native-instruments', 'effects-series-mod-pack', 'utilities'), -- category from the NI store | https://www.native-instruments.com/products/effects-series-mod-pack
  ('native-instruments', 'electric-keys-reeds-duo', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/electric-keys-reeds-duo
  ('native-instruments', 'electric-keys-timber-duo', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/electric-keys-timber-duo
  ('native-instruments', 'electric-keys-tines-duo', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/electric-keys-tines-duo
  ('native-instruments', 'fade', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/fade
  ('native-instruments', 'faded-reels-samples', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/faded-reels-samples
  ('native-instruments', 'form', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/form
  ('native-instruments', 'haze', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/haze
  ('native-instruments', 'hazy-days-samples', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/hazy-days-samples
  ('native-instruments', 'kino', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/kino
  ('native-instruments', 'kolor', 'saturation'), -- category from the NI store | https://www.native-instruments.com/products/kolor
  ('native-instruments', 'komplete-select-band', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/komplete-select-band
  ('native-instruments', 'komplete-select-beats', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/komplete-select-beats
  ('native-instruments', 'komplete-select-electronic', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/komplete-select-electronic
  ('native-instruments', 'kontour', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/kontour
  ('native-instruments', 'light-trilogy', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/light-trilogy
  ('native-instruments', 'lofi-chill-plucks', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/lofi-chill-plucks
  ('native-instruments', 'mechanix', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/mechanix
  ('native-instruments', 'moebius', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/moebius
  ('native-instruments', 'our-house', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/our-house
  ('native-instruments', 'pharlight', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/pharlight
  ('native-instruments', 'playbox', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/playbox
  ('native-instruments', 'pulse', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/pulse
  ('native-instruments', 'quest', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/quest
  ('native-instruments', 'reaktor-spark', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/reaktor-spark
  ('native-instruments', 'retro-machines-mk2', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/retro-machines-mk2
  ('native-instruments', 'reverb-classics', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/reverb-classics
  ('native-instruments', 'rush', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/rush
  ('native-instruments', 'scarbee-rickenbacker-bass', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/scarbee-rickenbacker-bass
  ('native-instruments', 'scarbee-sun-bass-finger', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/scarbee-sun-bass-finger
  ('native-instruments', 'scene', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/scene
  ('native-instruments', 'scoring-sequences', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/scoring-sequences
  ('native-instruments', 'sequis', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/sequis
  ('native-instruments', 'session-bassist-icon-bass', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-bassist-icon-bass
  ('native-instruments', 'session-bassist-jam-bass', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-bassist-jam-bass
  ('native-instruments', 'session-bassist-prime-bass', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-bassist-prime-bass
  ('native-instruments', 'session-bassist-upright-bass', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-bassist-upright-bass
  ('native-instruments', 'session-guitarist-acoustic-sunburst-deluxe', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-acoustic-sunburst-deluxe
  ('native-instruments', 'session-guitarist-electric-mint', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-mint
  ('native-instruments', 'session-guitarist-electric-neon-deluxe', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-neon-deluxe
  ('native-instruments', 'session-guitarist-electric-neon-essentials', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-neon-essentials
  ('native-instruments', 'session-guitarist-electric-ruby-deluxe', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-ruby-deluxe
  ('native-instruments', 'session-guitarist-electric-storm-deluxe', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-storm-deluxe
  ('native-instruments', 'session-guitarist-electric-sunburst', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-sunburst
  ('native-instruments', 'session-guitarist-electric-sunburst-deluxe', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-sunburst-deluxe
  ('native-instruments', 'session-guitarist-electric-vintage', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-electric-vintage
  ('native-instruments', 'session-guitarist-picked-acoustic', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-picked-acoustic
  ('native-instruments', 'session-guitarist-picked-nylon', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-picked-nylon
  ('native-instruments', 'session-guitarist-strummed-acoustic', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/session-guitarist-strummed-acoustic
  ('native-instruments', 'solid-mix-series', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/solid-mix-series
  ('native-instruments', 'soul-magic-samples', 'sample-libraries'), -- category from the NI store | https://www.native-instruments.com/products/soul-magic-samples
  ('native-instruments', 'straylight', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/straylight
  ('native-instruments', 'super-8', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/super-8
  ('native-instruments', 'superstarsaw', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/superstarsaw
  ('native-instruments', 'tape-wobble', 'saturation'), -- category from the NI store | https://www.native-instruments.com/products/tape-wobble
  ('native-instruments', 'the-finger', 'saturation'), -- category from the NI store | https://www.native-instruments.com/products/the-finger
  ('native-instruments', 'transient-master', 'compression'), -- category from the NI store | https://www.native-instruments.com/products/transient-master
  ('native-instruments', 'trap-bells', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/trap-bells
  ('native-instruments', 'trk-01', 'synths'), -- category from the NI store | https://www.native-instruments.com/products/trk-01
  ('native-instruments', 'vintage-compressors', 'bundles'), -- category from the NI store | https://www.native-instruments.com/products/vintage-compressors
  ('native-instruments', 'wake', 'synths') -- category from the NI store | https://www.native-instruments.com/products/wake
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;


