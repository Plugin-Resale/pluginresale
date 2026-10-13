"use server";

import { revalidatePath } from "next/cache";
import { PROOF_BUCKET, USER_IMAGE_PATH_RE } from "@/lib/images";
import { createClient } from "@/lib/supabase/server";

// The seller adds, replaces or removes the license screenshot of their own listing.
// RLS only lets the seller update it, while the listing is active or removed.
// The file it replaces is deleted.
export async function setListingProof(formData: FormData) {
  const id = Number(formData.get("listing_id"));
  const path = String(formData.get("proof_image_path") ?? "");
  if (!Number.isInteger(id) || id <= 0 || (path && !USER_IMAGE_PATH_RE.test(path))) return;

  const supabase = await createClient();
  const { data: before } = await supabase
    .from("listings")
    .select("proof_image_path")
    .eq("id", id)
    .maybeSingle<{ proof_image_path: string | null }>();

  const { data: updated, error } = await supabase
    .from("listings")
    .update({ proof_image_path: path || null })
    .eq("id", id)
    .select("id");
  if (error || !updated?.length) {
    if (error) console.error("set proof failed:", error.message);
    return;
  }

  const old = before?.proof_image_path;
  if (old && old !== path) {
    const { error: removeError } = await supabase.storage.from(PROOF_BUCKET).remove([old]);
    if (removeError) console.error("old proof removal failed:", removeError.message);
  }
  revalidatePath(`/listings/${id}`);
}

// The seller changes the price of their own listing (same rules as the Sell form).
// RLS only lets the seller update it while the listing is active or removed: a reserved
// listing keeps its price, and a deal keeps the price it was bought at.
export async function setListingPrice(formData: FormData) {
  const id = Number(formData.get("listing_id"));
  const raw = String(formData.get("price") ?? "").trim().replace(",", ".");
  const price = Number(raw);
  if (!Number.isInteger(id) || id <= 0) return;
  if (!/^\d+(\.\d{1,2})?$/.test(raw) || price < 1 || price > 10000) return;

  const supabase = await createClient();
  const { error } = await supabase.from("listings").update({ price_eur: price }).eq("id", id);
  if (error) console.error("set price failed:", error.message);
  revalidatePath("/", "layout");
}
