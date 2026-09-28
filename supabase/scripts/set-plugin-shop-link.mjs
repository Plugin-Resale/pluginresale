// Sets the Thomann or Plugin Boutique page of a catalogue plugin (migration 0051), used for the
// "Buy new" affiliate link. The shop is picked from the URL. Without --save it only fetches the
// page and prints its title, to check by eye that it is the right product and major version.
//
// Usage (from the repo root):
//   node --env-file=.env.local supabase/scripts/set-plugin-shop-link.mjs <plugin id> <url>          (check only)
//   node --env-file=.env.local supabase/scripts/set-plugin-shop-link.mjs <plugin id> <url> --save
//   node --env-file=.env.local supabase/scripts/set-plugin-shop-link.mjs <plugin id> --clear thomann|pluginboutique
import { createClient } from "@supabase/supabase-js";

const [pluginId, arg, flag] = process.argv.slice(2);
if (!/^\d+$/.test(pluginId ?? "") || !arg) {
  console.error(
    "Usage: set-plugin-shop-link.mjs <plugin id> <shop URL> [--save]\n" +
      "       set-plugin-shop-link.mjs <plugin id> --clear thomann|pluginboutique",
  );
  process.exit(1);
}

const COLUMNS = { thomann: "thomann_url", pluginboutique: "pluginboutique_url" };
const HEADERS = {
  "user-agent":
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
  "accept-language": "en",
};

const admin = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const { data: plugin, error: pluginError } = await admin
  .from("plugins")
  .select("id, name, thomann_url, pluginboutique_url, developers (name)")
  .eq("id", Number(pluginId))
  .single();
if (pluginError) throw pluginError;
const label = `${plugin.developers.name} ${plugin.name}`;

if (arg === "--clear") {
  const column = COLUMNS[flag];
  if (!column) throw new Error("--clear needs thomann or pluginboutique");
  const { error } = await admin.from("plugins").update({ [column]: null }).eq("id", plugin.id);
  if (error) throw error;
  console.log(`${label}: ${column} cleared`);
  process.exit(0);
}

const url = new URL(arg);
url.search = "";
url.hash = "";
url.protocol = "https:";
const column = /(^|\.)thomann\.[a-z.]+$/.test(url.hostname)
  ? "thomann_url"
  : url.hostname.endsWith("pluginboutique.com")
    ? "pluginboutique_url"
    : null;
if (!column) throw new Error(`${url.hostname} is neither Thomann nor Plugin Boutique`);
if (!url.hostname.startsWith("www.")) url.hostname = `www.${url.hostname}`;

const res = await fetch(url, { headers: HEADERS, redirect: "follow", signal: AbortSignal.timeout(20000) });
const title = /<title[^>]*>([^<]*)<\/title>/i.exec(await res.text())?.[1]?.trim() ?? "(no title)";
console.log(`${label}\n  ${url.href}\n  HTTP ${res.status} -> ${res.url}\n  page title: ${title}`);
if (!res.ok) console.warn("  warning: the page did not answer 200, check it in a browser");
if (flag !== "--save") process.exit(0);

const { error: updateError } = await admin.from("plugins").update({ [column]: url.href }).eq("id", plugin.id);
if (updateError) throw updateError;
console.log(`saved: ${column}`);
