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
  "id, name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified";

export function formatDate(iso: string) {
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}
