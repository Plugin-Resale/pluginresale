-- Step 32: FabFilter Pro-Q 3 and Pro-C 2 are separate products again (Victor, 2026-09-24).
-- 0024 had merged them into Pro-Q 4 / Pro-C 3 under the catalogue rule "old version, the
-- exact version a seller owns goes in the listing free-text field" -- correct for a
-- developer whose major-version upgrade is free, wrong here: FabFilter own FAQ says a
-- major version upgrade is never included in the original license and must be bought
-- separately ("a new major version is a brand new plug-in"), so Pro-Q 3 and Pro-Q 4 (same
-- for Pro-C 2 / Pro-C 3) are two different licenses with two different resale values, not
-- one product at different version numbers. Checked against fabfilter.com/support/faq.
-- Run once in Supabase > SQL Editor.

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('Pro-Q 3', 'pro-q-3', 'eq'),
  ('Pro-C 2', 'pro-c-2', 'compression')
) as p(name, slug, category), public.developers d
where d.slug = 'fabfilter'
on conflict (developer_id, slug) do update set category = excluded.category;
