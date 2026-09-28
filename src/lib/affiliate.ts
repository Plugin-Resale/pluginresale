// "Buy new" affiliate links. The database stores each shop's clean product URL (migration
// 0051), the affiliate parameters are added here so a code change happens in one place.
import type { ShopLinks } from "./catalog";

// Where the click happened, sent to Thomann as subid2 to see it in their stats.
export type Placement = "plugin" | "listing" | "browse" | "blog";

export type BuyNewLink = { shop: "Thomann" | "Plugin Boutique"; url: string };

// One link only: Thomann when both shops sell the plugin (Victor, 2026-09-28).
export function buyNewLink(links: ShopLinks, placement: Placement): BuyNewLink | null {
  if (links.thomann_url) {
    const url = new URL(links.thomann_url);
    url.searchParams.set("offid", "1");
    url.searchParams.set("affid", "2491");
    url.searchParams.set("subid", "pluginresale");
    url.searchParams.set("subid2", placement);
    return { shop: "Thomann", url: url.href };
  }
  if (links.pluginboutique_url) {
    const url = new URL(links.pluginboutique_url);
    url.searchParams.set("a_aid", "66a6642614e68");
    url.searchParams.set("a_cid", "1461e21b");
    url.searchParams.set("chan", "code2");
    return { shop: "Plugin Boutique", url: url.href };
  }
  return null;
}
