# Affiliate links (Thomann, Plugin Boutique) + plugin pages

Validated with Victor on 2026-09-28.

## Goal

Earn affiliate commissions on new-license sales **without pulling buyers away from used
listings**. Used always comes first; "buy new" is the fallback when no used copy exists, when
the listing is gone, or when the developer forbids resale.

## Affiliate link format

Stored URLs are the clean product page, no query string. The affiliate parameters are added
at render time by one helper (`src/lib/affiliate.ts`), so a code change happens in one place.

- Thomann: `<product url>?offid=1&affid=2491&subid=pluginresale&subid2=<placement>`
- Plugin Boutique: `<product url>?a_aid=66a6642614e68&a_cid=1461e21b&chan=code2`
- `placement` = where the click happened: `plugin`, `listing`, `browse` (and `blog` if an
  article ever links a shop directly).
- Built with the URL API, so an existing query string is handled.

**One link only**: Thomann when the plugin has a Thomann URL, otherwise Plugin Boutique,
otherwise no "buy new" box at all.

## Data

Migration `0051_shop_links.sql`:
- `plugins.thomann_url text`, check `^https://www\.thomann\.[a-z.]+/[^?#]+$`
- `plugins.pluginboutique_url text`, check `^https://www\.pluginboutique\.com/product/[^?#]+$`
- `grant update (thomann_url, pluginboutique_url) on public.plugins to service_role`
  (readable by everyone through the existing `select` grant, writable only by us).

Thomann URLs are stored as the international English page (`www.thomann.de/intl/...htm`),
the site being in English.

Filled **by us, never guessed at runtime**, with
`node --env-file=.env.local supabase/scripts/set-plugin-shop-link.mjs <plugin id> <url> [--save]`
(shop detected from the host; without `--save` it only fetches the page and prints its title
for a by-eye check). Priority: plugins currently listed, plugins named in the blog, flagship
products of developers that forbid transfers. No bulk import of the 3,700 plugins.

## Plugin page `/developers/[slug]/[plugin]`

Plugin slugs are only unique per developer, hence the nesting.

Order on the page:
1. Breadcrumb Developers / Developer / Plugin, hero (name, developer, category, visual).
2. **Used licenses for sale**: active listings of this plugin (`ListingGrid`). None: "No one
   is selling it right now", with "Alert me" (existing `createAlert`, back to this page) and
   "I own it, sell it" (`/sell?plugin=<id>`).
3. Developer transfer rules (`TransferRules`).
4. **Buy new** box (if a shop URL exists).

Non-transferable developer (`transferable = false`): no used/alert/sell block, a "can't be
resold" notice, and the Buy new box moves to the top, before the transfer rules.

Metadata: canonical, openGraph and its own `opengraph-image.tsx` (a page that sets
`openGraph` loses the inherited image). Sitemap: only plugin pages that have an active listing
or a shop URL, to avoid thousands of near-empty pages.

Links to it:
- Developer page: each plugin name becomes a link.
- Listing page: the plugin name in the breadcrumb.
- Browse empty-search suggestions: each plugin name.
- Blog: plugin names in articles point to their plugin page (never straight to a shop).

## Buy new box (`src/components/BuyNew.tsx`)

"Prefer a new license? **Buy it at Thomann →**" plus the line "Affiliate link: we may earn a
commission, it doesn't change your price." Link: `target="_blank"`,
`rel="sponsored noopener"`. A compact inline variant for the Browse suggestions.

Where it shows:
- ✅ Plugin page.
- ✅ Browse empty search, on each suggested plugin.
- ✅ Listing page when the listing is `reserved` or `sold`.
- ❌ Never on an `active` listing.

## Legal

A short affiliate-links paragraph in the Terms and the Privacy policy, English and French
parts both (the French prevails, keep them in sync). No cookie banner needed: the tracking
happens on the shop's site, the link only carries parameters.

## Out of scope

Prices of new licenses, product feeds, automatic URL matching, ads.
