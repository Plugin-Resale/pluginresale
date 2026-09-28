-- Toontrack "License Transfer" is the name of the paid transfer service in the Toontrack
-- store, not a product. Removed from the catalogue, only if no listing points at it.
delete from public.plugins p
using public.developers d
where d.id = p.developer_id
  and d.slug = 'toontrack'
  and p.slug = 'license-transfer'
  and not exists (select 1 from public.listings l where l.plugin_id = p.id);
