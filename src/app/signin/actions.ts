"use server";

import { headers } from "next/headers";
import { createClient } from "@/lib/supabase/server";

export type SignInState = { status: "idle" | "sent" | "error"; message?: string };

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export async function sendMagicLink(_prev: SignInState, formData: FormData): Promise<SignInState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  if (!EMAIL_RE.test(email)) {
    return { status: "error", message: "Please enter a valid email address." };
  }

  // The email link comes back to the site the user is on (localhost, preview or production).
  const origin = (await headers()).get("origin") ?? "https://www.pluginresale.com";

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

  return { status: "sent", message: email };
}
