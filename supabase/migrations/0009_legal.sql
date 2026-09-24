-- Step 6: legal. Terms acceptance + self-service account deletion.
-- Run once in Supabase > SQL Editor.

alter table public.profiles
  add column terms_accepted_at timestamptz,
  add column deleted_at timestamptz;

comment on column public.profiles.terms_accepted_at is
  'When the user ticked "I agree to the Terms of Service" (set by accept_terms()).';
comment on column public.profiles.deleted_at is
  'Set by delete_my_account(). The row is kept, anonymised, so past deals and reviews stay consistent.';

-- 1. The user accepts the Terms (called from the username form on My account).
create function public.accept_terms()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;
  update public.profiles set terms_accepted_at = now()
  where id = auth.uid() and terms_accepted_at is null;
end;
$$;

-- 2. A username (required to sell, buy and message) can only be chosen once the Terms
--    are accepted, and "deleted_..." is reserved for deleted accounts.
create function public.check_username_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.username is distinct from old.username and new.deleted_at is null then
    if new.terms_accepted_at is null then
      raise exception 'TERMS_REQUIRED';
    end if;
    if new.username like 'deleted\_%' then
      raise exception 'USERNAME_RESERVED';
    end if;
  end if;
  return new;
end;
$$;

create trigger profiles_check_username_change
  before update on public.profiles
  for each row execute function public.check_username_change();

-- 3. French law (LCEN, Décret n° 2021-1362) makes hosts keep the identification data of a
--    closed account (email, username) for 1 year, for court requests only. No policy and no
--    grant: only the service role (Supabase dashboard) can read it.
create table public.deleted_accounts (
  user_id uuid primary key,
  email text,
  username text,
  deleted_at timestamptz not null default now()
);

alter table public.deleted_accounts enable row level security;
revoke all on public.deleted_accounts from anon, authenticated;

-- 4. The user deletes their account (My account > Delete my account).
--    Their listings go offline, their PayPal emails are erased and the profile is
--    anonymised. The app then deletes (or scrubs and bans) the auth user, which holds the email.
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'NOT_SIGNED_IN';
  end if;
  if exists (select 1 from public.deals
             where v_uid in (buyer_id, seller_id) and status in ('requested', 'paid')) then
    raise exception 'OPEN_DEAL';
  end if;

  -- Archive what the law requires (see 3.), and purge archives older than a year.
  insert into public.deleted_accounts (user_id, email, username)
  select u.id, u.email, p.username
  from auth.users u join public.profiles p on p.id = u.id
  where u.id = v_uid
  on conflict (user_id) do nothing;
  delete from public.deleted_accounts where deleted_at < now() - interval '1 year';

  update public.listings set status = 'removed'
  where seller_id = v_uid and status = 'active';

  delete from public.listing_private
  where listing_id in (select id from public.listings where seller_id = v_uid);

  update public.profiles
  set username = 'deleted_' || substr(md5(id::text), 1, 12), deleted_at = now()
  where id = v_uid;
end;
$$;

revoke execute on function public.accept_terms, public.delete_my_account from public, anon;
grant execute on function public.accept_terms, public.delete_my_account to authenticated;
