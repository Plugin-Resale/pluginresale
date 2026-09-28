import type { MetadataRoute } from "next";
import { getAllPosts } from "@/lib/blog";
import { createClient } from "@/lib/supabase/server";

const SITE = "https://www.pluginresale.com";

// Every public page Google should know about. Rendered at request time (getAllPosts depends on
// today's date), so new listings and scheduled blog posts show up without a redeploy.
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const supabase = await createClient();
  const [posts, { data: developers }, { data: listings }, { data: shopPlugins }] =
    await Promise.all([
      getAllPosts(),
      supabase.from("developers").select("id, slug").order("name"),
      supabase
        .from("listing_cards")
        .select("id, created_at, plugin_id")
        .eq("status", "active")
        .order("created_at", { ascending: false }),
      supabase
        .from("plugins")
        .select("id")
        .or("thomann_url.not.is.null,pluginboutique_url.not.is.null"),
    ]);

  // Plugin pages: only those with an active listing or a shop page, not thousands of
  // near-empty pages for the whole catalogue.
  const pluginIds = [
    ...new Set([
      ...(listings ?? []).map((listing) => listing.plugin_id as number),
      ...(shopPlugins ?? []).map((plugin) => plugin.id as number),
    ]),
  ];
  const { data: plugins } = pluginIds.length
    ? await supabase.from("plugins").select("slug, developer_id").in("id", pluginIds)
    : { data: [] };
  const developerSlug = new Map((developers ?? []).map((d) => [d.id, d.slug]));

  const pages: MetadataRoute.Sitemap = [
    { url: SITE, changeFrequency: "daily", priority: 1 },
    { url: `${SITE}/browse`, changeFrequency: "daily", priority: 0.9 },
    { url: `${SITE}/developers`, changeFrequency: "weekly", priority: 0.8 },
    { url: `${SITE}/blog`, changeFrequency: "weekly", priority: 0.7 },
    { url: `${SITE}/faq`, changeFrequency: "monthly", priority: 0.6 },
    { url: `${SITE}/terms`, changeFrequency: "yearly", priority: 0.2 },
    { url: `${SITE}/privacy`, changeFrequency: "yearly", priority: 0.2 },
    { url: `${SITE}/legal`, changeFrequency: "yearly", priority: 0.2 },
  ];

  return [
    ...pages,
    ...posts.map((post) => ({
      url: `${SITE}/blog/${post.slug}`,
      lastModified: post.updated ?? post.date,
      changeFrequency: "monthly" as const,
      priority: 0.7,
    })),
    ...(developers ?? []).map((developer) => ({
      url: `${SITE}/developers/${developer.slug}`,
      changeFrequency: "monthly" as const,
      priority: 0.6,
    })),
    ...(plugins ?? []).map((plugin) => ({
      url: `${SITE}/developers/${developerSlug.get(plugin.developer_id)}/${plugin.slug}`,
      changeFrequency: "weekly" as const,
      priority: 0.7,
    })),
    ...(listings ?? []).map((listing) => ({
      url: `${SITE}/listings/${listing.id}`,
      lastModified: listing.created_at,
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
  ];
}
