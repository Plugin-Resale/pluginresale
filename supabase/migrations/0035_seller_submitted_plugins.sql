-- Step 35: sellers can add a plugin themselves when it is not in the catalogue yet
-- (Victor, 2026-09-24: instead of pre-guessing every developer full back-catalogue,
-- let real listings grow it). The developer itself still has to be picked from the
-- existing list, since that is where the whole transfer-rules policy lives - only the
-- plugin name/category becomes free-entry as a fallback.
-- Run once in Supabase > SQL Editor.

alter table public.plugins add column created_by uuid references public.profiles (id) on delete set null;

comment on column public.plugins.created_by is
  'Set when a seller added this plugin themselves via the Sell form because it was missing from the catalogue. Null = part of the curated catalogue import.';

create policy "Sellers add a missing plugin to the catalogue"
  on public.plugins for insert
  to authenticated
  with check (created_by = (select auth.uid()));

grant insert (developer_id, name, slug, category, created_by) on public.plugins to authenticated;

-- create_listing now accepts either an existing p_plugin_id, or a new plugin to create
-- on the fly under an existing developer (p_developer_id + name + category).
create or replace function public.create_listing(
  p_plugin_id bigint,
  p_version text,
  p_price_eur numeric,
  p_description text,
  p_formats text[],
  p_paypal_email text,
  p_new_plugin_name text default null,
  p_new_plugin_category text default null,
  p_developer_id bigint default null
)
returns bigint
language plpgsql
set search_path = ''
as $$
declare
  v_id bigint;
  v_plugin_id bigint;
  v_transferable boolean;
  v_paypal_email text;
  v_slug text;
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;

  if not exists (select 1 from public.profiles where id = auth.uid() and username is not null) then
    raise exception 'USERNAME_REQUIRED';
  end if;

  if p_plugin_id is not null then
    select d.transferable into v_transferable
    from public.plugins p
    join public.developers d on d.id = p.developer_id
    where p.id = p_plugin_id;

    if not found then
      raise exception 'UNKNOWN_PLUGIN';
    end if;

    v_plugin_id := p_plugin_id;
  else
    if p_developer_id is null or nullif(trim(p_new_plugin_name), '') is null
       or p_new_plugin_category is null then
      raise exception 'UNKNOWN_PLUGIN';
    end if;

    select d.transferable into v_transferable
    from public.developers d
    where d.id = p_developer_id;

    if not found then
      raise exception 'UNKNOWN_PLUGIN';
    end if;

    v_slug := trim(both '-' from lower(regexp_replace(p_new_plugin_name, '[^a-zA-Z0-9]+', '-', 'g')));

    -- Reuse the row if someone already added the exact same plugin (avoids needing an
    -- update grant/policy just for an upsert no-op).
    select id into v_plugin_id from public.plugins
    where developer_id = p_developer_id and slug = v_slug;

    if not found then
      insert into public.plugins (developer_id, name, slug, category, created_by)
      values (p_developer_id, trim(p_new_plugin_name), v_slug, p_new_plugin_category, auth.uid())
      returning id into v_plugin_id;
    end if;
  end if;

  if not v_transferable then
    raise exception 'NOT_TRANSFERABLE';
  end if;

  v_paypal_email := lower(trim(p_paypal_email));

  insert into public.listings (seller_id, plugin_id, version, price_eur, description, formats)
  values (auth.uid(), v_plugin_id, nullif(trim(p_version), ''), p_price_eur,
          coalesce(trim(p_description), ''), coalesce(p_formats, '{}'))
  returning id into v_id;

  insert into public.listing_private (listing_id, paypal_email)
  values (v_id, v_paypal_email);

  insert into public.profile_private (user_id, paypal_email)
  values (auth.uid(), v_paypal_email)
  on conflict (user_id) do update set paypal_email = excluded.paypal_email;

  return v_id;
end;
$$;
