"use server";

import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { emailButton, sendEmail } from "@/lib/email";
import { createClient } from "@/lib/supabase/server";
import { getUserEmail } from "@/lib/supabase/admin";
import { getCurrentUser } from "@/lib/supabase/user";

// Posts one message on a listing thread: a buyer to the seller, or the seller's reply.
export async function sendMessage(formData: FormData) {
  const listingId = Number(formData.get("listing_id"));
  const toId = String(formData.get("to_id") ?? "");
  const body = String(formData.get("body") ?? "");
  if (!Number.isInteger(listingId) || !toId) return;

  const { profile } = await getCurrentUser();
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

  const [toEmail, { data: listing }] = await Promise.all([
    getUserEmail(toId),
    supabase.from("listing_cards").select("developer_name, plugin_name").eq("id", listingId).single(),
  ]);
  if (toEmail && listing) {
    const origin = (await headers()).get("origin") ?? "https://www.pluginresale.com";
    const title = `${listing.developer_name} ${listing.plugin_name}`;
    await sendEmail({
      to: toEmail,
      subject: `New message about ${title}`,
      html: `<h2>New message</h2><p>@${profile?.username ?? "Someone"} sent you a message about ${title}.</p>${emailButton(`${origin}/listings/${listingId}/messages`, "Read the message")}`,
    });
  }

  revalidatePath(`/listings/${listingId}/messages`);
  redirect(`/listings/${listingId}/messages?with=${toId}`);
}
