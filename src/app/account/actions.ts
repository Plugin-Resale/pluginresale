"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { AVATAR_BUCKET, PROOF_BUCKET, USER_IMAGE_PATH_RE } from "@/lib/images";
import { safeNext } from "@/lib/next-path";
import { removeAuthUser } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

export type UsernameState = { status: "idle" | "saved" | "error"; message?: string };

const USERNAME_RE = /^[a-z0-9_]{3,20}$/;


// Sets or removes (empty path) the signed-in user's profile photo, already uploaded by the
// browser into their own folder of the avatars bucket. The photo it replaces is deleted.
export async function setAvatar(path: string): Promise<{ error?: string }> {
  if (path && !USER_IMAGE_PATH_RE.test(path)) return { error: "Unexpected photo." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Your session has expired. Please sign in again." };

  const { data: before } = await supabase
    .from("profiles")
    .select("avatar_path")
    .eq("id", user.id)
    .single<{ avatar_path: string | null }>();

  const { error } = await supabase
    .from("profiles")
    .update({ avatar_path: path || null })
    .eq("id", user.id);
  if (error) {
    console.error("set avatar failed:", error.message);
    return { error: "Something went wrong. Please try again." };
  }

  const old = before?.avatar_path;
  if (old && old !== path) {
    const { error: removeError } = await supabase.storage.from(AVATAR_BUCKET).remove([old]);
    if (removeError) console.error("old avatar removal failed:", removeError.message);
  }
  revalidatePath("/", "layout");
  return {};
}

export async function saveUsername(
  _prev: UsernameState,
  formData: FormData,
): Promise<UsernameState> {
  const username = String(formData.get("username") ?? "").trim().toLowerCase();
  const next = safeNext(formData.get("next"));
  if (!USERNAME_RE.test(username)) {
    return {
      status: "error",
      message: "3 to 20 characters: lowercase letters, numbers and underscores only.",
    };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { status: "error", message: "Your session has expired. Please sign in again." };

  if (formData.get("accept_terms") === "on") {
    const { error } = await supabase.rpc("accept_terms");
    if (error) {
      console.error("accept_terms failed:", error.message);
      return { status: "error", message: "Something went wrong. Please try again." };
    }
  }

  const { error } = await supabase.from("profiles").update({ username }).eq("id", user.id);

  if (error) {
    if (error.code === "23505") {
      return { status: "error", message: "This username is already taken." };
    }
    if (error.message === "TERMS_REQUIRED") {
      return { status: "error", message: "Please accept the Terms of Service to continue." };
    }
    if (error.message === "USERNAME_RESERVED") {
      return { status: "error", message: "This username isn't available." };
    }
    console.error("profile update failed:", error.message);
    return { status: "error", message: "Something went wrong. Please try again." };
  }

  revalidatePath("/", "layout");
  if (next) redirect(next);
  return { status: "saved", message: username };
}

// Seller removes a listing or puts it back online (RLS only allows active <-> removed).
export async function setListingStatus(formData: FormData) {
  const id = Number(formData.get("id"));
  const status = String(formData.get("status"));
  if (!Number.isInteger(id) || !["active", "removed"].includes(status)) return;

  const supabase = await createClient();
  const { error } = await supabase.from("listings").update({ status }).eq("id", id);
  if (error) console.error("listing status update failed:", error.message);

  revalidatePath("/", "layout");
}

// Removes one of the user's listing alerts (RLS: only their own).
export async function deleteAlert(formData: FormData) {
  const id = Number(formData.get("id"));
  if (!Number.isInteger(id)) return;

  const supabase = await createClient();
  const { error } = await supabase.from("listing_alerts").delete().eq("id", id);
  if (error) console.error("listing alert delete failed:", error.message);

  revalidatePath("/account");
}

export type DeleteAccountState = { error?: string };

// GDPR erasure, self-service. The profile stays (anonymised) so the other side's deals and
// reviews still make sense; everything that identifies the user is removed.
export async function deleteAccount(
  _prev: DeleteAccountState,
  formData: FormData,
): Promise<DeleteAccountState> {
  if (String(formData.get("confirm") ?? "").trim().toUpperCase() !== "DELETE") {
    return { error: "Type DELETE to confirm." };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Your session has expired. Please sign in again." };

  const { error } = await supabase.rpc("delete_my_account");
  if (error) {
    if (error.message === "OPEN_DEAL") {
      return {
        error:
          "You have a purchase or a sale in progress. Complete or cancel it first, then delete your account.",
      };
    }
    console.error("delete_my_account failed:", error.message);
    return { error: "Something went wrong. Please try again." };
  }

  // Alerts are not needed by anyone else: drop them rather than keep them on the anonymised profile.
  const { error: alertsError } = await supabase.from("listing_alerts").delete().eq("user_id", user.id);
  if (alertsError) console.error("listing alerts cleanup failed:", alertsError.message);

  // License screenshots and the profile photo are public files: they go with the account
  // (migrations 0048 and 0049).
  const { error: proofsDbError } = await supabase.rpc("clear_my_proofs");
  if (proofsDbError) console.error("proof paths cleanup failed:", proofsDbError.message);
  const { error: avatarDbError } = await supabase
    .from("profiles")
    .update({ avatar_path: null })
    .eq("id", user.id);
  if (avatarDbError) console.error("avatar path cleanup failed:", avatarDbError.message);
  for (const bucket of [PROOF_BUCKET, AVATAR_BUCKET]) {
    const { data: files } = await supabase.storage.from(bucket).list(user.id, { limit: 1000 });
    if (!files?.length) continue;
    const { error: removeError } = await supabase.storage
      .from(bucket)
      .remove(files.map((f) => `${user.id}/${f.name}`));
    if (removeError) console.error(`${bucket} cleanup failed:`, removeError.message);
  }

  await supabase.auth.signOut();
  await removeAuthUser(user.id);

  revalidatePath("/", "layout");
  redirect("/signin?deleted=1");
}
