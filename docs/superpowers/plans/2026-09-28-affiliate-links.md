# Affiliate links + plugin pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a public page per catalogue plugin (used listings first) and a single "Buy new" affiliate link (Thomann first, else Plugin Boutique) where no used copy can be bought.

**Architecture:** Two nullable URL columns on `plugins`, filled by a service-role script. A pure helper builds the affiliate URL at render time; one `<BuyNew>` component renders it. The plugin page lives under the developer route because plugin slugs are unique per developer only.

**Tech Stack:** Next.js 16 App Router (server components), Supabase (Postgres + RLS), plain CSS in `src/app/globals.css`.

Spec: `docs/superpowers/specs/2026-09-28-affiliate-links-design.md`.

## Global Constraints

- Thomann params: `offid=1&affid=2491&subid=pluginresale&subid2=<placement>`.
- Plugin Boutique params: `a_aid=66a6642614e68&a_cid=1461e21b&chan=code2`.
- One link only: Thomann if set, else Plugin Boutique, else nothing.
- Never a Buy new link on an `active` listing.
- Every affiliate link: `target="_blank" rel="sponsored noopener"` + the line "Affiliate link: we may earn a commission, it doesn't change your price."
- SQL comments free of `'` and `;` (Supabase SQL Editor limitation).
- No test runner in this repo: each task is verified with `npm run lint`, `npx tsc --noEmit` and, for pages, the dev server preview.

---

### Task 1: Migration + shop-link script

**Files:**
- Create: `supabase/migrations/0051_shop_links.sql`
- Create: `supabase/scripts/set-plugin-shop-link.mjs`

- [ ] **Step 1: Migration**

```sql
-- Official shop pages for the Buy new affiliate link. Clean URL only, the affiliate
-- parameters are added by the site when it renders the link.
alter table public.plugins
  add column thomann_url text check (thomann_url ~ '^https://www\.thomann\.[a-z.]+/[^?#]+$'),
  add column pluginboutique_url text check (pluginboutique_url ~ '^https://www\.pluginboutique\.com/product/[^?#]+$');

grant update (thomann_url, pluginboutique_url) on public.plugins to service_role;
```

- [ ] **Step 2: Script** — `node --env-file=.env.local supabase/scripts/set-plugin-shop-link.mjs <plugin id> <url> [--save]`: detects the shop from the host (`thomann.*` → `thomann_url`, `pluginboutique.com` → `pluginboutique_url`, anything else → error), strips query/hash, fetches the page and prints HTTP status + `<title>` next to the plugin name for a by-eye check; `--save` writes the column. `--clear thomann|pluginboutique` sets it back to null.

- [ ] **Step 3: Commit** `Migration 0051 + script: shop links on plugins`

### Task 2: Affiliate helper + BuyNew component

**Files:**
- Create: `src/lib/affiliate.ts`
- Create: `src/components/BuyNew.tsx`
- Modify: `src/lib/catalog.ts` (add `ShopLinks` type)
- Modify: `src/app/globals.css` (`.buy-new` styles)

**Produces:**
- `type ShopLinks = { thomann_url: string | null; pluginboutique_url: string | null }` (catalog.ts)
- `type Placement = "plugin" | "listing" | "browse" | "blog"`
- `buyNewLink(links: ShopLinks, placement: Placement): { shop: "Thomann" | "Plugin Boutique"; url: string } | null`
- `<BuyNew links={ShopLinks} placement={Placement} compact?={boolean} />` renders nothing when `buyNewLink` returns null.

```ts
// src/lib/affiliate.ts
import type { ShopLinks } from "./catalog";

export type Placement = "plugin" | "listing" | "browse" | "blog";

// Thomann first when both shops sell it (Victor, 2026-09-28).
export function buyNewLink(links: ShopLinks, placement: Placement) {
  if (links.thomann_url) {
    const url = new URL(links.thomann_url);
    url.searchParams.set("offid", "1");
    url.searchParams.set("affid", "2491");
    url.searchParams.set("subid", "pluginresale");
    url.searchParams.set("subid2", placement);
    return { shop: "Thomann" as const, url: url.href };
  }
  if (links.pluginboutique_url) {
    const url = new URL(links.pluginboutique_url);
    url.searchParams.set("a_aid", "66a6642614e68");
    url.searchParams.set("a_cid", "1461e21b");
    url.searchParams.set("chan", "code2");
    return { shop: "Plugin Boutique" as const, url: url.href };
  }
  return null;
}
```

- [ ] Verify the helper with a one-off `node --experimental-strip-types` check: Thomann wins when both are set, PB params exact, null when none.
- [ ] Lint + typecheck, commit `Affiliate link helper and Buy new box`.

### Task 3: Plugin page

**Files:**
- Create: `src/app/developers/[slug]/[plugin]/page.tsx`
- Create: `src/app/developers/[slug]/[plugin]/opengraph-image.tsx`
- Modify: `src/app/globals.css` (`.plugin-hero`, `.plugin-section`)

Data: developer by slug (`DEVELOPER_COLUMNS`), plugin by `(developer_id, slug)` with `id, name, slug, category, image_path, thomann_url, pluginboutique_url`, active `listing_cards` where `plugin_id = id`, and for a signed-in user whether a `listing_alerts` row exists. `cache()` the developer+plugin lookup for metadata + page.

Layout (transferable or unverified): breadcrumb → hero → "Used licenses for sale" (`ListingGrid`, or empty state with Alert me / I own it, sell it, and `?alert=set|error` notice) → `TransferRules` → `BuyNew placement="plugin"`.
Non-transferable: breadcrumb → hero → notice "X doesn't allow license transfers, so it can't be resold here." → `BuyNew` → `TransferRules`.

Metadata: title `Used ${dev} ${plugin} licenses` (non-transferable: `${dev} ${plugin} license transfer`), canonical `/developers/<dev>/<plugin>`, openGraph. OG image: `ogImage({ eyebrow: developer name, title: plugin name, transferable, footer })`.

- [ ] Build, preview `/developers/fabfilter/pro-q-4` and a non-transferable plugin, commit `Plugin page: used listings first, then transfer rules and Buy new`.

### Task 4: Links into the plugin page + Buy new placements

**Files:**
- Modify: `src/app/developers/[slug]/page.tsx` (plugin names → links)
- Modify: `src/app/listings/[id]/page.tsx` (breadcrumb link, Buy new when reserved/sold)
- Modify: `src/app/browse/page.tsx` + `src/app/browse/NoResults.tsx` (plugin links, compact Buy new)
- Modify: `src/app/sitemap.ts` (plugin pages with an active listing or a shop URL)

Listing page: one extra query `plugins.select("slug, thomann_url, pluginboutique_url").eq("id", listing.plugin_id)`. Browse: after `search_plugins`, one query on `plugins` by the matched ids for slug + shop URLs, merged into `PluginMatch` (`slug`, `thomann_url`, `pluginboutique_url`).

- [ ] Lint, typecheck, preview, commit `Link plugin pages everywhere, Buy new on sold listings and empty searches`.

### Task 5: Legal + blog links + docs

- Terms §1 (EN + FR): affiliate links paragraph. Privacy §5 Cookies (EN + FR): clicking a shop link takes you to that shop, which may set its own cookies under its own policy; we send no personal data. Bump "Last updated" on both, both languages.
- Blog: link plugin names already mentioned in published/scheduled articles to their plugin page (only products that exist in the catalogue, checked against the DB).
- CLAUDE.md: summary entry.
- [ ] Commit `Affiliate links: Terms, Privacy, blog links, CLAUDE.md`.

### Task 6: Fill the first shop links (after Victor applies 0051)

Plugins currently listed + plugins named in the blog: find the official Thomann page (international) and Plugin Boutique page, check by eye with the script, `--save`.
