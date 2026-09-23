-- Step 5b: messages (buyer <-> seller chat about a listing). Run once in Supabase > SQL Editor.

create table public.messages (
  id bigint generated always as identity primary key,
  listing_id bigint not null references public.listings (id),
  from_id uuid not null references public.profiles (id),
  to_id uuid not null references public.profiles (id),
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now(),
  check (from_id <> to_id)
);

create index messages_listing_idx on public.messages (listing_id, created_at);
create index messages_to_id_idx on public.messages (to_id);
create index messages_from_id_idx on public.messages (from_id);

alter table public.messages enable row level security;

create policy "Sender and recipient read their messages" on public.messages
  for select to authenticated
  using ((select auth.uid()) in (from_id, to_id));

revoke all on public.messages from anon, authenticated;
grant select on public.messages to authenticated;

-- Sends a message about a listing: to the seller, or a reply to someone who already
-- messaged the sender about it. Keeps every thread scoped to (listing, seller, one buyer).
create function public.send_message(p_listing_id bigint, p_to_id uuid, p_body text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_seller_id uuid;
  v_id bigint;
  v_body text := trim(p_body);
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;
  if not exists (select 1 from public.profiles where id = auth.uid() and username is not null) then
    raise exception 'USERNAME_REQUIRED';
  end if;
  if p_to_id = auth.uid() then
    raise exception 'NOT_ALLOWED';
  end if;
  if v_body = '' then
    raise exception 'EMPTY_BODY';
  end if;

  select seller_id into v_seller_id from public.listings where id = p_listing_id;
  if not found then
    raise exception 'UNKNOWN_LISTING';
  end if;

  if p_to_id <> v_seller_id
     and not exists (select 1 from public.messages
                      where listing_id = p_listing_id and from_id = p_to_id and to_id = auth.uid()) then
    raise exception 'NOT_ALLOWED';
  end if;

  insert into public.messages (listing_id, from_id, to_id, body)
  values (p_listing_id, auth.uid(), p_to_id, v_body)
  returning id into v_id;

  return v_id;
end;
$$;

revoke execute on function public.send_message from public, anon;
grant execute on function public.send_message to authenticated;
