import { CATEGORIES, formatPrice, type ListingCard } from "@/lib/catalog";
import { ogImage } from "@/lib/og";
import { createClient } from "@/lib/supabase/server";

export const alt = "Used plugin license for sale on Plugin Resale";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

const STATUS_LABELS: Partial<Record<ListingCard["status"], string>> = {
  reserved: "Reserved",
  sold: "Sold",
};

export default async function Image({ params }: { params: Promise<{ id: string }> }) {
  const id = Number((await params).id);
  const supabase = await createClient();
  const { data: listing } =
    Number.isInteger(id) && id > 0
      ? await supabase.from("listing_cards").select("*").eq("id", id).maybeSingle<ListingCard>()
      : { data: null };

  if (!listing) return ogImage({ title: "Used plugin licenses, straight from other producers." });

  const status = STATUS_LABELS[listing.status];
  return ogImage({
    eyebrow: `${listing.developer_name} · ${CATEGORIES[listing.category]}`,
    title: listing.plugin_name,
    price: status ? `${formatPrice(listing.price_eur)} · ${status}` : formatPrice(listing.price_eur),
    transferable: listing.transferable,
    footer: "Used license, pay the seller directly with PayPal",
  });
}
