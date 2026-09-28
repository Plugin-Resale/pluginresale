-- Official shop pages for the Buy new affiliate link (Thomann first, else Plugin Boutique).
-- Clean product URL only, the affiliate parameters are added by the site when it renders the
-- link (src/lib/affiliate.ts). Filled by us with supabase/scripts/set-plugin-shop-link.mjs.
alter table public.plugins
  add column thomann_url text
    check (thomann_url ~ '^https://www\.thomann\.[a-z.]+/[^?#]+$'),
  add column pluginboutique_url text
    check (pluginboutique_url ~ '^https://www\.pluginboutique\.com/product/[^?#]+$');

grant update (thomann_url, pluginboutique_url) on public.plugins to service_role;

-- The script shows the developer name next to the plugin, as the service role.
grant select on public.developers to service_role;
