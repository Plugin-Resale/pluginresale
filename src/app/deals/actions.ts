"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const START_ERRORS: Record<string, string> = {
  NOT_SIGNED_IN: "signin",
  USERNAME_REQUIRED: "username",
  NOT_AVAILABLE: "unavailable",
  OWN_LISTING: "own",
};

// "Buy with PayPal": reserves the listing and opens the deal page.
export async function startDeal(formData: FormData) {
  const listingId = Number(formData.get("listing_id"));
  if (!Number.isInteger(listingId)) return;

  const supabase = await createClient();
  const { data: dealId, error } = await supabase.rpc("start_deal", { p_listing_id: listingId });

  if (error) {
    const code = START_ERRORS[error.message];
    if (code === "signin") redirect("/signin");
    if (!code) console.error("start_deal failed:", error.message);
    redirect(`/listings/${listingId}?error=${code ?? "unknown"}`);
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
