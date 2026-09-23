"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

// Posts one message on a listing thread: a buyer to the seller, or the seller's reply.
export async function sendMessage(formData: FormData) {
  const listingId = Number(formData.get("listing_id"));
  const toId = String(formData.get("to_id") ?? "");
  const body = String(formData.get("body") ?? "");
  if (!Number.isInteger(listingId) || !toId) return;

  const supabase = await createClient();
  const { error } = await supabase.rpc("send_message", {
    p_listing_id: listingId,
    p_to_id: toId,
    p_body: body,
  });
  if (error) {
    console.error("send_message failed:", error.message);
    redirect(`/listings/${listingId}/messages?with=${toId}&error=1`);
  }

  revalidatePath(`/listings/${listingId}/messages`);
  redirect(`/listings/${listingId}/messages?with=${toId}`);
}
