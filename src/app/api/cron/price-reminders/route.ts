import { escapeHtml, emailButton, sendEmail } from "@/lib/email";
import { formatPrice, productName } from "@/lib/catalog";
import { signInUrl } from "@/lib/next-path";
import { claimPriceReminders, getUserEmail, type PriceReminder } from "@/lib/supabase/admin";

const ORIGIN = "https://www.pluginresale.com";

// Daily Vercel cron (vercel.json): one email per seller whose listings are still unsold
// 14 days after going live, suggesting a lower price. Each listing is only reminded once
// (claim_price_reminders), so calling this route again sends nothing new.
export async function GET(request: Request) {
  const secret = process.env.CRON_SECRET;
  if (secret && request.headers.get("authorization") !== `Bearer ${secret}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  const bySeller = new Map<string, PriceReminder[]>();
  for (const reminder of await claimPriceReminders()) {
    bySeller.set(reminder.seller_id, [...(bySeller.get(reminder.seller_id) ?? []), reminder]);
  }

  await Promise.all(
    [...bySeller].map(async ([sellerId, listings]) => {
      const email = await getUserEmail(sellerId);
      if (email) await sendEmail({ to: email, ...reminderEmail(listings) });
    }),
  );

  return Response.json({ sellers: bySeller.size });
}

// The seller lands on their listing, signed in first if needed, where they can change the price.
const listingUrl = (listing: PriceReminder) =>
  `${ORIGIN}${signInUrl(`/listings/${listing.listing_id}`)}`;

const title = (listing: PriceReminder) =>
  productName(listing.developer_name, listing.plugin_name);

function reminderEmail(listings: PriceReminder[]) {
  const [first] = listings;
  const single = listings.length === 1;

  const intro = single
    ? `<p>Your ${escapeHtml(title(first))} license (${formatPrice(first.price_eur)}) has been ` +
      `on Plugin Resale for 2 weeks and hasn&apos;t found a buyer yet.</p>`
    : `<p>These licenses have been on Plugin Resale for 2 weeks and haven&apos;t found a buyer yet:</p>` +
      `<ul>${listings
        .map(
          (listing) =>
            `<li><a href="${listingUrl(listing)}">${escapeHtml(title(listing))}</a>, ` +
            `${formatPrice(listing.price_eur)}</li>`,
        )
        .join("")}</ul>`;

  return {
    subject: single
      ? `Your ${title(first)} listing: still looking for a buyer?`
      : `Your ${listings.length} listings: still looking for a buyer?`,
    html:
      `<h2>Still looking for a buyer?</h2>` +
      intro +
      `<p>Buyers of used licenses look for a clear saving compared to the new price, ` +
      `including the developer&apos;s own sales. A slightly lower price is often what makes ` +
      `the difference, and you can change it in a few seconds from your listing page.</p>` +
      (single
        ? emailButton(listingUrl(first), "Change my price")
        : `<p>Open a listing above to change its price.</p>`) +
      `<p>Sharing your listing (Instagram, Facebook groups, Discord…) also helps it sell faster.</p>` +
      `<p style="color:#55545C;font-size:13px">You get this email once per listing, ` +
      `2 weeks after it goes live.</p>`,
  };
}
