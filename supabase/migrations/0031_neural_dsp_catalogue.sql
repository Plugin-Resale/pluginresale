-- Step 31: complete the Neural DSP catalogue (Victor, 2026-09-24).
-- Checked against neuraldsp.com/sitemap.xml (23 product URLs, the full current lineup) and
-- the plugins storefront page for exact names/prices. 12 products were already listed, these
-- 11 were missing. All guitar/bass amp-and-effects suites, no dedicated bass category in
-- the catalogue so grouped under guitar-amps like the existing Parallax X.
-- Run once in Supabase > SQL Editor.

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('Archetype: John Mayer X', 'archetype-john-mayer-x', 'guitar-amps'),
  ('Darkglass Ultimate', 'darkglass-ultimate', 'guitar-amps'),
  ('Archetype: Misha Mansoor X', 'archetype-misha-mansoor-x', 'guitar-amps'),
  ('Archetype: Rabea X', 'archetype-rabea-x', 'guitar-amps'),
  ('Morgan Amps Suite', 'morgan-amps-suite', 'guitar-amps'),
  ('Archetype: Mateus Asato', 'archetype-mateus-asato', 'guitar-amps'),
  ('Archetype: Tom Morello', 'archetype-tom-morello', 'guitar-amps'),
  ('Mesa Boogie Mark IIC+ Suite', 'mesa-boogie-mark-iic-suite', 'guitar-amps'),
  ('Tone King Imperial MKII', 'tone-king-imperial-mkii', 'guitar-amps'),
  ('Fortin Cali Suite', 'fortin-cali-suite', 'guitar-amps'),
  ('Omega Ampworks Granophyre', 'omega-ampworks-granophyre', 'guitar-amps')
) as p(name, slug, category), public.developers d
where d.slug = 'neural-dsp'
on conflict (developer_id, slug) do update set category = excluded.category;
