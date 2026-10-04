"use server";

import { cookies, headers } from "next/headers";
import { redirect } from "next/navigation";
import { OAUTH_NEXT_COOKIE, safeNext } from "@/lib/next-path";
import { saveSignInNext } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

export type SignInState = {
  status: "idle" | "sent" | "error";
  message?: string;
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export async function sendMagicLink(
  _prev: SignInState,
  formData: FormData,
): Promise<SignInState> {
  const email = String(formData.get("email") ?? "")
    .trim()
    .toLowerCase();
  if (!EMAIL_RE.test(email)) {
    return { status: "error", message: "Please enter a valid email address." };
  }

  // The email link comes back to the site the user is on (localhost, preview or production).
  const origin =
    (await headers()).get("origin") ?? "https://www.pluginresale.com";

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: { emailRedirectTo: `${origin}/auth/confirm` },
  });

  if (error) {
    console.error("signInWithOtp failed:", error.message);
    return {
      status: "error",
      message:
        error.status === 429
          ? "Too many attempts. Please wait a few minutes and try again."
          : "We couldn't send the email. Please try again.",
    };
  }

  const next = safeNext(formData.get("next"));
  if (next) await saveSignInNext(email, next);

  return { status: "sent", message: email };
}

// "Continue with Google": Supabase sends the user to Google, then back to /auth/confirm with
// a `?code=` (same browser, so the page to return to can simply wait in a cookie).
export async function signInWithGoogle(formData: FormData) {
  const origin =
    (await headers()).get("origin") ?? "https://www.pluginresale.com";

  const next = safeNext(formData.get("next"));
  const cookieStore = await cookies();
  if (next) {
    cookieStore.set(OAUTH_NEXT_COOKIE, next, {
      httpOnly: true,
      sameSite: "lax",
      secure: true,
      maxAge: 600,
      path: "/",
    });
  } else {
    cookieStore.delete(OAUTH_NEXT_COOKIE);
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: { redirectTo: `${origin}/auth/confirm` },
  });

  if (error || !data.url) {
    console.error("signInWithOAuth failed:", error?.message ?? "no url");
    redirect(
      next
        ? `/signin?error=google&next=${encodeURIComponent(next)}`
        : "/signin?error=google",
    );
  }
  redirect(data.url);
}
