import type { MetadataRoute } from "next";
import { getAllPosts } from "@/lib/blog";
import { createClient } from "@/lib/supabase/server";

const SITE = "https://www.pluginresale.com";

// Every public page Google should know about. Rendered at request time (getAllPosts depends on
// today's date), so new listings and scheduled blog posts show up without a redeploy.
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const supabase = await createClient();
  const [posts, { data: developers }, { data: listings }] = await Promise.all([
    getAllPosts(),
    supabase.from("developers").select("slug").order("name"),
    supabase
      .from("listing_cards")
      .select("id, created_at")
      .eq("status", "active")
      .order("created_at", { ascending: false }),
  ]);

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
    ...(listings ?? []).map((listing) => ({
      url: `${SITE}/listings/${listing.id}`,
      lastModified: listing.created_at,
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
  ];
}
