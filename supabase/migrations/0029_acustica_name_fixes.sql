-- Step 29: more Acustica Audio name fixes (Victor spotted Ultramarine missing, 2026-09-24).
-- Same root cause as Aquamarine5 in 0028: their store URL slug drops the space before the
-- version number, but the real product name (the page heading) has one. Checked one by one
-- against each product page. Also removed TH2, a free product (same policy as elsewhere:
-- free plugins are not listed). Run once in Supabase > SQL Editor, after 0028.

update public.plugins set name = 'Ultramarine 4', slug = 'ultramarine-4'
where slug = 'ultramarine4' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Pink 4', slug = 'pink-4'
where slug = 'pink4' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Jade 2', slug = 'jade-2'
where slug = 'jade2' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Cola 2', slug = 'cola-2'
where slug = 'cola2' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Honey 3', slug = 'honey-3'
where slug = 'honey3' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Copper 2', slug = 'copper-2'
where slug = 'copper2' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Mantis 2', slug = 'mantis-2'
where slug = 'mantis2' and developer_id = (select id from public.developers where slug = 'acustica-audio');
update public.plugins set name = 'Bronze 2', slug = 'bronze-2'
where slug = 'bronze2' and developer_id = (select id from public.developers where slug = 'acustica-audio');

-- Alice9 real name has a hyphen, not glued: "Alice-9".
update public.plugins set name = 'Alice-9', slug = 'alice-9'
where slug = 'alice9' and developer_id = (select id from public.developers where slug = 'acustica-audio');

-- TH2 is a free entry-level synth (no license to resell). Kept if a seller already listed it.
delete from public.plugins p
using public.developers d
where p.developer_id = d.id and d.slug = 'acustica-audio' and p.slug = 'th2'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
