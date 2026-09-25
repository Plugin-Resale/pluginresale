"use server";

import { redirect } from "next/navigation";
import { safeNext, signInUrl } from "@/lib/next-path";
import { createClient } from "@/lib/supabase/server";

// Back to the search the alert was set from, with ?alert=set|error for the notice.
function withAlert(path: string, value: "set" | "error") {
  const url = new URL(path, "https://www.pluginresale.com");
  url.searchParams.set("alert", value);
  return `${url.pathname}${url.search}`;
}

// "Alert me": email this user when someone lists the plugin (listing_alerts, migration 0038).
export async function createAlert(formData: FormData) {
  const back = safeNext(formData.get("back")) ?? "/browse";
  const pluginId = Number(formData.get("plugin_id"));
  if (!Number.isInteger(pluginId) || pluginId <= 0) redirect(back);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect(signInUrl(back));

  const { error } = await supabase.from("listing_alerts").insert({ plugin_id: pluginId });
  // 23505: this alert already exists, which is what the user wanted anyway.
  if (error && error.code !== "23505") {
    console.error("listing alert insert failed:", error.message);
    redirect(withAlert(back, "error"));
  }
  redirect(withAlert(back, "set"));
}
