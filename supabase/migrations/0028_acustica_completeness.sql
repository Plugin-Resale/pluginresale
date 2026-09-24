-- Step 28: Acustica Audio catalogue completeness pass (Victor, 2026-09-24).
-- Re-checked against Acustica own store sitemap (sitemap.acustica-audio.com/sitemap.xml,
-- about 220 product URLs) and individual product pages, same technique as the earlier
-- sitemap-sourced passes (0018, 0025). Run once in Supabase > SQL Editor.

-- "Aquamarine5" was the product URL slug, not its real name: the product page title is
-- "Aquamarine 5", matching the "Name N" style already used for Gold 6, Cream 3, Ruby 3 etc
update public.plugins set name = 'Aquamarine 5', slug = 'aquamarine-5'
where slug = 'aquamarine5' and developer_id = (select id from public.developers where slug = 'acustica-audio');

-- 5 real products with their own store page that were missing from the catalogue.
insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('acustica-audio', 'NebulaMan2', 'nebulaman2', 'utilities'),
  ('acustica-audio', 'Squid3 - Electro Edge', 'squid3-electro-edge', 'synths'),
  ('acustica-audio', 'Squid3 - Analog Life 1', 'squid3-analog-life-1', 'synths'),
  ('acustica-audio', 'Blackout for SQUID-3', 'blackout-for-squid-3', 'synths'),
  ('acustica-audio', 'Expanse5 - Zygote', 'expanse5-zygote', 'synths')
) as p(dev_slug, name, slug, category)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do update set category = excluded.category;
