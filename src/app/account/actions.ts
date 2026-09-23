"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type UsernameState = { status: "idle" | "saved" | "error"; message?: string };

const USERNAME_RE = /^[a-z0-9_]{3,20}$/;

export async function saveUsername(
  _prev: UsernameState,
  formData: FormData,
): Promise<UsernameState> {
  const username = String(formData.get("username") ?? "").trim().toLowerCase();
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

  const { error } = await supabase.from("profiles").update({ username }).eq("id", user.id);

  if (error) {
    if (error.code === "23505") {
      return { status: "error", message: "This username is already taken." };
    }
    console.error("profile update failed:", error.message);
    return { status: "error", message: "Something went wrong. Please try again." };
  }

  revalidatePath("/", "layout");
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
