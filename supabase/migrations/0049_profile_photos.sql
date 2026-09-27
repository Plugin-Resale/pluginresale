-- Step 49: optional profile photo (Victor, 2026-09-27), shown on the seller card of each
-- listing and on the public profile, instead of the first letter of the username.
-- Same storage pattern as the license proof screenshots (0048).
-- Run once in Supabase > SQL Editor, before deploying the matching code.

-- 1. Path of the photo in the avatars bucket, always inside the user own folder.
alter table public.profiles add column avatar_path text;
alter table public.profiles add constraint profiles_avatar_in_own_folder check (
  avatar_path is null
  or avatar_path ~ ('^' || id::text || '/[0-9a-f-]{36}\.jpg$')
);
grant update (avatar_path) on public.profiles to authenticated;

-- 2. Public bucket, small JPEG files only (the browser resizes the photo before upload).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 2097152, array['image/jpeg']);

create policy "Users upload their photo into their own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars'
              and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Users list their own photo files" on storage.objects
  for select to authenticated
  using (bucket_id = 'avatars'
         and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Users delete their own photo files" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars'
         and (storage.foldername(name))[1] = (select auth.uid()::text));

-- 3. Listing cards carry the seller photo. New column last, a view cannot reorder its columns.
create or replace view public.listing_cards with (security_invoker = true) as
select
  l.id, l.status, l.price_eur, l.version, l.formats, l.description, l.created_at,
  l.seller_id, pr.username as seller_username, pr.created_at as seller_since,
  p.id as plugin_id, p.name as plugin_name, p.category,
  d.id as developer_id, d.name as developer_name, d.slug as developer_slug,
  d.transferable, d.no_fee,
  ss.avg_rating as seller_avg_rating, ss.review_count as seller_review_count,
  p.image_path as plugin_image_path, l.proof_image_path,
  pr.avatar_path as seller_avatar_path
from public.listings l
join public.plugins p on p.id = l.plugin_id
join public.developers d on d.id = p.developer_id
join public.profiles pr on pr.id = l.seller_id
left join public.seller_stats ss on ss.seller_id = l.seller_id;

grant select on public.listing_cards to anon, authenticated;
