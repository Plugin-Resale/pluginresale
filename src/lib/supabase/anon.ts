import { createClient as createSupabaseClient, type SupabaseClient } from "@supabase/supabase-js";

// Supabase client for public reads that do not depend on who is looking: catalogue, listings,
// profiles, reviews. It never touches cookies, so a page that only uses it can be rendered once
// and cached (ISR) instead of running as a function on every request. RLS still applies, with
// the anon role. Use `createClient` from ./server for anything that depends on the signed-in user.
// Untyped rows (`any`), like the cookie-based client from ./server: each query names its row type.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
let client: SupabaseClient<any, "public", any> | undefined;

export function createAnonClient() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  client ??= createSupabaseClient<any, "public", any>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false } },
  );
  return client;
}
