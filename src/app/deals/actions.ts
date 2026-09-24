"use server";

import { signInUrl } from "@/lib/next-path";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { emailButton, sendEmail } from "@/lib/email";
import { createClient } from "@/lib/supabase/server";
import { getUserEmail } from "@/lib/supabase/admin";

const START_ERRORS: Record<string, string> = {
  NOT_SIGNED_IN: "signin",
  USERNAME_REQUIRED: "username",
  NOT_AVAILABLE: "unavailable",
  OWN_LISTING: "own",
};

// Notifies one side of a deal by email, using the listing title in the subject/body.
// Best-effort: a Supabase/Resend hiccup here never breaks the deal flow itself.
async function notifyDeal(
  supabase: Awaited<ReturnType<typeof createClient>>,
  dealId: number,
  listingId: number,
  notifyUserId: string,
  subject: string,
  body: string,
) {
  const [email, { data: listing }] = await Promise.all([
    getUserEmail(notifyUserId),
    supabase.from("listing_cards").select("developer_name, plugin_name").eq("id", listingId).single(),
  ]);
  if (!email || !listing) return;

  const origin = (await headers()).get("origin") ?? "https://www.pluginresale.com";
  const title = `${listing.developer_name} ${listing.plugin_name}`;
  await sendEmail({
    to: email,
    subject: `${subject}: ${title}`,
    html: `<h2>${subject}</h2><p>${body}</p>${emailButton(`${origin}/deals/${dealId}`, "View the purchase")}`,
  });
}

// "Buy with PayPal": reserves the listing and opens the deal page.
export async function startDeal(formData: FormData) {
  const listingId = Number(formData.get("listing_id"));
  if (!Number.isInteger(listingId)) return;

  const supabase = await createClient();
  const { data: dealId, error } = await supabase.rpc("start_deal", { p_listing_id: listingId });

  if (error) {
    const code = START_ERRORS[error.message];
    if (code === "signin") redirect(signInUrl(`/listings/${listingId}`));
    if (!code) console.error("start_deal failed:", error.message);
    redirect(`/listings/${listingId}?error=${code ?? "unknown"}`);
  }

  const { data: deal } = await supabase.from("deals").select("seller_id").eq("id", dealId).single();
  if (deal) {
    await notifyDeal(
      supabase,
      dealId,
      listingId,
      deal.seller_id,
      "You have a buyer",
      "Someone wants to buy your listing. Open the purchase to see your PayPal details and the next step.",
    );
  }

  revalidatePath("/", "layout");
  redirect(`/deals/${dealId}`);
}

const STEP_FUNCTIONS = {
  paid: "mark_deal_paid",
  completed: "mark_deal_completed",
  cancel: "cancel_deal",
} as const;

// Seller: payment received. Buyer: license received. Either: cancel (before payment).
export async function advanceDeal(formData: FormData) {
  const dealId = Number(formData.get("deal_id"));
  const step = String(formData.get("step")) as keyof typeof STEP_FUNCTIONS;
  if (!Number.isInteger(dealId) || !(step in STEP_FUNCTIONS)) return;

  const supabase = await createClient();
  const { error } = await supabase.rpc(STEP_FUNCTIONS[step], { p_deal_id: dealId });
  if (error) {
    console.error(`${STEP_FUNCTIONS[step]} failed:`, error.message);
    redirect(`/deals/${dealId}?error=1`);
  }

  if (step === "paid" || step === "completed") {
    const { data: deal } = await supabase
      .from("deals")
      .select("listing_id, buyer_id, seller_id")
      .eq("id", dealId)
      .single();
    if (deal) {
      if (step === "paid") {
        await notifyDeal(
          supabase,
          dealId,
          deal.listing_id,
          deal.buyer_id,
          "Payment confirmed",
          "The seller confirmed they received your payment and is now transferring the license to you.",
        );
      } else {
        await notifyDeal(
          supabase,
          dealId,
          deal.listing_id,
          deal.seller_id,
          "Sale complete",
          "The buyer confirmed they received the license. Thanks for selling on Plugin Resale!",
        );
      }
    }
  }

  revalidatePath("/", "layout");
  redirect(`/deals/${dealId}`);
}

// Either side of a completed deal rates and reviews the other.
export async function addReview(formData: FormData) {
  const dealId = Number(formData.get("deal_id"));
  const rating = Number(formData.get("rating"));
  const comment = String(formData.get("comment") ?? "");
  if (!Number.isInteger(dealId) || !Number.isInteger(rating)) return;

  const supabase = await createClient();
  const { error } = await supabase.rpc("add_review", {
    p_deal_id: dealId,
    p_rating: rating,
    p_comment: comment,
  });
  if (error) {
    console.error("add_review failed:", error.message);
    redirect(`/deals/${dealId}?error=1`);
  }

  revalidatePath("/", "layout");
  redirect(`/deals/${dealId}`);
}
