-- Step 37: send people back to what they were doing after they click the sign-in link
-- (Victor, 2026-09-24). Most visitors come from Instagram and Facebook on a phone: they ask
-- for the link inside the app browser, then open the email in their mail app, so the link
-- opens in Safari or Chrome, where a cookie set in the app browser does not exist.
-- The page they wanted (for example /sell) is therefore kept here, keyed by email, when the
-- link is requested, and read back by the server when the link is opened.
-- Rows are deleted as soon as they are used and are ignored after one hour.
-- No RLS policy on purpose: only the server, with the service role key, reads or writes it.
-- Run once in Supabase > SQL Editor.

create table public.sign_in_redirects (
  email text primary key,
  next text not null check (next ~ '^/[^/]'),
  created_at timestamptz not null default now()
);

alter table public.sign_in_redirects enable row level security;

revoke all on public.sign_in_redirects from anon, authenticated;
