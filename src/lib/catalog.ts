// Reference data: developers (with their license-transfer rules) and plugins.

export type Developer = {
  id: number;
  name: string;
  slug: string;
  website: string | null;
  transferable: boolean;
  fee: string | null;
  who_pays: string | null;
  process: string | null;
  typical_delay: string | null;
  restrictions: string | null;
  source_url: string | null;
  last_verified: string | null;
  no_fee: boolean;
};

export type Plugin = {
  id: number;
  developer_id: number;
  name: string;
  slug: string;
  category: Category;
};

export const CATEGORIES = {
  eq: "EQ",
  compression: "Compression",
  "reverb-delay": "Reverb & Delay",
  saturation: "Saturation",
  mastering: "Mastering",
  synths: "Synths",
  "sample-libraries": "Sample libraries",
  bundles: "Bundles",
  utilities: "Utilities",
} as const;

export type Category = keyof typeof CATEGORIES;

export const DEVELOPER_COLUMNS =
  "id, name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee";

export function formatDate(iso: string) {
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}

export const FORMATS = ["VST3", "AU", "AAX", "VST2", "Standalone"] as const;

export type ListingStatus = "active" | "reserved" | "sold" | "removed";

// A row of the `listing_cards` view.
export type ListingCard = {
  id: number;
  status: ListingStatus;
  price_eur: number;
  version: string | null;
  formats: string[];
  description: string;
  created_at: string;
  seller_id: string;
  seller_username: string | null;
  seller_since: string;
  seller_avg_rating: number | null;
  seller_review_count: number;
  plugin_id: number;
  plugin_name: string;
  category: Category;
  developer_id: number;
  developer_name: string;
  developer_slug: string;
  transferable: boolean;
  no_fee: boolean;
};

const priceFormat = new Intl.NumberFormat("en-IE", {
  style: "currency",
  currency: "EUR",
  minimumFractionDigits: 0,
  maximumFractionDigits: 2,
});

export function formatPrice(eur: number) {
  return priceFormat.format(Number(eur));
}
