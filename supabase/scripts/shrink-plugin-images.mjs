// One-off (2026-10-04): the plugin visuals were stored at their original size (up to 3.5 MB PNG)
// and shown on every listing card, which blew through the Supabase free egress quota.
// Re-encodes each one as an 800 px wide WebP under a new name, points the plugin at it and
// removes the old file. Already-shrunk files (.webp) are skipped, so it is safe to re-run.
//
// Usage (from the repo root):
//   node --env-file=.env.local supabase/scripts/shrink-plugin-images.mjs          (dry run)
//   node --env-file=.env.local supabase/scripts/shrink-plugin-images.mjs --save
import sharp from "sharp";
import { createClient } from "@supabase/supabase-js";

const save = process.argv.includes("--save");
const admin = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const { data: plugins, error } = await admin
  .from("plugins")
  .select("id, name, image_path")
  .not("image_path", "is", null);
if (error) throw error;

let before = 0;
let after = 0;
for (const plugin of plugins) {
  if (plugin.image_path.endsWith(".webp")) continue;
  const { data: blob, error: dlError } = await admin.storage.from("plugin-images").download(plugin.image_path);
  if (dlError) {
    console.error(`${plugin.name}: ${dlError.message}`);
    continue;
  }
  const original = Buffer.from(await blob.arrayBuffer());
  const small = await sharp(original)
    .resize({ width: 800, withoutEnlargement: true })
    .webp({ quality: 80 })
    .toBuffer();
  before += original.length;
  after += small.length;
  console.log(`${plugin.name}: ${(original.length / 1e3) | 0} kB -> ${(small.length / 1e3) | 0} kB`);
  if (!save) continue;

  const path = `${plugin.id}-${Date.now()}.webp`;
  const { error: upError } = await admin.storage
    .from("plugin-images")
    .upload(path, small, { contentType: "image/webp", cacheControl: "31536000" });
  if (upError) throw upError;
  const { error: updError } = await admin.from("plugins").update({ image_path: path }).eq("id", plugin.id);
  if (updError) throw updError;
  await admin.storage.from("plugin-images").remove([plugin.image_path]);
}
console.log(`total: ${(before / 1e6).toFixed(1)} MB -> ${(after / 1e6).toFixed(1)} MB${save ? "" : " (dry run)"}`);
