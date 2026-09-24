import { createClient } from "@supabase/supabase-js";

// Service-role client: bypasses RLS, used only to look up another user's email
// to notify them and to remove a deleted account. Never import this from a client component.
const admin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
);

export async function getUserEmail(userId: string) {
  const { data, error } = await admin.auth.admin.getUserById(userId);
  if (error || !data.user?.email || data.user.email.endsWith(DELETED_EMAIL_DOMAIN)) return null;
  return data.user.email;
}

const DELETED_EMAIL_DOMAIN = "@deleted.pluginresale.com";

// Called after delete_my_account() has anonymised the profile. Deleting the auth user erases
// the email for good; when past deals, messages or reviews still point to the profile, the
// database refuses it, so the email is replaced instead and the account banned from signing in.
export async function removeAuthUser(userId: string) {
  const { error } = await admin.auth.admin.deleteUser(userId);
  if (!error) return;

  const { error: scrubError } = await admin.auth.admin.updateUserById(userId, {
    email: `deleted-${userId}${DELETED_EMAIL_DOMAIN}`,
    email_confirm: true,
    user_metadata: {},
    ban_duration: "876000h",
  });
  if (scrubError) console.error("auth user scrub failed:", scrubError.message);
}

// Page to send the user back to after they open the sign-in link (see migration 0037).
// Kept in the database rather than a cookie because the link often opens in another browser
// (Instagram or Facebook app browser -> mail app -> Safari). Failures are only logged:
// the user then simply lands on My account, as before.
const SIGN_IN_NEXT_TTL_MS = 60 * 60 * 1000;

export async function saveSignInNext(email: string, next: string) {
  const { error } = await admin
    .from("sign_in_redirects")
    .upsert({ email, next, created_at: new Date().toISOString() });
  if (error) console.error("saveSignInNext failed:", error.message);

  await admin
    .from("sign_in_redirects")
    .delete()
    .lt("created_at", new Date(Date.now() - SIGN_IN_NEXT_TTL_MS).toISOString());
}

export async function takeSignInNext(email: string) {
  const { data, error } = await admin
    .from("sign_in_redirects")
    .delete()
    .eq("email", email)
    .select("next, created_at")
    .maybeSingle<{ next: string; created_at: string }>();
  if (error) {
    console.error("takeSignInNext failed:", error.message);
    return null;
  }
  if (!data || Date.now() - new Date(data.created_at).getTime() > SIGN_IN_NEXT_TTL_MS) return null;
  return data.next;
}
