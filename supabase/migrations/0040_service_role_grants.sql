-- Step 40: let the server (service role key) use the two tables it reads and writes
-- (Victor, 2026-09-25). This Supabase project does not grant table privileges to
-- service_role automatically, and 0037 and 0038 only revoked access from anon and
-- authenticated, so every server call on these tables failed with permission denied
-- (only logged, never shown): sign-in links never brought people back to the page they
-- wanted (0037), and new listings never emailed the alert holders (0038).
-- Any future table the server touches with the service role key needs the same grant.
-- Run once in Supabase > SQL Editor.

grant select, insert, update, delete on public.sign_in_redirects to service_role;
grant select on public.listing_alerts to service_role;
