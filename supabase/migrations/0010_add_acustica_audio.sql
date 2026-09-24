-- Step 10: add Acustica Audio (developer + plugins).
-- Rules checked against Acustica's official transfer-policy help article on 2026-09-24.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified)
values
('Acustica Audio', 'acustica-audio', 'https://www.acustica-audio.com', true,
 'Free for the first 5 transfers per product; €25 + the difference to the current retail price after that',
 'Seller (starts the transfer)',
 'The seller de-authorizes and uninstalls the product, then starts the transfer in Acustica''s Aquarius web service (fully automated, no helpdesk needed). The buyer needs an Acustica Audio account to receive it.',
 'Immediate (automated via Aquarius)',
 'Products must be registered for at least 180 days before they can be transferred. Time-limited, educational, NFR, OEM, institutional and bundled licenses can''t be transferred. Each product includes 5 free transfers total; transferred products can''t be returned.',
 'https://acusticaudio.freshdesk.com/support/solutions/articles/35000055832-acustica-audio-products-transfer-policies-terms-and-conditions',
 '2026-09-24');

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name,
       trim(both '-' from lower(regexp_replace(p.name, '[^a-zA-Z0-9]+', '-', 'g'))),
       p.category
from (values
  ('acustica-audio', 'Gold 6', 'eq'),
  ('acustica-audio', 'Cream 3', 'eq'),
  ('acustica-audio', 'Diamond Color EQ 4', 'eq'),
  ('acustica-audio', 'Ruby 3', 'eq'),
  ('acustica-audio', 'Rust 2', 'eq'),
  ('acustica-audio', 'Grey Pro 2', 'compression'),
  ('acustica-audio', 'Ash 2', 'saturation')
) as p(dev_slug, name, category)
join public.developers d on d.slug = p.dev_slug;
