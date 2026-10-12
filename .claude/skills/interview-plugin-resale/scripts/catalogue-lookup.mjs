// Finds plugins named in an interview in the production catalogue, with their page URL and their
// developer's transfer rules, to link them in the article and write the "plugins, second-hand"
// section. Developer facts must come from here (and the official page in source_url), never memory.
//
// Usage (from the repo root):
//   node --env-file=.env.local .claude/skills/interview-plugin-resale/scripts/catalogue-lookup.mjs "Pro-Q" "Uni-L" "Massive Passive"
// Each term is matched loosely (case-insensitive, punctuation ignored) against plugin names;
// a term with no plugin match is also tried against developer names.
import { createClient } from "@supabase/supabase-js";

const terms = process.argv.slice(2);
if (!terms.length) throw new Error('usage: catalogue-lookup.mjs "<plugin name>" ...');
const db = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
const DEV = "name, slug, transferable, fee, who_pays, process, restrictions, source_url";

const rules = (d) =>
  `   rules: ${d.transferable === true ? "TRANSFERABLE" : d.transferable === false ? "NOT transferable" : "NOT VERIFIED"}` +
  `${d.fee ? ` | fee: ${d.fee}` : ""}${d.who_pays ? ` | who pays: ${d.who_pays}` : ""}\n` +
  `${d.process ? `   process: ${d.process}\n` : ""}${d.restrictions ? `   restrictions: ${d.restrictions}\n` : ""}` +
  `   source: ${d.source_url ?? "none"} | page: /developers/${d.slug}`;

for (const term of terms) {
  const pattern = "%" + term.replace(/[^a-z0-9]+/gi, "%") + "%";
  const { data, error } = await db.from("plugins").select(`name, slug, created_by, developers (${DEV})`).ilike("name", pattern).limit(8);
  if (error) throw error;
  console.log(`\n### ${term}`);
  if (data.length) {
    for (const p of data) {
      const d = p.developers;
      console.log(`- ${d.name} ${p.name} -> /developers/${d.slug}/${p.slug}${p.created_by ? " (seller-added)" : ""}\n${rules(d)}`);
    }
    continue;
  }
  const { data: devs } = await db.from("developers").select(DEV).ilike("name", pattern).limit(3);
  if (devs?.length) for (const d of devs) console.log(`- no plugin match, developer ${d.name}:\n${rules(d)}`);
  else console.log("- not in the catalogue (neither plugin nor developer)");
}
