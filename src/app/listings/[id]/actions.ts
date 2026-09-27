"use server";

import { revalidatePath } from "next/cache";
import { PROOF_BUCKET, PROOF_PATH_RE } from "@/lib/images";
import { createClient } from "@/lib/supabase/server";

// The seller adds, replaces or removes the license screenshot of their own listing.
// RLS only lets the seller update it, while the listing is active or removed.
// The file it replaces is deleted.
export async function setListingProof(formData: FormData) {
  const id = Number(formData.get("listing_id"));
  const path = String(formData.get("proof_image_path") ?? "");
  if (!Number.isInteger(id) || id <= 0 || (path && !PROOF_PATH_RE.test(path))) return;

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
