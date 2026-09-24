-- Step 24: catalogue audit, part 2 of 3 (run after 0024_audit_fixes.sql).
-- Catalogues imported from store sitemaps in 0018/0022, re-checked against the same
-- official stores (their product feeds give the exact name, price and vendor):
--   - 8dio / Spitfire Audio: official product names (the import had turned "Adagio Violins
--     2.0" into "Adagio Violins", "BBC Symphony Orchestra" into "Bbc...", and left SEO junk
--     in 8dio slugs such as "-for-kontakt-vst-au-aax-samples"), free products and a gift card
--     removed, duplicates merged.
--   - Plugin Alliance: "marketplace" items are sold by PA but published and licensed by
--     their own developers (Baby Audio, Krotos, GForce, Mastering The Mix, Fuse Audio Labs):
--     moved to those developers, or merged when already listed there. BEATSURFING (not in
--     the catalogue) removed. Categories fixed from PA’s own product descriptions (many
--     compressors, reverbs and amps had landed in "utilities").
--   - MeldaProduction: the free MFreeFXBundle plugins removed, categories fixed.
--   - Toontrack / Universal Audio: brand spelling (EZkeys, EZmix, EZbass, UAD, roman numerals).
-- Idempotent, same rules as 0024.


-- Removed: not a real product of this developer, free, hardware, or not sold on its own (2)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('8dio', '1928-scoring-piano'), -- free product, nothing to resell | https://8dio.com/products/1928-scoring-piano
  ('8dio', '8dio-gift-card') -- gift card, not a product | https://8dio.com/products/8dio-gift-card
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Duplicates / old versions merged into the kept product (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('8dio', 'adagio-violins-2', '8dio', 'adagio-violins') -- duplicate of the same store product | https://8dio.com/products/adagio-violins
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
  ('8dio', 'adagio-violins-2', '8dio', 'adagio-violins') -- duplicate of the same store product | https://8dio.com/products/adagio-violins
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (18)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('8dio', 'catmosphere'), -- free product, nothing to resell | https://8dio.com/products/catmosphere
  ('8dio', 'free-angels'), -- free product, nothing to resell | https://8dio.com/products/free-angels
  ('8dio', 'free-asmr-for-kontakt-vst-au-aax'), -- free product, nothing to resell | https://8dio.com/products/free-asmr-for-kontakt-vst-au-aax
  ('8dio', 'free-home'), -- free product, nothing to resell | https://8dio.com/products/free-home
  ('8dio', 'free-radicals'), -- free product, nothing to resell | https://8dio.com/products/free-radicals
  ('8dio', 'free-you-cloud-collaborationfor-kontakt-vst-au-aax-samples'), -- free product, nothing to resell | https://8dio.com/products/free-you-cloud-collaborationfor-kontakt-vst-au-aax-samples
  ('8dio', 'mini'), -- free product, nothing to resell | https://8dio.com/products/mini
  ('8dio', 'polyphon'), -- free product, nothing to resell | https://8dio.com/products/polyphon
  ('8dio', 'post-apocalyptic-guitar'), -- free product, nothing to resell | https://8dio.com/products/post-apocalyptic-guitar
  ('8dio', 'sequential-prophet-xxl-mapping-utility'), -- free product, nothing to resell | https://8dio.com/products/sequential-prophet-xxl-mapping-utility
  ('8dio', 'smiley-drum'), -- free product, nothing to resell | https://8dio.com/products/smiley-drum
  ('8dio', 'songwriting-guitar'), -- free product, nothing to resell | https://8dio.com/products/songwriting-guitar
  ('8dio', 'synthetic-shadows'), -- free product, nothing to resell | https://8dio.com/products/synthetic-shadows
  ('8dio', 'the-new-ambient-guitar-vst-au-aax-kontakt-instruments-samples'), -- free product, nothing to resell | https://8dio.com/products/the-new-ambient-guitar-vst-au-aax-kontakt-instruments-samples
  ('8dio', 'the-new-cajon'), -- free product, nothing to resell | https://8dio.com/products/the-new-cajon
  ('8dio', 'the-new-copperphone'), -- free product, nothing to resell | https://8dio.com/products/the-new-copperphone
  ('8dio', 'the-new-hybrid-rhythms'), -- free product, nothing to resell | https://8dio.com/products/the-new-hybrid-rhythms
  ('8dio', 'the-new-plucked-grand-piano') -- free product, nothing to resell | https://8dio.com/products/the-new-plucked-grand-piano
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Wrong name or outdated version -> official current name (28)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', '1901-upright-studio-piano-for-kontakt-vst-au-aax-samples', '1901 Studio Upright Piano', '1901-studio-upright-piano', null::text), -- official product name | https://8dio.com/products/1901-upright-studio-piano-for-kontakt-vst-au-aax-samples
  ('8dio', '1985-modern-grand', '1985 Passionate Piano', '1985-passionate-piano', null::text), -- official product name | https://8dio.com/products/1985-modern-grand
  ('8dio', '1990-prepared-grand', '1990 Prepared Studio Grand Piano', '1990-prepared-studio-grand-piano', null::text), -- official product name | https://8dio.com/products/1990-prepared-grand
  ('8dio', '8dio-advanced-drum-series-ragnarok-kit-kontakt-vst-au-aax', 'Advanced Drum Series Ragnarok Kit', 'advanced-drum-series-ragnarok-kit', null::text), -- official product name | https://8dio.com/products/8dio-advanced-drum-series-ragnarok-kit-kontakt-vst-au-aax
  ('8dio', '8dio-aluphone', 'Aluphone', 'aluphone', null::text), -- official product name | https://8dio.com/products/8dio-aluphone
  ('8dio', '8dio-caisa-drum', 'Caisa Drum', 'caisa-drum', null::text), -- official product name | https://8dio.com/products/8dio-caisa-drum
  ('8dio', '8dio-marimba', 'Marimba', 'marimba', null::text), -- official product name | https://8dio.com/products/8dio-marimba
  ('8dio', '8dio-misfit-3-string-diddley-bow', 'Misfit 3 Stringed Diddley Bow', 'misfit-3-stringed-diddley-bow', null::text), -- official product name | https://8dio.com/products/8dio-misfit-3-string-diddley-bow
  ('8dio', '8dio-studio-vocal-series-jenifer-kontakt-vstauaxx', 'Advanced Studio Voices Jenifer', 'advanced-studio-voices-jenifer', null::text), -- official product name | https://8dio.com/products/8dio-studio-vocal-series-jenifer-kontakt-vstauaxx
  ('8dio', '8dio-vibraphone', 'Vibraphone', 'vibraphone', null::text), -- official product name | https://8dio.com/products/8dio-vibraphone
  ('8dio', '8dioboe-vst-au-aax-kontakt-instruments-samples', '8Dioboe', '8dioboe', null::text), -- official product name | https://8dio.com/products/8dioboe-vst-au-aax-kontakt-instruments-samples
  ('8dio', 'acoustic-guitar-bundle-solo-strummer-vst-au-aax-kontakt', 'Instant Guitar Series Acoustic Guitar', 'instant-guitar-series-acoustic-guitar', null::text), -- official product name | https://8dio.com/products/acoustic-guitar-bundle-solo-strummer-vst-au-aax-kontakt
  ('8dio', 'adagietto-vst-au-aax-kontakt-instruments-samples', 'Adagietto', 'adagietto', null::text), -- official product name | https://8dio.com/products/adagietto-vst-au-aax-kontakt-instruments-samples
  ('8dio', 'adagio-agitato', 'Adagio & Agitato Bundle', 'adagio-and-agitato-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/adagio-agitato
  ('8dio', 'adagio-basses', 'Adagio Basses 2.0', 'adagio-basses-2-0', null::text), -- official product name | https://8dio.com/products/adagio-basses
  ('8dio', 'adagio-cellos', 'Adagio Cellos 2.0', 'adagio-cellos-2-0', null::text), -- official product name | https://8dio.com/products/adagio-cellos
  ('8dio', 'adagio-violas', 'Adagio Violas 2.0', 'adagio-violas-2-0', null::text), -- official product name | https://8dio.com/products/adagio-violas
  ('8dio', 'adagio-violins', 'Adagio Violins 2.0', 'adagio-violins-2-0', null::text), -- official product name | https://8dio.com/products/adagio-violins
  ('8dio', 'advanced-drum-series-blackbird-vst-au-aax-kontakt-instrument', 'Advanced Drum Series Blackbird Kit', 'advanced-drum-series-blackbird-kit', null::text), -- official product name | https://8dio.com/products/advanced-drum-series-blackbird-vst-au-aax-kontakt-instrument
  ('8dio', 'advanced-guitalele', 'Advanced Guitar Series Guitalele', 'advanced-guitar-series-guitalele', null::text), -- official product name | https://8dio.com/products/advanced-guitalele
  ('8dio', 'advanced-guitar-series', 'Advanced Guitar Series Bundle', 'advanced-guitar-series-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/advanced-guitar-series
  ('8dio', 'advanced-guitar-series-charango-for-kontakt', 'Advanced Guitar Series Charango', 'advanced-guitar-series-charango', null::text), -- official product name | https://8dio.com/products/advanced-guitar-series-charango-for-kontakt
  ('8dio', 'aetheria', 'Aetheria Choir', 'aetheria-choir', null::text), -- official product name | https://8dio.com/products/aetheria
  ('8dio', 'agitato-grandiose-ensemble-cellos', 'Agitato Grandiose Legato Ensemble & Divisi Cellos', 'agitato-grandiose-legato-ensemble-and-divisi-cellos', null::text), -- official product name | https://8dio.com/products/agitato-grandiose-ensemble-cellos
  ('8dio', 'agitato-grandiose-ensemble-violas', 'Agitato Ensemble & Divisi Violas', 'agitato-ensemble-and-divisi-violas', null::text), -- official product name | https://8dio.com/products/agitato-grandiose-ensemble-violas
  ('8dio', 'agitato-grandiose-ensemble-violins', 'Agitato Ensemble & Divisi Violins', 'agitato-ensemble-and-divisi-violins', null::text), -- official product name | https://8dio.com/products/agitato-grandiose-ensemble-violins
  ('8dio', 'agitato-legato-arpeggio-for-kontakt-vst-au-aax', 'Agitato Legato Arpeggio', 'agitato-legato-arpeggio', null::text), -- official product name | https://8dio.com/products/agitato-legato-arpeggio-for-kontakt-vst-au-aax
  ('8dio', 'agitato-sordino-strings-for-kontakt-vst-au-aax', 'Agitato Sordino Strings', 'agitato-sordino-strings', null::text) -- official product name | https://8dio.com/products/agitato-sordino-strings-for-kontakt-vst-au-aax
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Category fixes (1)
update public.plugins p set category = v.category
from public.developers d, (values
  ('8dio', 'all-century-orchestra-bundle', 'bundles') -- store lists it as a bundle | https://8dio.com/products/all-century-orchestra-bundle
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Wrong name or outdated version -> official current name (2)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', 'all-choirs', 'All Choirs Bundle', 'all-choirs-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/all-choirs
  ('8dio', 'all-collection-brass-bundle-1', 'All Brass Bundle', 'all-brass-bundle', 'bundles'::text) -- official product name | https://8dio.com/products/all-collection-brass-bundle-1
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Category fixes (3)
update public.plugins p set category = v.category
from public.developers d, (values
  ('8dio', 'all-custom-instruments-collection', 'bundles'), -- store lists it as a bundle | https://8dio.com/products/all-custom-instruments-collection
  ('8dio', 'all-guitars-collection', 'bundles'), -- store lists it as a bundle | https://8dio.com/products/all-guitars-collection
  ('8dio', 'all-hybrid-cinema-bundle', 'bundles') -- store lists it as a bundle | https://8dio.com/products/all-hybrid-cinema-bundle
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Wrong name or outdated version -> official current name (2)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', 'all-pianos', 'All Pianos Bundle', 'all-pianos-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/all-pianos
  ('8dio', 'all-pianos-keyboards-collection-bundle', 'All Pianos & Keys Collection', 'all-pianos-and-keys-collection', 'bundles'::text) -- official product name | https://8dio.com/products/all-pianos-keyboards-collection-bundle
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Category fixes (1)
update public.plugins p set category = v.category
from public.developers d, (values
  ('8dio', 'all-solo-vox-bundle', 'bundles') -- store lists it as a bundle | https://8dio.com/products/all-solo-vox-bundle
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Wrong name or outdated version -> official current name (1)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', 'all-strings-bundle-collection', 'All Strings Bundle', 'all-strings-bundle', 'bundles'::text) -- official product name | https://8dio.com/products/all-strings-bundle-collection
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Category fixes (1)
update public.plugins p set category = v.category
from public.developers d, (values
  ('8dio', 'all-woodwinds-bundle', 'bundles') -- store lists it as a bundle | https://8dio.com/products/all-woodwinds-bundle
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Wrong name or outdated version -> official current name (42)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', 'alto-flute-virtuoso', 'Claire Alto Flute Virtuoso', 'claire-alto-flute-virtuoso', null::text), -- official product name | https://8dio.com/products/alto-flute-virtuoso
  ('8dio', 'animalix', 'EDM Animalix', 'edm-animalix', null::text), -- official product name | https://8dio.com/products/animalix
  ('8dio', 'aura-guitars-for-kontakt-vst-au-aax', 'Aura Guitars', 'aura-guitars', null::text), -- official product name | https://8dio.com/products/aura-guitars-for-kontakt-vst-au-aax
  ('8dio', 'aura-tonal-exotic-studio-percussion', '5 Studio Exotic Percussions', '5-studio-exotic-percussions', null::text), -- official product name | https://8dio.com/products/aura-tonal-exotic-studio-percussion
  ('8dio', 'bassoon-virtuoso', 'Claire Bassoon Virtuoso', 'claire-bassoon-virtuoso', null::text), -- official product name | https://8dio.com/products/bassoon-virtuoso
  ('8dio', 'batucada', 'Legion Series 33 Drummers Batucada', 'legion-series-33-drummers-batucada', null::text), -- official product name | https://8dio.com/products/batucada
  ('8dio', 'blendstrument-alive-percussion-kontakt-vst-au-aax', 'Blendstrument Alive Percussion', 'blendstrument-alive-percussion', null::text), -- official product name | https://8dio.com/products/blendstrument-alive-percussion-kontakt-vst-au-aax
  ('8dio', 'blendstrument-hybrid-pulses-vst-au-aax-kontakt-instruments', 'Blendstrument Hybrid Pulses', 'blendstrument-hybrid-pulses', null::text), -- official product name | https://8dio.com/products/blendstrument-hybrid-pulses-vst-au-aax-kontakt-instruments
  ('8dio', 'blendstrument-motion-textures-vst-au-aax-kontakt-instruments', 'Blendstrument Motion Textures', 'blendstrument-motion-textures', null::text), -- official product name | https://8dio.com/products/blendstrument-motion-textures-vst-au-aax-kontakt-instruments
  ('8dio', 'blendstrument-strange-pulses-kontakt-vst-au-aax', 'Blendstrument Strange Pulses', 'blendstrument-strange-pulses', null::text), -- official product name | https://8dio.com/products/blendstrument-strange-pulses-kontakt-vst-au-aax
  ('8dio', 'cage', 'CAGE Bundle', 'cage-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/cage
  ('8dio', 'cage-brass', 'CAGE Brass Edition', 'cage-brass-edition', null::text), -- official product name | https://8dio.com/products/cage-brass
  ('8dio', 'cage-strings-vst-au-aax-kontakt-instruments-samples', 'CAGE Strings Edition', 'cage-strings-edition', null::text), -- official product name | https://8dio.com/products/cage-strings-vst-au-aax-kontakt-instruments-samples
  ('8dio', 'cage-woodwinds', 'CAGE Woodwinds Edition', 'cage-woodwinds-edition', null::text), -- official product name | https://8dio.com/products/cage-woodwinds
  ('8dio', 'case-bundle', 'CASE Solo Bundle', 'case-solo-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/case-bundle
  ('8dio', 'case-solo-brass-fx-kontakt-instrument-samples', 'CASE Solo Brass', 'case-solo-brass', null::text), -- official product name | https://8dio.com/products/case-solo-brass-fx-kontakt-instrument-samples
  ('8dio', 'case-solo-woodwinds-fx-kontakt-instrument-samples', 'CASE Solo Winds', 'case-solo-winds', null::text), -- official product name | https://8dio.com/products/case-solo-woodwinds-fx-kontakt-instrument-samples
  ('8dio', 'case-strings-vst-au-aax-kontakt-instruments-samples', 'CASE Solo Strings', 'case-solo-strings', null::text), -- official product name | https://8dio.com/products/case-strings-vst-au-aax-kontakt-instruments-samples
  ('8dio', 'century-advanced-ostinato-strings-ii-2', 'Ostinato Strings Chapter 2', 'ostinato-strings-chapter-2', null::text), -- official product name | https://8dio.com/products/century-advanced-ostinato-strings-ii-2
  ('8dio', 'century-artisan-brass', 'Century Artisan Brass Bundle', 'century-artisan-brass-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/century-artisan-brass
  ('8dio', 'century-artisan-brass-cimbasso-for-kontakt-vst-au-aax-samples', 'Century Artisan Brass Cimbasso', 'century-artisan-brass-cimbasso', null::text), -- official product name | https://8dio.com/products/century-artisan-brass-cimbasso-for-kontakt-vst-au-aax-samples
  ('8dio', 'century-artisan-brass-euphonium-for-kontakt-vst-au-aax-samples', 'Century Artisan Brass Euphonium', 'century-artisan-brass-euphonium', null::text), -- official product name | https://8dio.com/products/century-artisan-brass-euphonium-for-kontakt-vst-au-aax-samples
  ('8dio', 'century-artisan-brass-flugel-horn-kontakt-vst-au-aax-samples', 'Century Artisan Brass Flugel Horn', 'century-artisan-brass-flugel-horn', null::text), -- official product name | https://8dio.com/products/century-artisan-brass-flugel-horn-kontakt-vst-au-aax-samples
  ('8dio', 'century-brass-bundle', 'All Century Brass Bundle', 'all-century-brass-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/century-brass-bundle
  ('8dio', 'century-brass-solo', 'Century Solo Brass Bundle', 'century-solo-brass-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/century-brass-solo
  ('8dio', 'century-ensemble-brass', 'Century Ensemble Brass Bundle', 'century-ensemble-brass-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/century-ensemble-brass
  ('8dio', 'century-ensemble-trumpets', 'Century Ensemble Brass Trumpets', 'century-ensemble-brass-trumpets', null::text), -- official product name | https://8dio.com/products/century-ensemble-trumpets
  ('8dio', 'century-ostinato-brass-trombones-tubas-for-kontakt', 'Century Ostinato Brass Trombones and Tuba', 'century-ostinato-brass-trombones-and-tuba', null::text), -- official product name | https://8dio.com/products/century-ostinato-brass-trombones-tubas-for-kontakt
  ('8dio', 'century-ostinato-brass-trumpets-horns-for-kontakt', 'Century Ostinato Brass Trumpets and Horns', 'century-ostinato-brass-trumpets-and-horns', null::text), -- official product name | https://8dio.com/products/century-ostinato-brass-trumpets-horns-for-kontakt
  ('8dio', 'century-ostinato-flute-clarinet-vol-1', 'Ostinato Woodwinds Flutes and Clarinets', 'ostinato-woodwinds-flutes-and-clarinets', null::text), -- official product name | https://8dio.com/products/century-ostinato-flute-clarinet-vol-1
  ('8dio', 'century-ostinato-oboe-bassoon-vol-2', 'Ostinato Woodwinds Oboes and Bassoons', 'ostinato-woodwinds-oboes-and-bassoons', null::text), -- official product name | https://8dio.com/products/century-ostinato-oboe-bassoon-vol-2
  ('8dio', 'century-ostinato-woodwinds', 'Century Ostinato Woodwinds Bundle', 'century-ostinato-woodwinds-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/century-ostinato-woodwinds
  ('8dio', 'century-strings-series', 'Century Strings Bundle', 'century-strings-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/century-strings-series
  ('8dio', 'christopher-young', 'Christopher Young Series Bundle', 'christopher-young-series-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/christopher-young
  ('8dio', 'christopher-young-orchestral', 'Christopher Youngs Orchestral Touch', 'christopher-youngs-orchestral-touch', null::text), -- official product name | https://8dio.com/products/christopher-young-orchestral
  ('8dio', 'christopher-young-textural', 'Christopher Youngs Textural Worlds', 'christopher-youngs-textural-worlds', null::text), -- official product name | https://8dio.com/products/christopher-young-textural
  ('8dio', 'claire-woodwinds', 'Claire Woodwinds Bundle', 'claire-woodwinds-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/claire-woodwinds
  ('8dio', 'clarinet-virtouso', 'Claire Clarinet Virtuoso', 'claire-clarinet-virtuoso', null::text), -- official product name | https://8dio.com/products/clarinet-virtouso
  ('8dio', 'clay-vase-drum', 'Clay Drum', 'clay-drum', null::text), -- official product name | https://8dio.com/products/clay-vase-drum
  ('8dio', 'clocks-instrument', 'Clocks', 'clocks', null::text), -- official product name | https://8dio.com/products/clocks-instrument
  ('8dio', 'custom-instrument-series-circle-strings', 'Circle Strings', 'circle-strings', null::text), -- official product name | https://8dio.com/products/custom-instrument-series-circle-strings
  ('8dio', 'custom-instrument-series-everwave', 'EverWave', 'everwave', null::text) -- official product name | https://8dio.com/products/custom-instrument-series-everwave
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Category fixes (1)
update public.plugins p set category = v.category
from public.developers d, (values
  ('8dio', 'custom-instruments-bundle', 'bundles') -- store lists it as a bundle | https://8dio.com/products/custom-instruments-bundle
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Wrong name or outdated version -> official current name (70)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', 'deep-house-groove-edition-vol-2-for-maschine-kontakt-wav', 'EDM Deep House Vol. 2', 'edm-deep-house-vol-2', null::text), -- official product name | https://8dio.com/products/deep-house-groove-edition-vol-2-for-maschine-kontakt-wav
  ('8dio', 'deep-house-synth-edition-vol-1', 'EDM Deep House Synth Edition', 'edm-deep-house-synth-edition', null::text), -- official product name | https://8dio.com/products/deep-house-synth-edition-vol-1
  ('8dio', 'deep-house-vol-1', 'EDM Deep House Vol. 1', 'edm-deep-house-vol-1', null::text), -- official product name | https://8dio.com/products/deep-house-vol-1
  ('8dio', 'deep-solo-strings', 'Deep Solo Strings Bundle', 'deep-solo-strings-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/deep-solo-strings
  ('8dio', 'dubstep-vol-1', 'EDM Dubstep Vol. 1', 'edm-dubstep-vol-1', null::text), -- official product name | https://8dio.com/products/dubstep-vol-1
  ('8dio', 'dubstep-vol-2', 'EDM Dubstep Vol. 2', 'edm-dubstep-vol-2', null::text), -- official product name | https://8dio.com/products/dubstep-vol-2
  ('8dio', 'duduks', '3 Duduks', '3-duduks', null::text), -- official product name | https://8dio.com/products/duduks
  ('8dio', 'edge-groove-edition-vol-1', 'EDM Edge Vol. 1', 'edm-edge-vol-1', null::text), -- official product name | https://8dio.com/products/edge-groove-edition-vol-1
  ('8dio', 'edge-groove-edition-vol-2', 'EDM Edge Vol. 2', 'edm-edge-vol-2', null::text), -- official product name | https://8dio.com/products/edge-groove-edition-vol-2
  ('8dio', 'edm', 'All EDM Bundle', 'all-edm-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/edm
  ('8dio', 'edm-drumstep-1', 'EDM Drumstep Vol.1', 'edm-drumstep-vol-1', null::text), -- official product name | https://8dio.com/products/edm-drumstep-1
  ('8dio', 'edm-trap', 'EDM Trap', 'edm-trap', null::text), -- official product name | https://8dio.com/products/edm-trap
  ('8dio', 'electric-cello-vst-au-aax-kontakt-instrument', 'Electric Cello', 'electric-cello', null::text), -- official product name | https://8dio.com/products/electric-cello-vst-au-aax-kontakt-instrument
  ('8dio', 'electric-guitar-bundle-solo-strummer-vst-au-aax-kontakt-instruments', 'Instant Guitar Series Electric Guitar', 'instant-guitar-series-electric-guitar', null::text), -- official product name | https://8dio.com/products/electric-guitar-bundle-solo-strummer-vst-au-aax-kontakt-instruments
  ('8dio', 'electric-solo-strings', 'Electric Solo Strings Bundle', 'electric-solo-strings-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/electric-solo-strings
  ('8dio', 'electric-violin-vst-au-aax-kontakt-instrument', 'Electric Violin', 'electric-violin', null::text), -- official product name | https://8dio.com/products/electric-violin-vst-au-aax-kontakt-instrument
  ('8dio', 'electro-house-vol-1', 'EDM Electro House Vol. 1', 'edm-electro-house-vol-1', null::text), -- official product name | https://8dio.com/products/electro-house-vol-1
  ('8dio', 'electro-house-vol-3-samples-loops', 'EDM Electro House Vol. 3', 'edm-electro-house-vol-3', null::text), -- official product name | https://8dio.com/products/electro-house-vol-3-samples-loops
  ('8dio', 'electro-house-volume-2', 'EDM Electro House Vol. 2', 'edm-electro-house-vol-2', null::text), -- official product name | https://8dio.com/products/electro-house-volume-2
  ('8dio', 'emotional-guitars-bundle', 'Emotional Guitars The Collection', 'emotional-guitars-the-collection', 'bundles'::text), -- official product name | https://8dio.com/products/emotional-guitars-bundle
  ('8dio', 'emotional-multi-samples', 'Emotional Guitars Multi Sampled', 'emotional-guitars-multi-sampled', null::text), -- official product name | https://8dio.com/products/emotional-multi-samples
  ('8dio', 'english-horn-virtuoso', 'Claire English Horn Virtuoso', 'claire-english-horn-virtuoso', null::text), -- official product name | https://8dio.com/products/english-horn-virtuoso
  ('8dio', 'epic-drums', 'Epic Drums Bundle', 'epic-drums-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/epic-drums
  ('8dio', 'epic-ensemble-bundle', 'All Epic Ensemble Collection', 'all-epic-ensemble-collection', 'bundles'::text), -- official product name | https://8dio.com/products/epic-ensemble-bundle
  ('8dio', 'epic-taiko-ensemble-vst', 'Epic Taiko Ensemble', 'epic-taiko-ensemble', null::text), -- official product name | https://8dio.com/products/epic-taiko-ensemble-vst
  ('8dio', 'equinox', 'Hybrid Action Tools Equinox', 'hybrid-action-tools-equinox', null::text), -- official product name | https://8dio.com/products/equinox
  ('8dio', 'extreme-electric-bass-ensemble', 'Extreme Ensemble 10 Basses', 'extreme-ensemble-10-basses', null::text), -- official product name | https://8dio.com/products/extreme-electric-bass-ensemble
  ('8dio', 'extreme-electric-guitar-ensemble', 'Extreme Ensemble 10 Electric Guitars', 'extreme-ensemble-10-electric-guitars', null::text), -- official product name | https://8dio.com/products/extreme-electric-guitar-ensemble
  ('8dio', 'extreme-ensemble-analog-synth-edition', 'Extreme Ensemble 10 Analog Synths', 'extreme-ensemble-10-analog-synths', null::text), -- official product name | https://8dio.com/products/extreme-ensemble-analog-synth-edition
  ('8dio', 'extreme-ensemble-real-drumkit', 'Extreme Ensemble 10 Drum Kits', 'extreme-ensemble-10-drum-kits', null::text), -- official product name | https://8dio.com/products/extreme-ensemble-real-drumkit
  ('8dio', 'extreme-ensemble-series-drum-machine-ensemble', 'Extreme Ensembles 10 Drum Machines', 'extreme-ensembles-10-drum-machines', null::text), -- official product name | https://8dio.com/products/extreme-ensemble-series-drum-machine-ensemble
  ('8dio', 'extreme-ensembles', 'Extreme Ensembles Bundle', 'extreme-ensembles-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/extreme-ensembles
  ('8dio', 'flow-house-groove-edition-vol-2-for-kontakt-maschine-wav', 'EDM Flow House Vol. 2', 'edm-flow-house-vol-2', null::text), -- official product name | https://8dio.com/products/flow-house-groove-edition-vol-2-for-kontakt-maschine-wav
  ('8dio', 'flow-house-synth-edition-vst-au-aax-kontakt-instrument', 'EDM Flow House Synth Edition', 'edm-flow-house-synth-edition', null::text), -- official product name | https://8dio.com/products/flow-house-synth-edition-vst-au-aax-kontakt-instrument
  ('8dio', 'flow-house-volume-1', 'EDM Flow House Vol. 1', 'edm-flow-house-vol-1', null::text), -- official product name | https://8dio.com/products/flow-house-volume-1
  ('8dio', 'flute-virtuoso', 'Claire Flute Virtuoso', 'claire-flute-virtuoso', null::text), -- official product name | https://8dio.com/products/flute-virtuoso
  ('8dio', 'greek-percussion-for-kontakt-vst-au-aax-samples', 'Greek Percussion', 'greek-percussion', null::text), -- official product name | https://8dio.com/products/greek-percussion-for-kontakt-vst-au-aax-samples
  ('8dio', 'hybrid-drums-8d8-instrument-for-kontakt-vst-au-aax-samples', 'Hybrid Drums 8D8', 'hybrid-drums-8d8', null::text), -- official product name | https://8dio.com/products/hybrid-drums-8d8-instrument-for-kontakt-vst-au-aax-samples
  ('8dio', 'hybrid-tools-eternal-darkness-for-kontakt-vst-au-aax', 'Hybrid Tools Eternal Darkness', 'hybrid-tools-eternal-darkness', null::text), -- official product name | https://8dio.com/products/hybrid-tools-eternal-darkness-for-kontakt-vst-au-aax
  ('8dio', 'hybrid-tools-modern-cinema', 'Hybrid Tools 4', 'hybrid-tools-4', null::text), -- official product name | https://8dio.com/products/hybrid-tools-modern-cinema
  ('8dio', 'hybrid-tools-neo-for-kontakt-vst-au-aax-instruments', 'Hybrid Tools NEO', 'hybrid-tools-neo', null::text), -- official product name | https://8dio.com/products/hybrid-tools-neo-for-kontakt-vst-au-aax-instruments
  ('8dio', 'hybrid-tools-neo-ii-kontakt-vst-au-aax', 'Hybrid Tools NEO II', 'hybrid-tools-neo-ii', null::text), -- official product name | https://8dio.com/products/hybrid-tools-neo-ii-kontakt-vst-au-aax
  ('8dio', 'hybrid-tools-phenex-bundle', 'Phenex Bundle', 'phenex-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/hybrid-tools-phenex-bundle
  ('8dio', 'hybrid-tools-phenex-modular-analog-basses-pads', 'Phenex Modular Analog', 'phenex-modular-analog', null::text), -- official product name | https://8dio.com/products/hybrid-tools-phenex-modular-analog-basses-pads
  ('8dio', 'hybrid-tools-phenex-modular-analog-effects', 'Phenex Modular Tools', 'phenex-modular-tools', null::text), -- official product name | https://8dio.com/products/hybrid-tools-phenex-modular-analog-effects
  ('8dio', 'hybrid-tools-series', 'All Hybrid Tools Bundle', 'all-hybrid-tools-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/hybrid-tools-series
  ('8dio', 'hybrid-tools-synphony-for-kontakt-vst-au-aax', 'Hybrid Tools Synphony', 'hybrid-tools-synphony', null::text), -- official product name | https://8dio.com/products/hybrid-tools-synphony-for-kontakt-vst-au-aax
  ('8dio', 'hybrid-tools-synphony-opus-1-expansion-for-kontakt-vst-au-aax', 'Hybrid Tools Synphony Opus 1 Expansion', 'hybrid-tools-synphony-opus-1-expansion', null::text), -- official product name | https://8dio.com/products/hybrid-tools-synphony-opus-1-expansion-for-kontakt-vst-au-aax
  ('8dio', 'hybrid-tools-vol-3', 'Hybrid Tools 3', 'hybrid-tools-3', null::text), -- official product name | https://8dio.com/products/hybrid-tools-vol-3
  ('8dio', 'instant-12-string-guitar-kontakt-vst-au-aax', 'Instant Guitar Series 12 String Guitar', 'instant-guitar-series-12-string-guitar', null::text), -- official product name | https://8dio.com/products/instant-12-string-guitar-kontakt-vst-au-aax
  ('8dio', 'instant-dobro', 'Instant Guitar Series Dobro Guitar', 'instant-guitar-series-dobro-guitar', null::text), -- official product name | https://8dio.com/products/instant-dobro
  ('8dio', 'instant-guitars', 'Instant Guitar Series Bundle', 'instant-guitar-series-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/instant-guitars
  ('8dio', 'instant-mandolin-guitar-bundle', 'Instant Guitar Series Mandolin Guitar', 'instant-guitar-series-mandolin-guitar', null::text), -- official product name | https://8dio.com/products/instant-mandolin-guitar-bundle
  ('8dio', 'instant-steel-string', 'Instant Guitar Series Steel String Guitar', 'instant-guitar-series-steel-string-guitar', null::text), -- official product name | https://8dio.com/products/instant-steel-string
  ('8dio', 'instant-ukulele', 'Instant Guitar Series Ukulele Guitar', 'instant-guitar-series-ukulele-guitar', null::text), -- official product name | https://8dio.com/products/instant-ukulele
  ('8dio', 'intimate-studio-brass-kontakt-vst-au-aax', 'Intimate Studio Brass', 'intimate-studio-brass', null::text), -- official product name | https://8dio.com/products/intimate-studio-brass-kontakt-vst-au-aax
  ('8dio', 'intimate-studio-series', 'Intimate Studio Orchestra', 'intimate-studio-orchestra', 'bundles'::text), -- official product name | https://8dio.com/products/intimate-studio-series
  ('8dio', 'intimate-studio-woodwinds', 'Intimate Studio Winds', 'intimate-studio-winds', null::text), -- official product name | https://8dio.com/products/intimate-studio-woodwinds
  ('8dio', 'lacrimosa-epic-choir', 'Lacrimosa Choir', 'lacrimosa-choir', null::text), -- official product name | https://8dio.com/products/lacrimosa-epic-choir
  ('8dio', 'legion-series', 'Legion Series Bundle', 'legion-series-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/legion-series
  ('8dio', 'legion-series-66-cellos-ensemble-for-kontakt-vst-au-aax-samples', 'Legion Series 66 Cellos', 'legion-series-66-cellos', null::text), -- official product name | https://8dio.com/products/legion-series-66-cellos-ensemble-for-kontakt-vst-au-aax-samples
  ('8dio', 'legion-series-66-trombones-kontakt-vst-au-aax', 'Legion Series 66 Trombones', 'legion-series-66-trombones', null::text), -- official product name | https://8dio.com/products/legion-series-66-trombones-kontakt-vst-au-aax
  ('8dio', 'legion-series-66-tubas-for-kontakt-vst-au-aax-samples', 'Legion Series 66 Tubas', 'legion-series-66-tubas', null::text), -- official product name | https://8dio.com/products/legion-series-66-tubas-for-kontakt-vst-au-aax-samples
  ('8dio', 'liberis-childrens-choir', 'Liberis Choir', 'liberis-choir', null::text), -- official product name | https://8dio.com/products/liberis-childrens-choir
  ('8dio', 'lyre-vst-au-aax-kontakt-instrument', 'Lyre', 'lyre', null::text), -- official product name | https://8dio.com/products/lyre-vst-au-aax-kontakt-instrument
  ('8dio', 'majestica', 'Majestica Series', 'majestica-series', null::text), -- official product name | https://8dio.com/products/majestica
  ('8dio', 'misfit-1-string-diddley-bow-vst-au-aax', 'Misfit 1 Stringed Diddley Bow', 'misfit-1-stringed-diddley-bow', null::text), -- official product name | https://8dio.com/products/misfit-1-string-diddley-bow-vst-au-aax
  ('8dio', 'misfit-baby-n-toys-for-kontakt-vst-au-aax-samples', 'Misfit Toys n'' Baby', 'misfit-toys-n-baby', null::text), -- official product name | https://8dio.com/products/misfit-baby-n-toys-for-kontakt-vst-au-aax-samples
  ('8dio', 'misfit-banjo-vst-au-axx', 'Misfit Banjo', 'misfit-banjo', null::text), -- official product name | https://8dio.com/products/misfit-banjo-vst-au-axx
  ('8dio', 'misfit-bicycle-vst-au-axx', 'Misfit Bicycle', 'misfit-bicycle', null::text) -- official product name | https://8dio.com/products/misfit-bicycle-vst-au-axx
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Category fixes (1)
update public.plugins p set category = v.category
from public.developers d, (values
  ('8dio', 'misfit-bundle', 'bundles') -- store lists it as a bundle | https://8dio.com/products/misfit-bundle
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Wrong name or outdated version -> official current name (101)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('8dio', 'misfit-fiddle-vst-au-aax', 'Misfit Washboard', 'misfit-washboard', null::text), -- official product name | https://8dio.com/products/misfit-fiddle-vst-au-aax
  ('8dio', 'misfit-fiddle-vst-au-aax-2', 'Misfit Fiddle', 'misfit-fiddle', null::text), -- official product name | https://8dio.com/products/misfit-fiddle-vst-au-aax-2
  ('8dio', 'misfit-harmonica-vst-au-aax', 'Misfit Harmonica', 'misfit-harmonica', null::text), -- official product name | https://8dio.com/products/misfit-harmonica-vst-au-aax
  ('8dio', 'misfit-jaw-harp-vst-au-aax', 'Misfit Jawharp', 'misfit-jawharp', null::text), -- official product name | https://8dio.com/products/misfit-jaw-harp-vst-au-aax
  ('8dio', 'misfit-stomp-box-vst-au-aax', 'Misfit Stompbox', 'misfit-stompbox', null::text), -- official product name | https://8dio.com/products/misfit-stomp-box-vst-au-aax
  ('8dio', 'misfit-toy-instruments', 'Misfit Toy Instruments', 'misfit-toy-instruments', null::text), -- official product name | https://8dio.com/products/misfit-toy-instruments
  ('8dio', 'misfit-toy-piano-vst-au-aax', 'Misfit Toy Piano', 'misfit-toy-piano', null::text), -- official product name | https://8dio.com/products/misfit-toy-piano-vst-au-aax
  ('8dio', 'misfit-toy-synths-drums-for-kontakt-vst-au-aax-samples', 'Misfit Synths', 'misfit-synths', null::text), -- official product name | https://8dio.com/products/misfit-toy-synths-drums-for-kontakt-vst-au-aax-samples
  ('8dio', 'misfit-trombone-vst-au-aax', 'Misfit Trombone', 'misfit-trombone', null::text), -- official product name | https://8dio.com/products/misfit-trombone-vst-au-aax
  ('8dio', 'misfit-trumpet-vst-au-axx-8dio', 'Misfit Trumpet', 'misfit-trumpet', null::text), -- official product name | https://8dio.com/products/misfit-trumpet-vst-au-axx-8dio
  ('8dio', 'misfit-whistling-vst-au-aax', 'Misfit Whistling', 'misfit-whistling', null::text), -- official product name | https://8dio.com/products/misfit-whistling-vst-au-aax
  ('8dio', 'misfitconcertina', 'Misfit Concertina', 'misfit-concertina', null::text), -- official product name | https://8dio.com/products/misfitconcertina
  ('8dio', 'new-1969-piano-vst-au-aax', '1969 Legacy Piano', '1969-legacy-piano', null::text), -- official product name | https://8dio.com/products/new-1969-piano-vst-au-aax
  ('8dio', 'new-acoustic-gr', 'Acoustic Grand Ensembles AGE Vol. 1', 'acoustic-grand-ensembles-age-vol-1', null::text), -- official product name | https://8dio.com/products/new-acoustic-gr
  ('8dio', 'new-bulbul-tarang', 'Bulbul Tarang', 'bulbul-tarang', null::text), -- official product name | https://8dio.com/products/new-bulbul-tarang
  ('8dio', 'new-century-ensemble-strings-2-0-sordino', 'Century Sordino Strings', 'century-sordino-strings', null::text), -- official product name | https://8dio.com/products/new-century-ensemble-strings-2-0-sordino
  ('8dio', 'new-forgotten-voices-francesca-for-kontakt-vst-au-aax', 'Forgotten Voices Francesca', 'forgotten-voices-francesca', null::text), -- official product name | https://8dio.com/products/new-forgotten-voices-francesca-for-kontakt-vst-au-aax
  ('8dio', 'new-hybrid-tools-2-for-kontakt-vst-au-aax-samples', 'Hybrid Tools 2', 'hybrid-tools-2', null::text), -- official product name | https://8dio.com/products/new-hybrid-tools-2-for-kontakt-vst-au-aax-samples
  ('8dio', 'new-rhythmic-aura-2-for-kontakt-vst-au-aax-samples', 'Rhythmic Aura 2', 'rhythmic-aura-2', null::text), -- official product name | https://8dio.com/products/new-rhythmic-aura-2-for-kontakt-vst-au-aax-samples
  ('8dio', 'new-terrie-solo-vocal-instrument-kontakt-vst-au-aax', 'Forgotten Voices Terrie', 'forgotten-voices-terrie', null::text), -- official product name | https://8dio.com/products/new-terrie-solo-vocal-instrument-kontakt-vst-au-aax
  ('8dio', 'oboe-virtuoso', 'Claire Oboe Virtuoso', 'claire-oboe-virtuoso', null::text), -- official product name | https://8dio.com/products/oboe-virtuoso
  ('8dio', 'piccolo-flute-virtuoso', 'Claire Piccolo Flute Virtuoso', 'claire-piccolo-flute-virtuoso', null::text), -- official product name | https://8dio.com/products/piccolo-flute-virtuoso
  ('8dio', 'progressive-house', 'EDM Progressive House Vol. 1', 'edm-progressive-house-vol-1', null::text), -- official product name | https://8dio.com/products/progressive-house
  ('8dio', 'progressive-house-v2', 'EDM Progressive House Vol. 2', 'edm-progressive-house-vol-2', null::text), -- official product name | https://8dio.com/products/progressive-house-v2
  ('8dio', 'progressive-metal', 'Progressive Metal Guitar', 'progressive-metal-guitar', null::text), -- official product name | https://8dio.com/products/progressive-metal
  ('8dio', 'prophet-5-add-on', 'PX Add On The Last P5', 'px-add-on-the-last-p5', null::text), -- official product name | https://8dio.com/products/prophet-5-add-on
  ('8dio', 'qanun-vst-au-aax-kontakt-instrument', 'Qanun', 'qanun', null::text), -- official product name | https://8dio.com/products/qanun-vst-au-aax-kontakt-instrument
  ('8dio', 'quintet-strings', 'Deep Quintet Strings', 'deep-quintet-strings', null::text), -- official product name | https://8dio.com/products/quintet-strings
  ('8dio', 'roadtrip', 'Road Trip', 'road-trip', null::text), -- official product name | https://8dio.com/products/roadtrip
  ('8dio', 'santur-vst-au-aax-kontakt-instrument', 'Santur', 'santur', null::text), -- official product name | https://8dio.com/products/santur-vst-au-aax-kontakt-instrument
  ('8dio', 'sequential-prophet-x-xl-add-10-1971-piano', 'PX Add On 1971 Estonia Grand', 'px-add-on-1971-estonia-grand', null::text), -- official product name | https://8dio.com/products/sequential-prophet-x-xl-add-10-1971-piano
  ('8dio', 'sequential-prophet-x-xl-add-11-1985-piano', 'PX Add On 1985 Passionate Piano', 'px-add-on-1985-passionate-piano', null::text), -- official product name | https://8dio.com/products/sequential-prophet-x-xl-add-11-1985-piano
  ('8dio', 'sequential-prophet-xxl-add-4-obx', 'PX Add On OG-X', 'px-add-on-og-x', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-4-obx
  ('8dio', 'sequential-prophet-xxl-add-7-prodigy', 'PX Add On Prodigius', 'px-add-on-prodigius', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-7-prodigy
  ('8dio', 'sequential-prophet-xxl-add-on-2-cp70-electric-grand-piano', 'PX Add On Electric Piano 70', 'px-add-on-electric-piano-70', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-on-2-cp70-electric-grand-piano
  ('8dio', 'sequential-prophet-xxl-add-on-5-t8', 'PX Add On T8', 'px-add-on-t8', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-on-5-t8
  ('8dio', 'sequential-prophet-xxl-add-on-6-jupiter-4', 'PX Add On Juniper 4', 'px-add-on-juniper-4', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-on-6-jupiter-4
  ('8dio', 'sequential-prophet-xxl-add-on-8-model-d', 'PX Add On The Classic D', 'px-add-on-the-classic-d', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-on-8-model-d
  ('8dio', 'sequential-prophet-xxl-add-on-9-juno-60', 'PX Add On Nuno 60', 'px-add-on-nuno-60', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-on-9-juno-60
  ('8dio', 'sequential-prophet-xxl-add-on-a2600', 'PX Add On Arpistic 2600', 'px-add-on-arpistic-2600', null::text), -- official product name | https://8dio.com/products/sequential-prophet-xxl-add-on-a2600
  ('8dio', 'shepard-tones-ii-for-kontakt-vst-au-aax-instruments-samples', 'Orchestral Shepards', 'orchestral-shepards', null::text), -- official product name | https://8dio.com/products/shepard-tones-ii-for-kontakt-vst-au-aax-instruments-samples
  ('8dio', 'solo-cello-designer-vst-au-aax-kontakt-instruments', 'Solo Cello Designer', 'solo-cello-designer', null::text), -- official product name | https://8dio.com/products/solo-cello-designer-vst-au-aax-kontakt-instruments
  ('8dio', 'solo-frame-drum', 'Solo Frame Drums', 'solo-frame-drums', null::text), -- official product name | https://8dio.com/products/solo-frame-drum
  ('8dio', 'solo-string-designers', 'Solo String Designers Bundle', 'solo-string-designers-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/solo-string-designers
  ('8dio', 'solo-studio-strings-cello', 'Studio Series Deep Solo Cello', 'studio-series-deep-solo-cello', null::text), -- official product name | https://8dio.com/products/solo-studio-strings-cello
  ('8dio', 'solo-studio-strings-viola', 'Studio Series Deep Solo Viola', 'studio-series-deep-solo-viola', null::text), -- official product name | https://8dio.com/products/solo-studio-strings-viola
  ('8dio', 'solo-studio-strings-violin', 'Studio Series Deep Solo Violin', 'studio-series-deep-solo-violin', null::text), -- official product name | https://8dio.com/products/solo-studio-strings-violin
  ('8dio', 'solo-violin-vst-au-aax-kontakt-instruments-samples-designer', 'Solo Violin Designer', 'solo-violin-designer', null::text), -- official product name | https://8dio.com/products/solo-violin-vst-au-aax-kontakt-instruments-samples-designer
  ('8dio', 'solo-voices', 'Seven Solo Voices', 'seven-solo-voices', 'bundles'::text), -- official product name | https://8dio.com/products/solo-voices
  ('8dio', 'soulful-studio-trumpet-2', 'Soulful Studio Trumpet Two', 'soulful-studio-trumpet-two', null::text), -- official product name | https://8dio.com/products/soulful-studio-trumpet-2
  ('8dio', 'soulful-trumpet-1', 'Soulful Studio Trumpet One', 'soulful-studio-trumpet-one', null::text), -- official product name | https://8dio.com/products/soulful-trumpet-1
  ('8dio', 'steel-drum-for-kontakt-vst-au-aax-samples', 'Studio Steel Drum', 'studio-steel-drum', null::text), -- official product name | https://8dio.com/products/steel-drum-for-kontakt-vst-au-aax-samples
  ('8dio', 'studio-fire-sax', 'Fire Sax', 'fire-sax', null::text), -- official product name | https://8dio.com/products/studio-fire-sax
  ('8dio', 'studio-fire-trombone', 'Fire Trombone', 'fire-trombone', null::text), -- official product name | https://8dio.com/products/studio-fire-trombone
  ('8dio', 'studio-percussion', 'Studio Percussion Bundle', 'studio-percussion-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/studio-percussion
  ('8dio', 'studio-percussion-auxiliary', '72 Studio Percussions', '72-studio-percussions', null::text), -- official product name | https://8dio.com/products/studio-percussion-auxiliary
  ('8dio', 'studio-percussion-orchestral-for-kontakt-vst-au-aax-samples', '6 Studio Orchestral Percussions', '6-studio-orchestral-percussions', null::text), -- official product name | https://8dio.com/products/studio-percussion-orchestral-for-kontakt-vst-au-aax-samples
  ('8dio', 'studio-quartet-series-deep-solo-bass', 'Studio Series Deep Solo Bass', 'studio-series-deep-solo-bass', null::text), -- official product name | https://8dio.com/products/studio-quartet-series-deep-solo-bass
  ('8dio', 'studio-saxophones-for-kontakt-vst-au-aax', 'Studio Sax Trio', 'studio-sax-trio', null::text), -- official product name | https://8dio.com/products/studio-saxophones-for-kontakt-vst-au-aax
  ('8dio', 'studio-series-fire-trumpet', 'Fire Trumpet', 'fire-trumpet', null::text), -- official product name | https://8dio.com/products/studio-series-fire-trumpet
  ('8dio', 'studio-suspended-non-tonal-kontakt-instrument-samples', 'Studio Percussion Suspended Non Tonal', 'studio-percussion-suspended-non-tonal', null::text), -- official product name | https://8dio.com/products/studio-suspended-non-tonal-kontakt-instrument-samples
  ('8dio', 'studio-suspended-tonal-kontakt-instrument-samples', 'Studio Percussion Suspended Tonal', 'studio-percussion-suspended-tonal', null::text), -- official product name | https://8dio.com/products/studio-suspended-tonal-kontakt-instrument-samples
  ('8dio', 'studio-tenor-saxophone', 'Studio Solo Saxophone', 'studio-solo-saxophone', null::text), -- official product name | https://8dio.com/products/studio-tenor-saxophone
  ('8dio', 'studio-vintage-series-all-keyboard-bundle-for-kontakt-vst-au-aax', 'Vintage Keyboard Bundle', 'vintage-keyboard-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/studio-vintage-series-all-keyboard-bundle-for-kontakt-vst-au-aax
  ('8dio', 'studio-vintage-series-cp70-electric-piano', 'Studio Electric Grand Piano', 'studio-electric-grand-piano', null::text), -- official product name | https://8dio.com/products/studio-vintage-series-cp70-electric-piano
  ('8dio', 'studio-vintage-series-studio-clavinet-for-kontakt-vst-au-aax', 'Studio Clavinet', 'studio-clavinet', null::text), -- official product name | https://8dio.com/products/studio-vintage-series-studio-clavinet-for-kontakt-vst-au-aax
  ('8dio', 'studio-vintage-series-studio-hammond-for-kontakt-vst-au-aax', 'Studio Vintage Hammond Organ', 'studio-vintage-hammond-organ', null::text), -- official product name | https://8dio.com/products/studio-vintage-series-studio-hammond-for-kontakt-vst-au-aax
  ('8dio', 'studio-vintage-series-suitcase-54-piano-kontakt-vst-au-aax', 'Studio Vintage Series Suitcase 54 Piano', 'studio-vintage-series-suitcase-54-piano', null::text), -- official product name | https://8dio.com/products/studio-vintage-series-suitcase-54-piano-kontakt-vst-au-aax
  ('8dio', 'studio-vocals-laurie-vst-au-aax-kontakt-instrument', 'Advanced Studio Voices Laurie', 'advanced-studio-voices-laurie', null::text), -- official product name | https://8dio.com/products/studio-vocals-laurie-vst-au-aax-kontakt-instrument
  ('8dio', 'studio-vocals-operatic-soprano', 'Opera Soprano Maria', 'opera-soprano-maria', null::text), -- official product name | https://8dio.com/products/studio-vocals-operatic-soprano
  ('8dio', 'studio-vocals-roula', 'Advanced Studio Voices Roula', 'advanced-studio-voices-roula', null::text), -- official product name | https://8dio.com/products/studio-vocals-roula
  ('8dio', 'terminus', 'Hybrid Tools Terminus', 'hybrid-tools-terminus', null::text), -- official product name | https://8dio.com/products/terminus
  ('8dio', 'the-bible-of-latin', 'The Bible of Salsa Volume 3', 'the-bible-of-salsa-volume-3', null::text), -- official product name | https://8dio.com/products/the-bible-of-latin
  ('8dio', 'the-bible-of-latin-2', 'The Bible of Salsa Volume 2', 'the-bible-of-salsa-volume-2', null::text), -- official product name | https://8dio.com/products/the-bible-of-latin-2
  ('8dio', 'the-bible-of-latin-3', 'The Bible of Salsa Volume 1', 'the-bible-of-salsa-volume-1', null::text), -- official product name | https://8dio.com/products/the-bible-of-latin-3
  ('8dio', 'the-bible-of-salsa-bundle', 'The Bible of Salsa Bundle', 'the-bible-of-salsa-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/the-bible-of-salsa-bundle
  ('8dio', 'the-new-acoustic-grand-bundle', 'Acoustic Grand Ensembles AGE Bundle', 'acoustic-grand-ensembles-age-bundle', 'bundles'::text), -- official product name | https://8dio.com/products/the-new-acoustic-grand-bundle
  ('8dio', 'the-new-acoustic-grand-v2', 'Acoustic Grand Ensembles AGE Vol. 2', 'acoustic-grand-ensembles-age-vol-2', null::text), -- official product name | https://8dio.com/products/the-new-acoustic-grand-v2
  ('8dio', 'the-new-bastard', 'Basstard', 'basstard', null::text), -- official product name | https://8dio.com/products/the-new-bastard
  ('8dio', 'the-new-bazantar', 'Bazantar', 'bazantar', null::text), -- official product name | https://8dio.com/products/the-new-bazantar
  ('8dio', 'the-new-century-ensemble-brass-french-horns', 'Century Ensemble Brass French Horns', 'century-ensemble-brass-french-horns', null::text), -- official product name | https://8dio.com/products/the-new-century-ensemble-brass-french-horns
  ('8dio', 'the-new-century-ensemble-brass-lite', 'Century Ensemble Brass LITE', 'century-ensemble-brass-lite', null::text), -- official product name | https://8dio.com/products/the-new-century-ensemble-brass-lite
  ('8dio', 'the-new-century-ensemble-brass-trombones', 'Century Ensemble Brass Trombones', 'century-ensemble-brass-trombones', null::text), -- official product name | https://8dio.com/products/the-new-century-ensemble-brass-trombones
  ('8dio', 'the-new-century-solo-brass-bass-trombone', 'Century Solo Brass Solo Bass Trombone', 'century-solo-brass-solo-bass-trombone', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-bass-trombone
  ('8dio', 'the-new-century-solo-brass-cimbasso', 'Century Solo Brass Solo Cimbasso', 'century-solo-brass-solo-cimbasso', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-cimbasso
  ('8dio', 'the-new-century-solo-brass-flugel-horn', 'Century Solo Brass Solo Flugel Horn', 'century-solo-brass-solo-flugel-horn', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-flugel-horn
  ('8dio', 'the-new-century-solo-brass-french-horn', 'Century Solo French Horn', 'century-solo-french-horn', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-french-horn
  ('8dio', 'the-new-century-solo-brass-trombone', 'Century Solo Brass Solo Trombone', 'century-solo-brass-solo-trombone', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-trombone
  ('8dio', 'the-new-century-solo-brass-trumpet', 'Century Solo Brass Solo Trumpet', 'century-solo-brass-solo-trumpet', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-trumpet
  ('8dio', 'the-new-century-solo-brass-tuba', 'Century Solo Brass Solo Tuba', 'century-solo-brass-solo-tuba', null::text), -- official product name | https://8dio.com/products/the-new-century-solo-brass-tuba
  ('8dio', 'the-new-epic-frame-drum-ensemble-vst-au-aax-kontakt-instruments', 'Epic Frame Drum Ensemble', 'epic-frame-drum-ensemble', null::text), -- official product name | https://8dio.com/products/the-new-epic-frame-drum-ensemble-vst-au-aax-kontakt-instruments
  ('8dio', 'the-new-forgotten-voices-barbary', 'Forgotten Voices Barbary', 'forgotten-voices-barbary', null::text), -- official product name | https://8dio.com/products/the-new-forgotten-voices-barbary
  ('8dio', 'the-new-forgotten-voices-cait', 'Forgotten Voices Cait', 'forgotten-voices-cait', null::text), -- official product name | https://8dio.com/products/the-new-forgotten-voices-cait
  ('8dio', 'the-new-glass-marimba', 'Glass Marimba', 'glass-marimba', null::text), -- official product name | https://8dio.com/products/the-new-glass-marimba
  ('8dio', 'the-new-hybrid-tools-1-instrument-for-kontakt-vst-au-aax', 'Hybrid Tools 1', 'hybrid-tools-1', null::text), -- official product name | https://8dio.com/products/the-new-hybrid-tools-1-instrument-for-kontakt-vst-au-aax
  ('8dio', 'the-new-propanium', 'Propanium', 'propanium', null::text), -- official product name | https://8dio.com/products/the-new-propanium
  ('8dio', 'the-new-rhythmic-aura-1-for-kontakt-vst-au-aax-samples', 'Rhythmic Aura 1', 'rhythmic-aura-1', null::text), -- official product name | https://8dio.com/products/the-new-rhythmic-aura-1-for-kontakt-vst-au-aax-samples
  ('8dio', 'the-new-solo-taiko-drum-vst-au-aax-kontakt-instruments-samples', 'Epic Solo Taiko', 'epic-solo-taiko', null::text), -- official product name | https://8dio.com/products/the-new-solo-taiko-drum-vst-au-aax-kontakt-instruments-samples
  ('8dio', 'the-newbowed-grand-piano', 'Bowed Piano', 'bowed-piano', null::text), -- official product name | https://8dio.com/products/the-newbowed-grand-piano
  ('8dio', 'windchimes', 'Wind Chimes', 'wind-chimes', null::text), -- official product name | https://8dio.com/products/windchimes
  ('8dio', 'zeus-drummer', 'Advanced Drum Series Zeus Kit', 'advanced-drum-series-zeus-kit', null::text) -- official product name | https://8dio.com/products/zeus-drummer
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Duplicates / old versions merged into the kept product (2)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('8dio', 'century-strings', '8dio', 'century-strings-bundle'), -- not a product on its own, sold as the Century Strings Bundle | https://8dio.com/products/century-strings-series
  ('8dio', 'century-brass', '8dio', 'all-century-brass-bundle') -- not a product on its own, sold as the All Century Brass Bundle | https://8dio.com/products/century-brass-bundle
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
  ('8dio', 'century-strings', '8dio', 'century-strings-bundle'), -- not a product on its own, sold as the Century Strings Bundle | https://8dio.com/products/century-strings-series
  ('8dio', 'century-brass', '8dio', 'all-century-brass-bundle') -- not a product on its own, sold as the All Century Brass Bundle | https://8dio.com/products/century-brass-bundle
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (3)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('8dio', 'century-ostinato-brass'), -- not a product: 8dio sells Century Ostinato Brass Trumpets and Horns / Trombones and Tuba separately (both listed) | https://8dio.com/collections/all
  ('spitfire-audio', 'bbc-symphony-orchestra-discover'), -- free product, nothing to resell | https://www.spitfireaudio.com/products/bbc-symphony-orchestra-discover
  ('spitfire-audio', 'spitfire-symphony-orchestra-discover') -- free product, nothing to resell | https://www.spitfireaudio.com/products/spitfire-symphony-orchestra-discover
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Wrong name or outdated version -> official current name (93)
update public.plugins p
set name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, (values
  ('spitfire-audio', 'abbey-road-one-grand-brass', 'Abbey Road One: Grand Brass', 'abbey-road-one-grand-brass', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-grand-brass
  ('spitfire-audio', 'abbey-road-one-legendary-low-strings', 'Abbey Road One: Legendary Low Strings', 'abbey-road-one-legendary-low-strings', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-legendary-low-strings
  ('spitfire-audio', 'abbey-road-one-mysterious-reeds', 'Abbey Road One: Mysterious Reeds', 'abbey-road-one-mysterious-reeds', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-mysterious-reeds
  ('spitfire-audio', 'abbey-road-one-soaring-high-strings', 'Abbey Road One: Soaring High Strings', 'abbey-road-one-soaring-high-strings', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-soaring-high-strings
  ('spitfire-audio', 'abbey-road-one-sparkling-woodwinds', 'Abbey Road One: Sparkling Woodwinds', 'abbey-road-one-sparkling-woodwinds', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-sparkling-woodwinds
  ('spitfire-audio', 'abbey-road-one-the-collection', 'Abbey Road One: The Collection', 'abbey-road-one-the-collection', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-the-collection
  ('spitfire-audio', 'abbey-road-one-thematic-horns', 'Abbey Road One: Thematic Horns', 'abbey-road-one-thematic-horns', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-thematic-horns
  ('spitfire-audio', 'abbey-road-one-thematic-trumpets', 'Abbey Road One: Thematic Trumpets', 'abbey-road-one-thematic-trumpets', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-thematic-trumpets
  ('spitfire-audio', 'abbey-road-one-vibrant-reeds', 'Abbey Road One: Vibrant Reeds', 'abbey-road-one-vibrant-reeds', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-vibrant-reeds
  ('spitfire-audio', 'abbey-road-one-wondrous-flutes', 'Abbey Road One: Wondrous Flutes', 'abbey-road-one-wondrous-flutes', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-one-wondrous-flutes
  ('spitfire-audio', 'abbey-road-orchestra-1st-violins-core', 'Abbey Road Orchestra: 1st Violins Core', 'abbey-road-orchestra-1st-violins-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-1st-violins-core
  ('spitfire-audio', 'abbey-road-orchestra-1st-violins-professional', 'Abbey Road Orchestra: 1st Violins Professional', 'abbey-road-orchestra-1st-violins-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-1st-violins-professional
  ('spitfire-audio', 'abbey-road-orchestra-2nd-violins-core', 'Abbey Road Orchestra: 2nd Violins Core', 'abbey-road-orchestra-2nd-violins-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-2nd-violins-core
  ('spitfire-audio', 'abbey-road-orchestra-2nd-violins-professional', 'Abbey Road Orchestra: 2nd Violins Professional', 'abbey-road-orchestra-2nd-violins-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-2nd-violins-professional
  ('spitfire-audio', 'abbey-road-orchestra-basses-core', 'Abbey Road Orchestra: Basses Core', 'abbey-road-orchestra-basses-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-basses-core
  ('spitfire-audio', 'abbey-road-orchestra-basses-professional', 'Abbey Road Orchestra: Basses Professional', 'abbey-road-orchestra-basses-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-basses-professional
  ('spitfire-audio', 'abbey-road-orchestra-bassoons-core', 'Abbey Road Orchestra: Bassoons Core', 'abbey-road-orchestra-bassoons-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-bassoons-core
  ('spitfire-audio', 'abbey-road-orchestra-bassoons-professional', 'Abbey Road Orchestra: Bassoons Professional', 'abbey-road-orchestra-bassoons-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-bassoons-professional
  ('spitfire-audio', 'abbey-road-orchestra-cellos-core', 'Abbey Road Orchestra: Cellos Core', 'abbey-road-orchestra-cellos-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-cellos-core
  ('spitfire-audio', 'abbey-road-orchestra-cellos-professional', 'Abbey Road Orchestra: Cellos Professional', 'abbey-road-orchestra-cellos-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-cellos-professional
  ('spitfire-audio', 'abbey-road-orchestra-clarinets-core', 'Abbey Road Orchestra: Clarinets Core', 'abbey-road-orchestra-clarinets-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-clarinets-core
  ('spitfire-audio', 'abbey-road-orchestra-clarinets-professional', 'Abbey Road Orchestra: Clarinets Professional', 'abbey-road-orchestra-clarinets-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-clarinets-professional
  ('spitfire-audio', 'abbey-road-orchestra-flutes-core', 'Abbey Road Orchestra: Flutes Core', 'abbey-road-orchestra-flutes-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-flutes-core
  ('spitfire-audio', 'abbey-road-orchestra-flutes-professional', 'Abbey Road Orchestra: Flutes Professional', 'abbey-road-orchestra-flutes-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-flutes-professional
  ('spitfire-audio', 'abbey-road-orchestra-high-percussion', 'Abbey Road Orchestra: High Percussion', 'abbey-road-orchestra-high-percussion', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-high-percussion
  ('spitfire-audio', 'abbey-road-orchestra-high-percussion-core', 'Abbey Road Orchestra: High Percussion Core', 'abbey-road-orchestra-high-percussion-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-high-percussion-core
  ('spitfire-audio', 'abbey-road-orchestra-low-percussion', 'Abbey Road Orchestra: Low Percussion', 'abbey-road-orchestra-low-percussion', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-low-percussion
  ('spitfire-audio', 'abbey-road-orchestra-low-percussion-core', 'Abbey Road Orchestra: Low Percussion Core', 'abbey-road-orchestra-low-percussion-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-low-percussion-core
  ('spitfire-audio', 'abbey-road-orchestra-metal-percussion', 'Abbey Road Orchestra: Metal Percussion', 'abbey-road-orchestra-metal-percussion', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-metal-percussion
  ('spitfire-audio', 'abbey-road-orchestra-metal-percussion-core', 'Abbey Road Orchestra: Metal Percussion Core', 'abbey-road-orchestra-metal-percussion-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-metal-percussion-core
  ('spitfire-audio', 'abbey-road-orchestra-oboes-core', 'Abbey Road Orchestra: Oboes Core', 'abbey-road-orchestra-oboes-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-oboes-core
  ('spitfire-audio', 'abbey-road-orchestra-oboes-professional', 'Abbey Road Orchestra: Oboes Professional', 'abbey-road-orchestra-oboes-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-oboes-professional
  ('spitfire-audio', 'abbey-road-orchestra-violas-core', 'Abbey Road Orchestra: Violas Core', 'abbey-road-orchestra-violas-core', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-violas-core
  ('spitfire-audio', 'abbey-road-orchestra-violas-professional', 'Abbey Road Orchestra: Violas Professional', 'abbey-road-orchestra-violas-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-orchestra-violas-professional
  ('spitfire-audio', 'abbey-road-two-iconic-strings', 'Abbey Road Two: Iconic Strings', 'abbey-road-two-iconic-strings', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-two-iconic-strings
  ('spitfire-audio', 'abbey-road-two-iconic-strings-professional', 'Abbey Road Two: Iconic Strings Professional', 'abbey-road-two-iconic-strings-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/abbey-road-two-iconic-strings-professional
  ('spitfire-audio', 'air-studios-reverb', 'AIR Studios Reverb', 'air-studios-reverb', 'reverb-delay'::text), -- official product name | https://www.spitfireaudio.com/products/air-studios-reverb
  ('spitfire-audio', 'air-studios-reverb-essentials', 'AIR Studios Reverb Essentials', 'air-studios-reverb-essentials', 'reverb-delay'::text), -- official product name | https://www.spitfireaudio.com/products/air-studios-reverb-essentials
  ('spitfire-audio', 'albion-iv-uist', 'Albion IV Uist', 'albion-iv-uist', null::text), -- official product name | https://www.spitfireaudio.com/products/albion-iv-uist
  ('spitfire-audio', 'albion-neo', 'Albion NEO', 'albion-neo', null::text), -- official product name | https://www.spitfireaudio.com/products/albion-neo
  ('spitfire-audio', 'albion-the-collection', 'Albion the Collection', 'albion-the-collection', null::text), -- official product name | https://www.spitfireaudio.com/products/albion-the-collection
  ('spitfire-audio', 'alev-lenz-3', 'Alev Lenz — 3', 'alev-lenz-3', null::text), -- official product name | https://www.spitfireaudio.com/products/alev-lenz-3
  ('spitfire-audio', 'alex-epton-entropy', 'Alex Epton — Entropy', 'alex-epton-entropy', null::text), -- official product name | https://www.spitfireaudio.com/products/alex-epton-entropy
  ('spitfire-audio', 'aska-matsumiya-crystal-bowls', 'Aska Matsumiya - Crystal Bowls', 'aska-matsumiya-crystal-bowls', null::text), -- official product name | https://www.spitfireaudio.com/products/aska-matsumiya-crystal-bowls
  ('spitfire-audio', 'bbc-radiophonic-workshop', 'BBC Radiophonic Workshop', 'bbc-radiophonic-workshop', null::text), -- official product name | https://www.spitfireaudio.com/products/bbc-radiophonic-workshop
  ('spitfire-audio', 'bbc-symphony-orchestra-core', 'BBC Symphony Orchestra Core', 'bbc-symphony-orchestra-core', null::text), -- official product name | https://www.spitfireaudio.com/products/bbc-symphony-orchestra-core
  ('spitfire-audio', 'bbc-symphony-orchestra-piano-core', 'BBC Symphony Orchestra Piano Core', 'bbc-symphony-orchestra-piano-core', null::text), -- official product name | https://www.spitfireaudio.com/products/bbc-symphony-orchestra-piano-core
  ('spitfire-audio', 'bbc-symphony-orchestra-piano-professional', 'BBC Symphony Orchestra Piano Professional', 'bbc-symphony-orchestra-piano-professional', null::text), -- official product name | https://www.spitfireaudio.com/products/bbc-symphony-orchestra-piano-professional
  ('spitfire-audio', 'blankforms-tape-synths', 'BlankFor.ms — Tape Synths', 'blankfor-ms-tape-synths', null::text), -- official product name | https://www.spitfireaudio.com/products/blankforms-tape-synths
  ('spitfire-audio', 'british-drama-toolkit-brass-and-reeds', 'British Drama Toolkit: Brass and Reeds', 'british-drama-toolkit-brass-and-reeds', null::text), -- official product name | https://www.spitfireaudio.com/products/british-drama-toolkit-brass-and-reeds
  ('spitfire-audio', 'bt-phobos', 'BT Phobos', 'bt-phobos', null::text), -- official product name | https://www.spitfireaudio.com/products/bt-phobos
  ('spitfire-audio', 'chateau-piano', 'Château Piano', 'chateau-piano', null::text), -- official product name | https://www.spitfireaudio.com/products/chateau-piano
  ('spitfire-audio', 'dan-keen-soft-string-textures', 'Soft String Textures', 'soft-string-textures', null::text), -- official product name | https://www.spitfireaudio.com/products/dan-keen-soft-string-textures
  ('spitfire-audio', 'darkstar-haunted-house', 'Darkstar — Haunted House', 'darkstar-haunted-house', null::text), -- official product name | https://www.spitfireaudio.com/products/darkstar-haunted-house
  ('spitfire-audio', 'edna-earth', 'eDNA Earth', 'edna-earth', null::text), -- official product name | https://www.spitfireaudio.com/products/edna-earth
  ('spitfire-audio', 'estatica', 'Estática', 'estatica', null::text), -- official product name | https://www.spitfireaudio.com/products/estatica
  ('spitfire-audio', 'fink-signatures', 'Fink — Signatures', 'fink-signatures', null::text), -- official product name | https://www.spitfireaudio.com/products/fink-signatures
  ('spitfire-audio', 'fred-poirier-afterglow', 'Afterglow', 'afterglow', null::text), -- official product name | https://www.spitfireaudio.com/products/fred-poirier-afterglow
  ('spitfire-audio', 'gaika-war-island', 'GAIKA — War Island', 'gaika-war-island', null::text), -- official product name | https://www.spitfireaudio.com/products/gaika-war-island
  ('spitfire-audio', 'glass-and-steel', 'Glass and Steel', 'glass-and-steel', null::text), -- official product name | https://www.spitfireaudio.com/products/glass-and-steel
  ('spitfire-audio', 'hainbach-landfill-totems', 'Hainbach — Landfill Totems', 'hainbach-landfill-totems', null::text), -- official product name | https://www.spitfireaudio.com/products/hainbach-landfill-totems
  ('spitfire-audio', 'hearth-and-hollow-folk-accordion', 'Hearth and Hollow - Folk Accordion', 'hearth-and-hollow-folk-accordion', null::text), -- official product name | https://www.spitfireaudio.com/products/hearth-and-hollow-folk-accordion
  ('spitfire-audio', 'hearth-and-hollow-folk-voices', 'Hearth and Hollow - Folk Voices', 'hearth-and-hollow-folk-voices', null::text), -- official product name | https://www.spitfireaudio.com/products/hearth-and-hollow-folk-voices
  ('spitfire-audio', 'hearth-and-hollow-plucked-folk-ensemble', 'Hearth and Hollow — Plucked Folk Ensemble', 'hearth-and-hollow-plucked-folk-ensemble', null::text), -- official product name | https://www.spitfireaudio.com/products/hearth-and-hollow-plucked-folk-ensemble
  ('spitfire-audio', 'henrietta-smith-rolla-spectrum', 'Henrietta Smith-Rolla — Spectrum', 'henrietta-smith-rolla-spectrum', null::text), -- official product name | https://www.spitfireaudio.com/products/henrietta-smith-rolla-spectrum
  ('spitfire-audio', 'jon-meyer-the-feathered-flute', 'The Feathered Flute', 'the-feathered-flute', null::text), -- official product name | https://www.spitfireaudio.com/products/jon-meyer-the-feathered-flute
  ('spitfire-audio', 'jupiter-by-trevor-horn', 'Jupiter by Trevor Horn', 'jupiter-by-trevor-horn', null::text), -- official product name | https://www.spitfireaudio.com/products/jupiter-by-trevor-horn
  ('spitfire-audio', 'kinematik-add-on-pack', 'Kinematik — Add-on Pack', 'kinematik-add-on-pack', null::text), -- official product name | https://www.spitfireaudio.com/products/kinematik-add-on-pack
  ('spitfire-audio', 'lea-bertucci-acoustic-shadows', 'Lea Bertucci — Acoustic Shadows', 'lea-bertucci-acoustic-shadows', null::text), -- official product name | https://www.spitfireaudio.com/products/lea-bertucci-acoustic-shadows
  ('spitfire-audio', 'lea-bertucci-xtended-vox', 'Lea Bertucci — Xtended Vox', 'lea-bertucci-xtended-vox', null::text), -- official product name | https://www.spitfireaudio.com/products/lea-bertucci-xtended-vox
  ('spitfire-audio', 'mg-soft-acoustic-guitar', 'Soft Acoustic Guitar', 'soft-acoustic-guitar', null::text), -- official product name | https://www.spitfireaudio.com/products/mg-soft-acoustic-guitar
  ('spitfire-audio', 'mg-soft-nylon-guitar', 'Soft Nylon Guitar', 'soft-nylon-guitar', null::text), -- official product name | https://www.spitfireaudio.com/products/mg-soft-nylon-guitar
  ('spitfire-audio', 'nok-cultural-ensemble-tape-percussion', 'Nok Cultural Ensemble — Tape Percussion', 'nok-cultural-ensemble-tape-percussion', null::text), -- official product name | https://www.spitfireaudio.com/products/nok-cultural-ensemble-tape-percussion
  ('spitfire-audio', 'olafur-arnalds-cells', 'Ólafur Arnalds Cells', 'olafur-arnalds-cells', null::text), -- official product name | https://www.spitfireaudio.com/products/olafur-arnalds-cells
  ('spitfire-audio', 'olafur-arnalds-chamber-evolutions', 'Ólafur Arnalds Chamber Evolutions', 'olafur-arnalds-chamber-evolutions', null::text), -- official product name | https://www.spitfireaudio.com/products/olafur-arnalds-chamber-evolutions
  ('spitfire-audio', 'olafur-arnalds-composer-toolkit', 'Ólafur Arnalds Composer Toolkit', 'olafur-arnalds-composer-toolkit', null::text), -- official product name | https://www.spitfireaudio.com/products/olafur-arnalds-composer-toolkit
  ('spitfire-audio', 'olafur-arnalds-stratus', 'Ólafur Arnalds Stratus', 'olafur-arnalds-stratus', null::text), -- official product name | https://www.spitfireaudio.com/products/olafur-arnalds-stratus
  ('spitfire-audio', 'olafur-arnalds-the-collection', 'Ólafur Arnalds the Collection', 'olafur-arnalds-the-collection', null::text), -- official product name | https://www.spitfireaudio.com/products/olafur-arnalds-the-collection
  ('spitfire-audio', 'oliver-patrice-weder-opw', 'Oliver Patrice Weder — OPW', 'oliver-patrice-weder-opw', null::text), -- official product name | https://www.spitfireaudio.com/products/oliver-patrice-weder-opw
  ('spitfire-audio', 'oliver-patrice-weder-the-pool-project', 'Oliver Patrice Weder — The Pool Project', 'oliver-patrice-weder-the-pool-project', null::text), -- official product name | https://www.spitfireaudio.com/products/oliver-patrice-weder-the-pool-project
  ('spitfire-audio', 'opw-the-shoe-factory', 'OPW - The Shoe Factory', 'opw-the-shoe-factory', null::text), -- official product name | https://www.spitfireaudio.com/products/opw-the-shoe-factory
  ('spitfire-audio', 'originals-epic-brass-and-woodwinds', 'Originals Epic Brass and Woodwinds', 'originals-epic-brass-and-woodwinds', null::text), -- official product name | https://www.spitfireaudio.com/products/originals-epic-brass-and-woodwinds
  ('spitfire-audio', 'peter-flint-tape-rooms', 'Tape Rooms', 'tape-rooms', null::text), -- official product name | https://www.spitfireaudio.com/products/peter-flint-tape-rooms
  ('spitfire-audio', 'raven-bush-moonglades', 'Raven Bush — Moonglades', 'raven-bush-moonglades', null::text), -- official product name | https://www.spitfireaudio.com/products/raven-bush-moonglades
  ('spitfire-audio', 'ronroco-by-gustavo-santaolalla', 'Ronroco by Gustavo Santaolalla', 'ronroco-by-gustavo-santaolalla', null::text), -- official product name | https://www.spitfireaudio.com/products/ronroco-by-gustavo-santaolalla
  ('spitfire-audio', 'samuel-sim-chrysalis', 'Samuel Sim — Chrysalis', 'samuel-sim-chrysalis', null::text), -- official product name | https://www.spitfireaudio.com/products/samuel-sim-chrysalis
  ('spitfire-audio', 'shakespeares-church-organ', 'Shakespeare''s Church Organ', 'shakespeare-s-church-organ', null::text), -- official product name | https://www.spitfireaudio.com/products/shakespeares-church-organ
  ('spitfire-audio', 'skyscapeparadise-gaze', 'GAZE', 'gaze', null::text), -- official product name | https://www.spitfireaudio.com/products/skyscapeparadise-gaze
  ('spitfire-audio', 'sound-dust-vol-1', 'Sound Dust Vol. 1', 'sound-dust-vol-1', null::text), -- official product name | https://www.spitfireaudio.com/products/sound-dust-vol-1
  ('spitfire-audio', 'sound-dust-vol-2', 'Sound Dust Vol. 2', 'sound-dust-vol-2', null::text), -- official product name | https://www.spitfireaudio.com/products/sound-dust-vol-2
  ('spitfire-audio', 'speculative-memories', 'Yair Elazar Glotman — Speculative Memories', 'yair-elazar-glotman-speculative-memories', null::text), -- official product name | https://www.spitfireaudio.com/products/speculative-memories
  ('spitfire-audio', 'tenebra-by-the-newton-brothers', 'Tenebra by The Newton Brothers', 'tenebra-by-the-newton-brothers', null::text), -- official product name | https://www.spitfireaudio.com/products/tenebra-by-the-newton-brothers
  ('spitfire-audio', 'trinz-colours-pst', 'Trinz — Colours PST', 'trinz-colours-pst', null::text) -- official product name | https://www.spitfireaudio.com/products/trinz-colours-pst
) as v(dev, old_slug, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.old_slug
  and not exists (select 1 from public.plugins x where x.developer_id = d.id and x.slug = v.new_slug);

-- Duplicates / old versions merged into the kept product (2)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('spitfire-audio', 'albion-uist', 'spitfire-audio', 'albion-iv-uist'), -- duplicate of Albion IV Uist | https://www.spitfireaudio.com/products/albion-iv-uist
  ('spitfire-audio', 'symphonic-motions', 'spitfire-audio', 'spitfire-symphonic-motions') -- duplicate of Spitfire Symphonic Motions | https://www.spitfireaudio.com/products/spitfire-symphonic-motions
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
  ('spitfire-audio', 'albion-uist', 'spitfire-audio', 'albion-iv-uist'), -- duplicate of Albion IV Uist | https://www.spitfireaudio.com/products/albion-iv-uist
  ('spitfire-audio', 'symphonic-motions', 'spitfire-audio', 'spitfire-symphonic-motions') -- duplicate of Spitfire Symphonic Motions | https://www.spitfireaudio.com/products/spitfire-symphonic-motions
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'crystalline', 'baby-audio', 'crystalline') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/crystalline (third-party marketplace item, vendor: Baby Audio)
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
  ('plugin-alliance', 'crystalline', 'baby-audio', 'crystalline') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/crystalline (third-party marketplace item, vendor: Baby Audio)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (1)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('plugin-alliance', 'random') -- third-party marketplace product (BEATSURFING), publisher not in catalogue | https://www.plugin-alliance.com/products/random (third-party marketplace item, vendor: BEATSURFING)
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (1)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'krotos-weaponiser-basic', 'krotos', 'Weaponiser Basic', 'weaponiser-basic', null::text) -- published by Krotos | https://www.plugin-alliance.com/products/krotos-weaponiser-basic (third-party marketplace item, vendor: Krotos)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (2)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'transit-2', 'baby-audio', 'transit-2'), -- already listed under Baby Audio | https://www.plugin-alliance.com/products/transit-2 (third-party marketplace item, vendor: Baby Audio)
  ('plugin-alliance', 'dehumaniser-2', 'krotos', 'dehumaniser-2') -- already listed under Krotos | https://www.plugin-alliance.com/products/dehumaniser-2 (third-party marketplace item, vendor: Krotos)
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
  ('plugin-alliance', 'transit-2', 'baby-audio', 'transit-2'), -- already listed under Baby Audio | https://www.plugin-alliance.com/products/transit-2 (third-party marketplace item, vendor: Baby Audio)
  ('plugin-alliance', 'dehumaniser-2', 'krotos', 'dehumaniser-2') -- already listed under Krotos | https://www.plugin-alliance.com/products/dehumaniser-2 (third-party marketplace item, vendor: Krotos)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (2)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'icondrum', 'gforce-software', 'IconDrum', 'icondrum', null::text), -- published by Gforce Software | https://www.plugin-alliance.com/products/icondrum (third-party marketplace item, vendor: Gforce Software)
  ('plugin-alliance', 'vsm-iv', 'gforce-software', 'VSM IV', 'vsm-iv', null::text) -- published by Gforce Software | https://www.plugin-alliance.com/products/vsm-iv (third-party marketplace item, vendor: Gforce Software)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'axxess', 'gforce-software', 'axxess') -- already listed under GForce Software | https://www.plugin-alliance.com/products/axxess (third-party marketplace item, vendor: Gforce Software)
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
  ('plugin-alliance', 'axxess', 'gforce-software', 'axxess') -- already listed under GForce Software | https://www.plugin-alliance.com/products/axxess (third-party marketplace item, vendor: Gforce Software)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (2)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('plugin-alliance', '7deadlysnares'), -- third-party marketplace product (BEATSURFING), publisher not in catalogue | https://www.plugin-alliance.com/products/7deadlysnares (third-party marketplace item, vendor: BEATSURFING)
  ('plugin-alliance', 'lunchtable') -- third-party marketplace product (BEATSURFING), publisher not in catalogue | https://www.plugin-alliance.com/products/lunchtable (third-party marketplace item, vendor: BEATSURFING)
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Already listed under its real developer -> merged there (3)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'reformer-pro', 'krotos', 'reformer-pro'), -- already listed under Krotos | https://www.plugin-alliance.com/products/reformer-pro (third-party marketplace item, vendor: Krotos)
  ('plugin-alliance', 'smooth-operator-pro', 'baby-audio', 'smooth-operator-pro'), -- already listed under Baby Audio | https://www.plugin-alliance.com/products/smooth-operator-pro (third-party marketplace item, vendor: Baby Audio)
  ('plugin-alliance', 'comeback-kid', 'baby-audio', 'comeback-kid') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/comeback-kid (third-party marketplace item, vendor: Baby Audio)
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
  ('plugin-alliance', 'reformer-pro', 'krotos', 'reformer-pro'), -- already listed under Krotos | https://www.plugin-alliance.com/products/reformer-pro (third-party marketplace item, vendor: Krotos)
  ('plugin-alliance', 'smooth-operator-pro', 'baby-audio', 'smooth-operator-pro'), -- already listed under Baby Audio | https://www.plugin-alliance.com/products/smooth-operator-pro (third-party marketplace item, vendor: Baby Audio)
  ('plugin-alliance', 'comeback-kid', 'baby-audio', 'comeback-kid') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/comeback-kid (third-party marketplace item, vendor: Baby Audio)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (2)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('plugin-alliance', 'beatfader'), -- third-party marketplace product (BEATSURFING), publisher not in catalogue | https://www.plugin-alliance.com/products/beatfader (third-party marketplace item, vendor: BEATSURFING)
  ('plugin-alliance', 'cheat-code') -- third-party marketplace product (BEATSURFING), publisher not in catalogue | https://www.plugin-alliance.com/products/cheat-code (third-party marketplace item, vendor: BEATSURFING)
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'spaced-out', 'baby-audio', 'spaced-out') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/spaced-out (third-party marketplace item, vendor: Baby Audio)
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
  ('plugin-alliance', 'spaced-out', 'baby-audio', 'spaced-out') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/spaced-out (third-party marketplace item, vendor: Baby Audio)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (1)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'tekno', 'baby-audio', 'Tekno', 'tekno', null::text) -- published by Baby Audio | https://www.plugin-alliance.com/products/tekno (third-party marketplace item, vendor: Baby Audio)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (1)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('plugin-alliance', 'random-metal') -- third-party marketplace product (BEATSURFING), publisher not in catalogue | https://www.plugin-alliance.com/products/random-metal (third-party marketplace item, vendor: BEATSURFING)
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (5)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'ocelot-limiter', 'fuse-audio-labs', 'Ocelot Limiter', 'ocelot-limiter', null::text), -- published by Fuse Audio Labs | https://www.plugin-alliance.com/products/ocelot-limiter (third-party marketplace item, vendor: Fuse Audio Labs)
  ('plugin-alliance', 'ocelot-clipper', 'fuse-audio-labs', 'Ocelot Clipper', 'ocelot-clipper', null::text), -- published by Fuse Audio Labs | https://www.plugin-alliance.com/products/ocelot-clipper (third-party marketplace item, vendor: Fuse Audio Labs)
  ('plugin-alliance', 'ocelot-bundle', 'fuse-audio-labs', 'Ocelot Bundle', 'ocelot-bundle', null::text), -- published by Fuse Audio Labs | https://www.plugin-alliance.com/products/ocelot-bundle (third-party marketplace item, vendor: Fuse Audio Labs)
  ('plugin-alliance', 'igniter', 'krotos', 'Igniter', 'igniter', null::text), -- published by Krotos | https://www.plugin-alliance.com/products/igniter (third-party marketplace item, vendor: Krotos)
  ('plugin-alliance', 'humanoid', 'baby-audio', 'Humanoid', 'humanoid', null::text) -- published by Baby Audio | https://www.plugin-alliance.com/products/humanoid (third-party marketplace item, vendor: Baby Audio)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'ba-1', 'baby-audio', 'ba-1') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/ba-1 (third-party marketplace item, vendor: Baby Audio)
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
  ('plugin-alliance', 'ba-1', 'baby-audio', 'ba-1') -- already listed under Baby Audio | https://www.plugin-alliance.com/products/ba-1 (third-party marketplace item, vendor: Baby Audio)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (2)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'map', 'gforce-software', 'MAP', 'map', null::text), -- published by Gforce Software | https://www.plugin-alliance.com/products/map (third-party marketplace item, vendor: Gforce Software)
  ('plugin-alliance', 'limiter', 'mastering-the-mix', 'LIMITER', 'limiter', null::text) -- published by Mastering The Mix | https://www.plugin-alliance.com/products/limiter (third-party marketplace item, vendor: Mastering The Mix)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'expose-2', 'mastering-the-mix', 'expose-2') -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/expose-2 (third-party marketplace item, vendor: Mastering The Mix)
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
  ('plugin-alliance', 'expose-2', 'mastering-the-mix', 'expose-2') -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/expose-2 (third-party marketplace item, vendor: Mastering The Mix)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (1)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'faster-master', 'mastering-the-mix', 'FASTER MASTER', 'faster-master', null::text) -- published by Mastering The Mix | https://www.plugin-alliance.com/products/faster-master (third-party marketplace item, vendor: Mastering The Mix)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (4)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'levels', 'mastering-the-mix', 'levels'), -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/levels (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'bassroom', 'mastering-the-mix', 'bassroom'), -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/bassroom (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'mixroom', 'mastering-the-mix', 'mixroom'), -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/mixroom (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'fuser', 'mastering-the-mix', 'fuser') -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/fuser (third-party marketplace item, vendor: Mastering The Mix)
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
  ('plugin-alliance', 'levels', 'mastering-the-mix', 'levels'), -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/levels (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'bassroom', 'mastering-the-mix', 'bassroom'), -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/bassroom (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'mixroom', 'mastering-the-mix', 'mixroom'), -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/mixroom (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'fuser', 'mastering-the-mix', 'fuser') -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/fuser (third-party marketplace item, vendor: Mastering The Mix)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (4)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'ocelot-octaver', 'fuse-audio-labs', 'Ocelot Octaver', 'ocelot-octaver', null::text), -- published by Fuse Audio Labs | https://www.plugin-alliance.com/products/ocelot-octaver (third-party marketplace item, vendor: Fuse Audio Labs)
  ('plugin-alliance', 'ocelot-upmixer', 'fuse-audio-labs', 'Ocelot Upmixer', 'ocelot-upmixer', null::text), -- published by Fuse Audio Labs | https://www.plugin-alliance.com/products/ocelot-upmixer (third-party marketplace item, vendor: Fuse Audio Labs)
  ('plugin-alliance', 'reso', 'mastering-the-mix', 'RESO', 'reso', null::text), -- published by Mastering The Mix | https://www.plugin-alliance.com/products/reso (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'reference', 'mastering-the-mix', 'REFERENCE 3', 'reference-3', null::text) -- published by Mastering The Mix | https://www.plugin-alliance.com/products/reference (third-party marketplace item, vendor: Mastering The Mix)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'animate', 'mastering-the-mix', 'animate') -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/animate (third-party marketplace item, vendor: Mastering The Mix)
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
  ('plugin-alliance', 'animate', 'mastering-the-mix', 'animate') -- already listed under Mastering The Mix | https://www.plugin-alliance.com/products/animate (third-party marketplace item, vendor: Mastering The Mix)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (5)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'grainferno', 'baby-audio', 'Grainferno', 'grainferno', null::text), -- published by Baby Audio | https://www.plugin-alliance.com/products/grainferno (third-party marketplace item, vendor: Baby Audio)
  ('plugin-alliance', 'stereovault', 'mastering-the-mix', 'STEREOVAULT', 'stereovault', null::text), -- published by Mastering The Mix | https://www.plugin-alliance.com/products/stereovault (third-party marketplace item, vendor: Mastering The Mix)
  ('plugin-alliance', 'complete-bundle', 'baby-audio', 'Complete Bundle', 'complete-bundle', null::text), -- published by Baby Audio | https://www.plugin-alliance.com/products/complete-bundle (third-party marketplace item, vendor: Baby Audio)
  ('plugin-alliance', 'gforce-software-oberheim-dmx', 'gforce-software', 'Oberheim DMX', 'oberheim-dmx', null::text), -- published by Gforce Software | https://www.plugin-alliance.com/products/gforce-software-oberheim-dmx (third-party marketplace item, vendor: Gforce Software)
  ('plugin-alliance', 'imposcar3', 'gforce-software', 'impOSCar3', 'imposcar3', null::text) -- published by Gforce Software | https://www.plugin-alliance.com/products/imposcar3 (third-party marketplace item, vendor: Gforce Software)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'minimonsta2', 'gforce-software', 'minimonsta-2') -- already listed under GForce Software | https://www.plugin-alliance.com/products/minimonsta2 (third-party marketplace item, vendor: Gforce Software)
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
  ('plugin-alliance', 'minimonsta2', 'gforce-software', 'minimonsta-2') -- already listed under GForce Software | https://www.plugin-alliance.com/products/minimonsta2 (third-party marketplace item, vendor: Gforce Software)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Moved to the developer that actually publishes it (3)
update public.plugins p
set developer_id = td.id, name = v.name, slug = v.new_slug, category = coalesce(v.category, p.category)
from public.developers d, public.developers td, (values
  ('plugin-alliance', 'novation-bass-station', 'gforce-software', 'Novation Bass Station', 'novation-bass-station', null::text), -- published by Gforce Software | https://www.plugin-alliance.com/products/novation-bass-station (third-party marketplace item, vendor: Gforce Software)
  ('plugin-alliance', 'oberheim-ob-x', 'gforce-software', 'Oberheim OB-X', 'oberheim-ob-x', null::text), -- published by Gforce Software | https://www.plugin-alliance.com/products/oberheim-ob-x (third-party marketplace item, vendor: Gforce Software)
  ('plugin-alliance', 'oberheim-tvs-pro', 'gforce-software', 'Oberheim TVS Pro', 'oberheim-tvs-pro', null::text) -- published by Gforce Software | https://www.plugin-alliance.com/products/oberheim-tvs-pro (third-party marketplace item, vendor: Gforce Software)
) as v(dev, slug, target_dev, name, new_slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug and td.slug = v.target_dev
  and not exists (select 1 from public.plugins x where x.developer_id = td.id and x.slug = v.new_slug);

-- Already listed under its real developer -> merged there (1)
-- Move any listing to the kept product, then drop the duplicate.
with v(dev, slug, target_dev, target_slug) as (values
  ('plugin-alliance', 'oddity3', 'gforce-software', 'oddity3') -- already listed under GForce Software | https://www.plugin-alliance.com/products/oddity3 (third-party marketplace item, vendor: Gforce Software)
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
  ('plugin-alliance', 'oddity3', 'gforce-software', 'oddity3') -- already listed under GForce Software | https://www.plugin-alliance.com/products/oddity3 (third-party marketplace item, vendor: Gforce Software)
) as v(dev, slug, target_dev, target_slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and exists (select 1 from public.plugins t join public.developers td on td.id = t.developer_id
              where td.slug = v.target_dev and t.slug = v.target_slug)
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Category fixes (58)
update public.plugins p set category = v.category
from public.developers d, (values
  ('plugin-alliance', 'c502v', 'compression'), -- official product description | https://www.plugin-alliance.com/products/c502v
  ('plugin-alliance', 'oldtimer', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/oldtimer
  ('plugin-alliance', 'machine-head', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/machine-head
  ('plugin-alliance', 'u2a', 'compression'), -- official product description | https://www.plugin-alliance.com/products/u2a
  ('plugin-alliance', 'bx-xl-v3', 'mastering'), -- official product description | https://www.plugin-alliance.com/products/bx_xl-v3
  ('plugin-alliance', 'bx-clipper', 'mastering'), -- official product description | https://www.plugin-alliance.com/products/bx_clipper
  ('plugin-alliance', 'vac-attack', 'compression'), -- official product description | https://www.plugin-alliance.com/products/vac-attack
  ('plugin-alliance', 'silver-bullet-mk2', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/silver-bullet-mk2
  ('plugin-alliance', 'bx-glue', 'compression'), -- official product description | https://www.plugin-alliance.com/products/bx_glue
  ('plugin-alliance', 'battalion', 'synths'), -- official product description | https://www.plugin-alliance.com/products/battalion
  ('plugin-alliance', 'big-al', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/big-al
  ('plugin-alliance', 'mu-66', 'compression'), -- official product description | https://www.plugin-alliance.com/products/mu-66
  ('plugin-alliance', 'bm60', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/bm60
  ('plugin-alliance', 'sculpt', 'compression'), -- official product description | https://www.plugin-alliance.com/products/sculpt
  ('plugin-alliance', 'bx-aura', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/bx_aura
  ('plugin-alliance', 'sa2rate-2', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/sa2rate-2
  ('plugin-alliance', 'lisa', 'eq'), -- official product description | https://www.plugin-alliance.com/products/lisa
  ('plugin-alliance', 'u17', 'compression'), -- official product description | https://www.plugin-alliance.com/products/u17
  ('plugin-alliance', 'pq', 'eq'), -- official product description | https://www.plugin-alliance.com/products/pq
  ('plugin-alliance', 'vsm-3', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/vsm-3
  ('plugin-alliance', 'bx-hybrid-v2', 'eq'), -- official product description | https://www.plugin-alliance.com/products/bx_hybrid-v2
  ('plugin-alliance', 'tcl-2', 'compression'), -- official product description | https://www.plugin-alliance.com/products/tcl-2
  ('plugin-alliance', 'zip', 'compression'), -- official product description | https://www.plugin-alliance.com/products/zip
  ('plugin-alliance', 'bx-opto', 'compression'), -- official product description | https://www.plugin-alliance.com/products/bx_opto
  ('plugin-alliance', 'bx-megadual', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/bx_megadual
  ('plugin-alliance', 'vsc-2', 'compression'), -- official product description | https://www.plugin-alliance.com/products/vsc-2
  ('plugin-alliance', '6x-500', 'eq'), -- official product description | https://www.plugin-alliance.com/products/6x-500
  ('plugin-alliance', 'bx-bassdude', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/bx_bassdude
  ('plugin-alliance', '7x-500', 'compression'), -- official product description | https://www.plugin-alliance.com/products/7x-500
  ('plugin-alliance', 'channelx', 'channel-strips'), -- official product description | https://www.plugin-alliance.com/products/channelx
  ('plugin-alliance', 'phils-cascade', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/phils-cascade
  ('plugin-alliance', 'sandman', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/sandman
  ('plugin-alliance', 'sandman-pro', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/sandman-pro
  ('plugin-alliance', 'magnum-k', 'compression'), -- official product description | https://www.plugin-alliance.com/products/magnum-k
  ('plugin-alliance', 'pex-500', 'eq'), -- official product description | https://www.plugin-alliance.com/products/pex-500
  ('plugin-alliance', 'bx-cleansweep-pro', 'eq'), -- official product description | https://www.plugin-alliance.com/products/bx_cleansweep-pro
  ('plugin-alliance', 'dsm-v3', 'mastering'), -- official product description | https://www.plugin-alliance.com/products/dsm-v3
  ('plugin-alliance', 'v-4b', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/v-4b
  ('plugin-alliance', 'bx-rooms', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/bx_rooms
  ('plugin-alliance', 'ds-40', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/ds-40
  ('plugin-alliance', 'herbert', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/herbert
  ('plugin-alliance', 'bx-rockergain100', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/bx_rockergain100
  ('plugin-alliance', 'overdrive-supreme-50', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/overdrive-supreme-50
  ('plugin-alliance', 'train-ii', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/train-ii
  ('plugin-alliance', 'buxom-betty', 'guitar-amps'), -- official product description | https://www.plugin-alliance.com/products/buxom-betty
  ('plugin-alliance', 'lo-fi-af', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/lo-fi-af
  ('plugin-alliance', 'tails', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/tails
  ('plugin-alliance', 'silo', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/silo
  ('plugin-alliance', 'stage', 'reverb-delay'), -- official product description | https://www.plugin-alliance.com/products/stage
  ('plugin-alliance', 'soma', 'eq'), -- official product description | https://www.plugin-alliance.com/products/soma
  ('plugin-alliance', 'v76u73', 'compression'), -- official product description | https://www.plugin-alliance.com/products/v76u73
  ('plugin-alliance', 'indent-2', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/indent-2
  ('plugin-alliance', 'bde', 'saturation'), -- official product description | https://www.plugin-alliance.com/products/bde
  ('plugin-alliance', 'laal', 'mastering'), -- official product description | https://www.plugin-alliance.com/products/laal
  ('plugin-alliance', 'hitstrip', 'channel-strips'), -- official product description | https://www.plugin-alliance.com/products/hitstrip
  ('plugin-alliance', 'thorn', 'synths'), -- official product description | https://www.plugin-alliance.com/products/thorn
  ('plugin-alliance', 'knocktonal', 'eq'), -- official product description | https://www.plugin-alliance.com/products/knocktonal
  ('plugin-alliance', 'unfiltered-audio-sandman-pro', 'reverb-delay') -- official product description | https://www.plugin-alliance.com
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Spelling / official name (slug unchanged) (1)
update public.plugins p set name = v.name
from public.developers d, (values
  ('plugin-alliance', 'train-ii', 'Train II') -- spelling | https://www.plugin-alliance.com/products/train-ii
) as v(dev, slug, name)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Removed: not a real product of this developer, free, hardware, or not sold on its own (38)
-- A product that already has a listing is kept (nothing is deleted under a seller).
delete from public.plugins p
using public.developers d, (values
  ('meldaproduction', 'magc'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'manalyzer'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mautopan'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mautopitch'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mbandpass'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mbitfun'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mccgenerator'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mchannelmatrix'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mcharmverb'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mcomb'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mcompressor'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mconvolutionez'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mdelay'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mequalizer'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mflanger'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mfreeformphase'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mfreqshifter'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mloudnessanalyzer'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mmetronome'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mnoisegenerator'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mnotepad'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'moscillator'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'moscilloscope'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mphaser'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mratio'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mratiomb'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mrecorder'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mringmodulator'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'msaturator'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mspectralpan'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mstereoexpander'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mstereoscope'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mtremolo'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mtuner'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mutility'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mvibrato'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mwavefolder'), -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
  ('meldaproduction', 'mwaveshaper') -- free plugin (part of the free MFreeFXBundle) | https://www.meldaproduction.com/MFreeFXBundle
) as v(dev, slug)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);

-- Category fixes (11)
update public.plugins p set category = v.category
from public.developers d, (values
  ('meldaproduction', 'mturbocomp', 'compression'), -- product type | https://www.meldaproduction.com/MTurboComp
  ('meldaproduction', 'mturbocomple', 'compression'), -- product type | https://www.meldaproduction.com/MTurboCompLE
  ('meldaproduction', 'mdistortionmb', 'saturation'), -- product type | https://www.meldaproduction.com/MDistortionMB
  ('meldaproduction', 'mwaveshapermb', 'saturation'), -- product type | https://www.meldaproduction.com/MWaveShaperMB
  ('meldaproduction', 'mwavefoldermb', 'saturation'), -- product type | https://www.meldaproduction.com/MWaveFolderMB
  ('meldaproduction', 'mbitfunmb', 'saturation'), -- product type | https://www.meldaproduction.com/MBitFunMB
  ('meldaproduction', 'mconvolutionmb', 'reverb-delay'), -- product type | https://www.meldaproduction.com/MConvolutionMB
  ('meldaproduction', 'mdrumstrip', 'channel-strips'), -- product type | https://www.meldaproduction.com/MDrumStrip
  ('meldaproduction', 'msoundfactoryessentials', 'synths'), -- product type | https://www.meldaproduction.com/MSoundFactoryEssentials
  ('meldaproduction', 'msoundfactoryle', 'synths'), -- product type | https://www.meldaproduction.com/MSoundFactoryLE
  ('meldaproduction', 'msoundfactoryplayer', 'synths') -- product type | https://www.meldaproduction.com/MSoundFactoryPlayer
) as v(dev, slug, category)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;

-- Spelling / official name (slug unchanged) (279)
update public.plugins p set name = v.name
from public.developers d, (values
  ('toontrack', 'acoustic-pop-ballads-ezkeys-midi', 'Acoustic Pop Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'acoustic-pop-ezkeys-midi', 'Acoustic Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'acoustic-songwriter-2-ezkeys-midi', 'Acoustic Songwriter 2 EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'acoustic-songwriter-3-ezkeys-midi', 'Acoustic Songwriter 3 EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'acoustic-songwriter-ezbass-midi', 'Acoustic Songwriter EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'acoustic-songwriter-ezkeys-midi', 'Acoustic Songwriter EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'acoustic-songwriter-ezmix-pack', 'Acoustic Songwriter EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'al-schmitt-ezmix-pack', 'Al Schmitt EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'alt-pop-ezkeys-midi', 'Alt Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'alternative-rock-ezmix-pack', 'Alternative Rock EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ambient-delays-ezmix-pack', 'Ambient Delays EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ambient-ezmix-pack', 'Ambient EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ambient-pop-ezkeys-midi', 'Ambient Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ambient-reverbs-ezmix-pack', 'Ambient Reverbs EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ambient-vibes-ezkeys-midi', 'Ambient Vibes EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'americana-ezbass-midi', 'Americana EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'americana-ezkeys-midi', 'Americana EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'amps-ezmix-pack', 'Amps EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'andy-sneap-ezmix-pack', 'Andy Sneap EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'aor-ballad-grooves', 'AOR Ballad Grooves'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'aor-ballads-ezkeys-midi', 'AOR Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'aor-ezkeys-midi', 'AOR EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'aor-grooves-midi', 'AOR Grooves MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'arena-rock-ezkeys-midi', 'Arena Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'art-rock-ezkeys-midi', 'Art Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'atmospheric-ezkeys-midi', 'Atmospheric EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ballads-2-ezkeys-midi', 'Ballads 2 EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ballads-ezkeys-midi', 'Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'basic-rock-ezbass-midi', 'Basic Rock EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'basic-rock-ezkeys-midi', 'Basic Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'bass-amps-ezmix-pack', 'Bass Amps EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'bass-toolbox-ezmix-pack', 'Bass Toolbox EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'beat-ideas-ezkeys-midi', 'Beat Ideas EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'beat-revamper-ezmix-pack', 'Beat Revamper EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'big-band-ezkeys-midi', 'Big Band EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'big-rock-guitars-ezmix-pack', 'Big Rock Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'blues-ezkeys-midi', 'Blues EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'blues-guitars-ezmix-pack', 'Blues Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'bob-rock-ezmix-pack', 'Bob Rock EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'boogie-ezkeys-midi', 'Boogie EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'british-invasion-ezbass-midi', 'British Invasion EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'british-invasion-ezkeys-midi', 'British Invasion EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'buses-masters-ezmix-pack', 'Buses Masters EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'chuck-ainlay-ezmix-pack', 'Chuck Ainlay EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'cinematic-fx-ezmix-pack', 'Cinematic Fx EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'cinematic-guitars-ezmix-pack', 'Cinematic Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'cinematic-mallets-ezkeys-midi', 'Cinematic Mallets EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'classic-amps-ezmix-pack', 'Classic Amps EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'classic-rock-organ-ezkeys-midi', 'Classic Rock Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'classic-soul-ezkeys-midi', 'Classic Soul EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'classical-ezkeys-midi', 'Classical EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'colin-richardson-ezmix-pack', 'Colin Richardson EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'compression-saturation-ezmix-pack', 'Compression Saturation EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'contemporary-country-ezkeys-midi', 'Contemporary Country EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'contemporary-rb-ezbass-midi', 'Contemporary R&B EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'contemporary-rb-ezkeys-midi', 'Contemporary R&B EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'contemporary-rb-grooves', 'Contemporary R&B Grooves'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'contemporary-soul-ballads-ezkeys-midi', 'Contemporary Soul Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'core-expansion-ezmix-pack', 'Core Expansion EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'country-ezkeys-midi', 'Country EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'country-guitars-ezmix-pack', 'Country Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'country-pop-ezkeys-midi', 'Country Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'country-roots-ezkeys-midi', 'Country Roots EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'dark-ambience-ezmix-pack', 'Dark Ambience EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'death-metal-guitars-ezmix-pack', 'Death Metal Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'detroit-soul-ezbass-midi', 'Detroit Soul EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'detroit-soul-ezkeys-midi', 'Detroit Soul EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'dimensional-guitars-ezmix-pack', 'Dimensional Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'dirt-ezmix-pack', 'Dirt EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'disco-ezbass-midi', 'Disco EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'disco-ezkeys-midi', 'Disco EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'dream-pop-ezkeys-midi', 'Dream Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'drum-elements-ezmix-pack', 'Drum Elements EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'drums-toolbox-ezmix-pack', 'Drums Toolbox EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'duality-ii-ezx', 'Duality II EZX'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'edm-ezkeys-midi', 'EDM EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'edm-grooves', 'EDM Grooves'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'eighties-ballads-ezbass-midi', 'Eighties Ballads EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'eighties-ballads-ezkeys-midi', 'Eighties Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'eighties-pop-ezbass-midi', 'Eighties Pop EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'eighties-pop-ezkeys-midi', 'Eighties Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'electronic-ezmix-pack', 'Electronic EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'electronic-songwriter-ezmix-pack', 'Electronic Songwriter EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'emotional-ballads-ezkeys-midi', 'Emotional Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'epic-metal-ezkeys-midi', 'Epic Metal EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'epic-themes-2-ezkeys-midi', 'Epic Themes 2 EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'epic-themes-ezkeys-midi', 'Epic Themes EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezbass-bundle', 'EZbass Bundle'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezbass-core-library', 'EZbass Core Library'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezbass-midi-6-pack', 'EZbass MIDI 6 Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezbass-midi-edition', 'EZbass MIDI Edition'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezdrummer-2-core-library-ezx', 'EZdrummer 2 Core Library EZX'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezdrummer-3-bundle', 'EZdrummer 3 Bundle'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezdrummer-3-core-library', 'EZdrummer 3 Core Library'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezdrummer-3-midi-edition', 'EZdrummer 3 MIDI Edition'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezkeys-2-bundle', 'EZkeys 2 Bundle'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezkeys-2-core-library', 'EZkeys 2 Core Library'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezkeys-2-midi-edition', 'EZkeys 2 MIDI Edition'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezkeys-midi-6-pack', 'EZkeys MIDI 6 Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezmix-3-bundle', 'EZmix 3 Bundle'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ezmix-6-pack-bundle', 'EZmix 6 Pack Bundle'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'filters-modulation-ezmix-pack', 'Filters Modulation EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'fm-rock-ezkeys-midi', 'FM Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'folk-ezkeys-midi', 'Folk EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'folk-rock-ezkeys-midi', 'Folk Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'forrester-savell-ezmix-pack', 'Forrester Savell EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'funk-ezkeys-midi', 'Funk EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'funk-riffs-ezkeys-midi', 'Funk Riffs EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'fusion-ezbass-midi', 'Fusion EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'fusion-ezkeys-midi', 'Fusion EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'garage-rock-organ-ezkeys-midi', 'Garage Rock Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'gospel-ezkeys-midi', 'Gospel EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'gospel-hymns-ezkeys-midi', 'Gospel Hymns EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'goth-rock-ezkeys-midi', 'Goth Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'guitar-tone-palette-ezmix-pack', 'Guitar Tone Palette EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'hard-rock-organ-ezkeys-midi', 'Hard Rock Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'heavy-metal-guitars-ezmix-pack', 'Heavy Metal Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'hip-hop-ezkeys-midi', 'Hip Hop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'hip-hop-hooks-ezkeys-midi', 'Hip Hop Hooks EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'hip-hop-rb-ezkeys-midi', 'Hip Hop R&B EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'hooks-chords-ezkeys-midi', 'Hooks Chords EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'hooks-leads-drops-ezkeys-midi', 'Hooks Leads Drops EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'house-ezkeys-midi', 'House EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'indie-guitars-ezmix-pack', 'Indie Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'indie-pop-ezkeys-midi', 'Indie Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'indie-rock-organ-ezkeys-midi', 'Indie Rock Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jamtrack-amps-ezmix-pack', 'Jamtrack Amps EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jazz-ballads-ezkeys-midi', 'Jazz Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jazz-ezbass-midi', 'Jazz EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jazz-ezkeys-midi', 'Jazz EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jazz-fusion-ezkeys-midi', 'Jazz Fusion EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jazz-fusion-guitars-ezmix-pack', 'Jazz Fusion Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'jazz-organ-ezkeys-midi', 'Jazz Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'kaleidoscope-ezmix-pack', 'Kaleidoscope EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'keys-strings-ezkeys-midi', 'Keys Strings EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'laid-back-pop-ezkeys-midi', 'Laid Back Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-ballads-ezbass-midi', 'Latin Ballads EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-ballads-ezkeys-midi', 'Latin Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-cuban-ezkeys-midi', 'Latin Cuban EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-ezkeys-midi', 'Latin EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-jazz-ezbass-midi', 'Latin Jazz EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-jazz-ezkeys-midi', 'Latin Jazz EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'latin-pop-ezkeys-midi', 'Latin Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'lead-guitar-ezmix-pack', 'Lead Guitar EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'lead-vocals-2-ezmix-pack', 'Lead Vocals 2 EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'lead-vocals-ezmix-pack', 'Lead Vocals EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'lo-fi-ezmix-pack', 'Lo-Fi EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'lo-fi-hip-hop-ezkeys-midi', 'Lo-Fi Hip Hop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'mark-lewis-metal-tones-ezmix-pack', 'Mark Lewis Metal Tones EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'mark-needham-ezmix-pack', 'Mark Needham EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'mastering-ezmix-pack', 'Mastering EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'mastering-ii-ezmix-pack', 'Mastering II EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'mastering-iii-ezmix-pack', 'Mastering III EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'melancholic-pop-ezkeys-midi', 'Melancholic Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'melancholic-rock-ezkeys-midi', 'Melancholic Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'melodic-mallets-ezkeys-midi', 'Melodic Mallets EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'melodic-techno-textures-ezkeys-midi', 'Melodic Techno Textures EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-amp-anthology-ezmix-pack', 'Metal Amp Anthology EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-amps-ezmix-pack', 'Metal Amps EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-bass-beasts-ezmix-pack', 'Metal Bass Beasts EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-essentials-ezmix-pack', 'Metal Essentials EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-ezbass-midi', 'Metal EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-ezmix-pack', 'Metal EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-fundamentals-ezmix-pack', 'Metal Fundamentals EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-guitar-gods-2-ezmix-pack', 'Metal Guitar Gods 2 EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-guitar-gods-3-ezmix-pack', 'Metal Guitar Gods 3 EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-guitar-gods-4-ezmix-pack', 'Metal Guitar Gods 4 EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-guitar-gods-ezmix-pack', 'Metal Guitar Gods EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-mix-buses-ezmix-pack', 'Metal Mix Buses EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-riffs-ezbass-midi', 'Metal Riffs EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-songwriter-ezmix-pack', 'Metal Songwriter EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'metal-themes-ezkeys-midi', 'Metal Themes EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'michael-ilbert-ezmix-pack', 'Michael Ilbert EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'mick-guzauski-ezmix-pack', 'Mick Guzauski EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-funk-ezbass-midi', 'Modern Funk EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-funk-ezkeys-midi', 'Modern Funk EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-gospel-ezkeys-midi', 'Modern Gospel EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-metal-guitars-ezmix-pack', 'Modern Metal Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-pop-ezbass-midi', 'Modern Pop EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-pop-ezkeys-midi', 'Modern Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-poprock-ezmix-pack', 'Modern Poprock EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'modern-soul-ezkeys-midi', 'Modern Soul EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-action-ezkeys-midi', 'Movie Scores Action EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-adventure-ezkeys-midi', 'Movie Scores Adventure EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-drama-ezkeys-midi', 'Movie Scores Drama EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-ezkeys-midi', 'Movie Scores EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-fantasy-ezkeys-midi', 'Movie Scores Fantasy EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-horror-ezkeys-midi', 'Movie Scores Horror EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-romance-ezkeys-midi', 'Movie Scores Romance EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-sci-fi-ezkeys-midi', 'Movie Scores Sci-Fi EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'movie-scores-suspense-ezkeys-midi', 'Movie Scores Suspense EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'musicals-ezkeys-midi', 'Musicals EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'neil-dorfsman-ezmix-pack', 'Neil Dorfsman EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'neo-soul-ezkeys-midi', 'Neo Soul EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'new-orleans-ezkeys-midi', 'New Orleans EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'new-wave-ezkeys-midi', 'New Wave EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'peter-henderson-ezmix-pack', 'Peter Henderson EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'piano-pop-ezkeys-midi', 'Piano Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'poprock-ezkeys-midi', 'Poprock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'power-ballads-ezkeys-midi', 'Power Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'prog-rock-organ-ezkeys-midi', 'Prog Rock Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'psychedelic-rock-organ-ezkeys-midi', 'Psychedelic Rock Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'randy-staub-ezmix-pack', 'Randy Staub EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'rb-ezkeys-midi', 'R&B EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'rb-themes-ezkeys-midi', 'R&B Themes EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'reggae-ezbass-midi', 'Reggae EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'reggae-ezkeys-midi', 'Reggae EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'reggae-ezmix-pack', 'Reggae EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'retro-soul-ezkeys-midi', 'Retro Soul EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'rock-ballads-ezkeys-midi', 'Rock Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'rock-ezmix-pack', 'Rock EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'rock-opera-ezkeys-midi', 'Rock Opera EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'rooms-and-verbs-ezmix-pack', 'Rooms And Verbs EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'roots-music-ezkeys-midi-6-pack', 'Roots Music EZkeys MIDI 6 Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'salsa-ezbass-midi', 'Salsa EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'salsa-ezkeys-midi', 'Salsa EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'session-amps-blues-roots-ezmix-pack', 'Session Amps Blues Roots EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'session-amps-funk-fusion-ezmix-pack', 'Session Amps Funk Fusion EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'session-amps-rock-country-ezmix-pack', 'Session Amps Rock Country EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'seventies-pop-ezbass-midi', 'Seventies Pop EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'seventies-pop-ezkeys-midi', 'Seventies Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'seventies-prog-ezkeys-midi', 'Seventies Prog EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'shuffles-ezkeys-midi', 'Shuffles EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'singer-songwriter-ballads-ezkeys-midi', 'Singer Songwriter Ballads EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'singer-songwriter-ezbass-midi', 'Singer Songwriter EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'singer-songwriter-ezkeys-midi', 'Singer Songwriter EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'sixties-pop-ezbass-midi', 'Sixties Pop EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'sixties-pop-ezkeys-midi', 'Sixties Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'ska-reggae-organ-ezkeys-midi', 'Ska Reggae Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'songwriters-tools-ezmix-pack', 'Songwriters Tools EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'songwriting-ezkeys-midi-6-pack', 'Songwriting EZkeys MIDI 6 Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'soul-organ-ezkeys-midi', 'Soul Organ EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'soundscapes-ezmix-pack', 'Soundscapes EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'southern-funk-ezkeys-midi', 'Southern Funk EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'synth-pop-ezkeys-midi', 'Synth Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'synthwave-ezkeys-midi', 'Synthwave EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'the-mix-toolbox-ezmix-pack', 'The Mix Toolbox EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'thordendal-guitars-ezmix-pack', 'Thordendal Guitars EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'traditional-gospel-ezbass-midi', 'Traditional Gospel EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'traditional-gospel-ezkeys-midi', 'Traditional Gospel EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'trip-hop-ezkeys-midi', 'Trip Hop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'tropical-house-ezkeys-midi', 'Tropical House EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'uk-dance-midi', 'UK Dance MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'uk-pop-ezkeys-midi', 'UK Pop EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'uk-pop-ezx', 'UK Pop EZX'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'uk-pop-grooves', 'UK Pop Grooves'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'urban-jazz-ezbass-midi', 'Urban Jazz EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'urban-jazz-ezkeys-midi', 'Urban Jazz EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'vintage-grit-ezmix-pack', 'Vintage Grit EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'vocal-toolbox-ezmix-pack', 'Vocal Toolbox EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'vocals-ezmix-pack', 'Vocals EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'warped-ezmix-pack', 'Warped EZmix Pack'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'west-coast-rock-ezbass-midi', 'West Coast Rock EZbass MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'west-coast-rock-ezkeys-midi', 'West Coast Rock EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('toontrack', 'world-music-ezkeys-midi', 'World Music EZkeys MIDI'), -- official spelling (EZkeys/EZmix/EZbass, roman numerals) | https://www.toontrack.com/product/ballads-ezkeys-midi/
  ('universal-audio', 'luna-studio-uad-native-pro-bundle', 'Luna Studio UAD Native Pro Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-carlos-de-la-garza-mix-tape', 'UAD Carlos De La Garza Mix Tape'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-classic-keys-and-synths-bundle', 'UAD Classic Keys And Synths Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-classic-tone-eq-mix-tape', 'UAD Classic Tone EQ Mix Tape'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-complete-4', 'UAD Complete 4'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-compressor-all-stars-mix-tape', 'UAD Compressor All Stars Mix Tape'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-custom-10-bundle', 'UAD Custom 10 Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-guitar-amp-bundle', 'UAD Guitar Amp Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-guitar-bundle', 'UAD Guitar Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-guitar-mix-tape', 'UAD Guitar Mix Tape'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-hip-hop-mix-tape', 'UAD Hip Hop Mix Tape'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-la-3a', 'UAD La 3a'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-mix-tape-10', 'UAD Mix Tape 10'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-native-classics-bundle', 'UAD Native Classics Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-native-pro-bundle', 'UAD Native Pro Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-native-producer-bundle', 'UAD Native Producer Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-native-studio-bundle', 'UAD Native Studio Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-oto-biscuit-effects-plug-in', 'UAD Oto Biscuit Effects Plug In'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-pro-vocal-bundle', 'UAD Pro Vocal Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-select-10-bundle', 'UAD Select 10 Bundle'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-sound-city-studios-plug-in', 'UAD Sound City Studios Plug In'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-ultimate-14', 'UAD Ultimate 14'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-vocal-mix-tape', 'UAD Vocal Mix Tape'), -- spelling | https://www.uaudio.com
  ('universal-audio', 'uad-will-yip-mix-tape', 'UAD Will Yip Mix Tape') -- spelling | https://www.uaudio.com
) as v(dev, slug, name)
where p.developer_id = d.id and d.slug = v.dev and p.slug = v.slug;


