-- Step 30: add Neural DSP Mantra (Victor, 2026-09-24). Just this one plugin for now.
-- Checked against neuraldsp.com/plugins/mantra: an all-in-one vocal production plugin
-- (tune, gate, EQ, de-esser, compressor, saturation, harmonies, delay, reverb, modulation),
-- categorised utilities like the catalogue other all-in-one vocal suites (Nectar, CLA
-- Vocals, Topline Vocal Suite...). Neural DSP own transfer policy is still unverified
-- (transferable = null already set on its developer row), so this listing is allowed with
-- the orange "check with the developer" warning like the rest of Neural DSP catalogue.
-- Run once in Supabase > SQL Editor.

insert into public.plugins (developer_id, name, slug, category)
select d.id, 'Mantra', 'mantra', 'utilities'
from public.developers d
where d.slug = 'neural-dsp'
on conflict (developer_id, slug) do update set category = excluded.category;
