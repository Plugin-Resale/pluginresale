import type { EmailOtpType } from "@supabase/supabase-js";
import { NextResponse, type NextRequest } from "next/server";
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

  if (tokenHash && type) {
    ({ error } = await supabase.auth.verifyOtp({ type, token_hash: tokenHash }));
  } else if (code) {
    ({ error } = await supabase.auth.exchangeCodeForSession(code));
  } else {
    error = { message: searchParams.get("error_description") ?? "missing code" };
  }

  if (!error) {
    return NextResponse.redirect(new URL("/account", request.url));
  }

  console.error("magic link confirmation failed:", error.message);
  return NextResponse.redirect(new URL("/signin?error=link", request.url));
}
