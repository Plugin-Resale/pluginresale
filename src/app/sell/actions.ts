"use server";

import { redirect } from "next/navigation";
import { CATEGORIES, FORMATS } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";

export type SellValues = {
  pluginId: string;
  version: string;
  price: string;
  formats: string[];
  description: string;
  paypalEmail: string;
  developerId: string;
  newPluginName: string;
  newPluginCategory: string;
};

export type SellState = { error?: string; values?: SellValues };

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const CATEGORY_KEYS = Object.keys(CATEGORIES);

const DB_ERRORS: Record<string, string> = {
  NOT_SIGNED_IN: "Your session has expired. Please sign in again.",
  USERNAME_REQUIRED: "Choose a username in My account before selling.",
  UNKNOWN_PLUGIN: "Pick your plugin from the suggestions list, or fill in the developer, name and category to add it.",
  NOT_TRANSFERABLE: "This developer doesn't allow license transfers, so it can't be sold here.",
};

export async function createListing(_prev: SellState, formData: FormData): Promise<SellState> {
  const values: SellValues = {
    pluginId: String(formData.get("plugin_id") ?? ""),
    version: String(formData.get("version") ?? "").trim(),
    price: String(formData.get("price") ?? "").trim().replace(",", "."),
    formats: formData.getAll("formats").map(String),
    description: String(formData.get("description") ?? "").trim(),
    paypalEmail: String(formData.get("paypal_email") ?? "").trim(),
    developerId: String(formData.get("developer_id") ?? ""),
    newPluginName: String(formData.get("new_plugin_name") ?? "").trim(),
    newPluginCategory: String(formData.get("new_plugin_category") ?? ""),
  };
  const fail = (error: string): SellState => ({ error, values });

  const pluginId = Number(values.pluginId);
  const price = Number(values.price);
  const hasPlugin = Number.isInteger(pluginId) && pluginId > 0;

  const developerId = Number(values.developerId);
  const hasNewPlugin =
    Number.isInteger(developerId) &&
    developerId > 0 &&
    values.newPluginName.length > 0 &&
    CATEGORY_KEYS.includes(values.newPluginCategory);

  if (!hasPlugin && !hasNewPlugin) {
    return fail("Pick your plugin from the suggestions list, or fill in the developer, name and category to add it.");
  }
  if (!hasPlugin && values.newPluginName.length > 80) {
    return fail("Plugin name is too long (80 characters max).");
  }
  if (!/^\d+(\.\d{1,2})?$/.test(values.price) || price < 1 || price > 10000) {
    return fail("Enter a price between €1 and €10,000.");
  }
  if (values.version.length > 30) return fail("Version is too long (30 characters max).");
  if (values.description.length > 2000) {
    return fail("Description is too long (2,000 characters max).");
  }
  if (!values.formats.every((f) => (FORMATS as readonly string[]).includes(f))) {
    return fail("Unknown plugin format.");
  }
  if (!EMAIL_RE.test(values.paypalEmail)) return fail("Enter the email of your PayPal account.");
  if (
    formData.get("owns_license") !== "on" ||
    formData.get("will_transfer") !== "on" ||
    formData.get("private_seller") !== "on"
  ) {
    return fail("Please confirm the three statements at the bottom of the form.");
  }

  const supabase = await createClient();
  const { data: id, error } = await supabase.rpc("create_listing", {
    p_plugin_id: hasPlugin ? pluginId : null,
    p_version: values.version,
    p_price_eur: price,
    p_description: values.description,
    p_formats: values.formats,
    p_paypal_email: values.paypalEmail,
    p_new_plugin_name: hasPlugin ? null : values.newPluginName,
    p_new_plugin_category: hasPlugin ? null : values.newPluginCategory,
    p_developer_id: hasPlugin ? null : developerId,
  });

  if (error) {
    const known = DB_ERRORS[error.message];
    if (!known) console.error("create_listing failed:", error.message);
    return fail(known ?? "Something went wrong. Please try again.");
  }

  redirect(`/listings/${id}?published=1`);
}
