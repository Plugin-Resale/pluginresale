import type { EmailOtpType, User } from "@supabase/supabase-js";
import { NextResponse, type NextRequest } from "next/server";
import { safeNext } from "@/lib/next-path";
import { takeSignInNext } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

// Target of the magic link email: verifies it and opens a session.
// Two formats are supported:
// - `?code=…` from Supabase's default email template (PKCE: must be opened in the same browser).
// - `?token_hash=…&type=email` from our custom template (works on any device, needs custom SMTP).
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get("code");
  const tokenHash = searchParams.get("token_hash");
  const type = searchParams.get("type") as EmailOtpType | null;

  const supabase = await createClient();
  let error: { message: string } | null = null;
  let user: User | null = null;

  if (tokenHash && type) {
    ({ error, data: { user } } = await supabase.auth.verifyOtp({ type, token_hash: tokenHash }));
  } else if (code) {
    ({ error, data: { user } } = await supabase.auth.exchangeCodeForSession(code));
  } else {
    error = { message: searchParams.get("error_description") ?? "missing code" };
  }

  if (error || !user) {
    console.error("magic link confirmation failed:", error?.message ?? "no user");
    return NextResponse.redirect(new URL("/signin?error=link", request.url));
  }

  // Back to what the user was doing before signing in (Sell, Buy, Message...), saved when
  // they asked for the link. New users set up their account first, then continue there.
  const next = user.email ? safeNext(await takeSignInNext(user.email)) : null;
  if (!next) return NextResponse.redirect(new URL("/account", request.url));

  const { data: profile } = await supabase
    .from("profiles")
    .select("username, terms_accepted_at")
    .eq("id", user.id)
    .maybeSingle<{ username: string | null; terms_accepted_at: string | null }>();
  const ready = Boolean(profile?.username && profile.terms_accepted_at);

  return NextResponse.redirect(
    new URL(ready ? next : `/account?next=${encodeURIComponent(next)}`, request.url),
  );
}
