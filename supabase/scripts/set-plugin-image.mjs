// Sets the official visual of a catalogue plugin (migration 0048): finds the og:image of the
// plugin's official product page (or takes a direct image URL), saves a local copy to look at,
// and with --save copies it into the plugin-images bucket and records it on the plugin.
//
// Usage (from the repo root):
//   node --env-file=.env.local supabase/scripts/set-plugin-image.mjs <plugin id> <url>          (preview only)
//   node --env-file=.env.local supabase/scripts/set-plugin-image.mjs <plugin id> <url> --save
import { writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import sharp from "sharp";
import { createClient } from "@supabase/supabase-js";

const [pluginId, pageUrl, flag] = process.argv.slice(2);
if (!/^\d+$/.test(pluginId ?? "") || !pageUrl) {
  console.error("Usage: set-plugin-image.mjs <plugin id> <official page or image URL> [--save]");
  process.exit(1);
}

const TYPES = { "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp" };
const HEADERS = {
  "user-agent":
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
};

async function findImageUrl(url) {
  const res = await fetch(url, { headers: HEADERS, redirect: "follow", signal: AbortSignal.timeout(20000) });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  if ((res.headers.get("content-type") ?? "").startsWith("image/")) return url;
  const html = await res.text();
  for (const tag of html.match(/<meta\b[^>]*>/gi) ?? []) {
    const key = /(?:property|name)\s*=\s*["']([^"']+)["']/i.exec(tag)?.[1]?.toLowerCase();
    const content = /content\s*=\s*["']([^"']+)["']/i.exec(tag)?.[1];
    if (content && ["og:image", "og:image:secure_url", "twitter:image"].includes(key)) {
      return new URL(content.replaceAll("&amp;", "&"), res.url).href;
    }
  }
  throw new Error(`No og:image on ${url}`);
}

const admin = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const { data: plugin, error: pluginError } = await admin
  .from("plugins")
  .select("id, name, image_path")
  .eq("id", Number(pluginId))
  .single();
if (pluginError) throw pluginError;

const imageUrl = await findImageUrl(pageUrl);
const res = await fetch(imageUrl, { headers: HEADERS, signal: AbortSignal.timeout(20000) });
const type = (res.headers.get("content-type") ?? "").split(";")[0].trim();
const ext = TYPES[type];
if (!res.ok || !ext) throw new Error(`${imageUrl}: HTTP ${res.status}, type ${type}`);
const bytes = Buffer.from(await res.arrayBuffer());
if (bytes.length > 5 * 1024 * 1024) throw new Error(`${imageUrl}: larger than 5 MB`);

const preview = join(tmpdir(), `plugin-${plugin.id}.${ext}`);
await writeFile(preview, bytes);
console.log(`${plugin.name}: ${imageUrl}\npreview: ${preview}`);
if (flag !== "--save") process.exit(0);

// Shown at most ~320 px wide: an 800 px WebP is sharp on retina screens and ~50 kB instead of
// the multi-MB originals that used up the Supabase egress quota (2026-10-04).
const small = await sharp(bytes).resize({ width: 800, withoutEnlargement: true }).webp({ quality: 80 }).toBuffer();

// A new name each time, so browsers and the CDN never show a cached older image.
const path = `${plugin.id}-${Date.now()}.webp`;
const { error: uploadError } = await admin.storage
  .from("plugin-images")
  .upload(path, small, { contentType: "image/webp", cacheControl: "31536000" });
if (uploadError) throw uploadError;

const { error: updateError } = await admin.from("plugins").update({ image_path: path }).eq("id", plugin.id);
if (updateError) throw updateError;
if (plugin.image_path) await admin.storage.from("plugin-images").remove([plugin.image_path]);
console.log(`saved: plugin-images/${path}`);
