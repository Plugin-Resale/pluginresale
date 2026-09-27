-- Step 48: official plugin visuals and optional license proof screenshots on listings
-- (Victor, 2026-09-27). Design in docs/superpowers/specs/2026-09-27-listing-images-design.md
-- Run once in Supabase > SQL Editor, before deploying the matching code.

-- 1. Official visual of a catalogue plugin, as a path in the plugin-images bucket.
--    Null means the generic visual. Only set by us (SQL Editor or supabase/scripts/set-plugin-image.mjs).
alter table public.plugins add column image_path text;
grant select on public.plugins to service_role;
grant update (image_path) on public.plugins to service_role;

-- 2. Optional screenshot of the seller account or iLok page, as a path in listing-proofs.
--    The path has to sit in the seller own folder, so nobody can show someone else file.
alter table public.listings add column proof_image_path text;
alter table public.listings add constraint listings_proof_in_seller_folder check (
  proof_image_path is null
  or proof_image_path ~ ('^' || seller_id::text || '/[0-9a-f-]{36}\.jpg$')
);
grant insert (proof_image_path), update (proof_image_path) on public.listings to authenticated;

-- 3. Storage buckets, both publicly readable.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('plugin-images', 'plugin-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('listing-proofs', 'listing-proofs', true, 5242880, array['image/jpeg']);

create policy "Sellers upload proofs into their own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'listing-proofs'
              and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Sellers list their own proof files" on storage.objects
  for select to authenticated
  using (bucket_id = 'listing-proofs'
         and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Sellers delete their own proof files" on storage.objects
  for delete to authenticated
  using (bucket_id = 'listing-proofs'
         and (storage.foldername(name))[1] = (select auth.uid()::text));

-- 4. create_listing takes the optional proof path. Both older versions are dropped first
--    (0035 added parameters without dropping the 0027 one, which left two overloads).
drop function if exists public.create_listing(bigint, text, numeric, text, text[], text);
drop function if exists public.create_listing(bigint, text, numeric, text, text[], text, text, text, bigint);

create function public.create_listing(
  p_plugin_id bigint,
  p_version text,
  p_price_eur numeric,
  p_description text,
  p_formats text[],
  p_paypal_email text,
  p_new_plugin_name text default null,
  p_new_plugin_category text default null,
  p_developer_id bigint default null,
  p_proof_image_path text default null
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

  if p_proof_image_path is not null
     and p_proof_image_path !~ ('^' || auth.uid()::text || '/[0-9a-f-]{36}\.jpg$') then
    raise exception 'BAD_PROOF';
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

  insert into public.listings (seller_id, plugin_id, version, price_eur, description, formats,
                               proof_image_path)
  values (auth.uid(), v_plugin_id, nullif(trim(p_version), ''), p_price_eur,
          coalesce(trim(p_description), ''), coalesce(p_formats, '{}'), p_proof_image_path)
  returning id into v_id;

  insert into public.listing_private (listing_id, paypal_email)
  values (v_id, v_paypal_email);

  insert into public.profile_private (user_id, paypal_email)
  values (auth.uid(), v_paypal_email)
  on conflict (user_id) do update set paypal_email = excluded.paypal_email;

  return v_id;
end;
$$;

revoke execute on function public.create_listing from public, anon;
grant execute on function public.create_listing to authenticated;

-- 5. Account deletion clears the proof paths on all the user listings, sold ones included
--    (the app deletes the files themselves right after).
create function public.clear_my_proofs()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.listings set proof_image_path = null where seller_id = auth.uid();
$$;

revoke execute on function public.clear_my_proofs from public, anon;
grant execute on function public.clear_my_proofs to authenticated;

-- 6. Listing cards carry both images. New columns go last, a view cannot reorder its columns.
create or replace view public.listing_cards with (security_invoker = true) as
select
  l.id, l.status, l.price_eur, l.version, l.formats, l.description, l.created_at,
  l.seller_id, pr.username as seller_username, pr.created_at as seller_since,
  p.id as plugin_id, p.name as plugin_name, p.category,
  d.id as developer_id, d.name as developer_name, d.slug as developer_slug,
  d.transferable, d.no_fee,
  ss.avg_rating as seller_avg_rating, ss.review_count as seller_review_count,
  p.image_path as plugin_image_path, l.proof_image_path
from public.listings l
join public.plugins p on p.id = l.plugin_id
join public.developers d on d.id = p.developer_id
join public.profiles pr on pr.id = l.seller_id
left join public.seller_stats ss on ss.seller_id = l.seller_id;

grant select on public.listing_cards to anon, authenticated;
