"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { removeAuthUser } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

export type UsernameState = { status: "idle" | "saved" | "error"; message?: string };

const USERNAME_RE = /^[a-z0-9_]{3,20}$/;

// Only redirect back to a path within this site, never to an attacker-supplied URL.
function safeNext(next: FormDataEntryValue | null): string | null {
  const value = String(next ?? "");
  return value.startsWith("/") && !value.startsWith("//") ? value : null;
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

  await supabase.auth.signOut();
  await removeAuthUser(user.id);

  revalidatePath("/", "layout");
  redirect("/signin?deleted=1");
}
