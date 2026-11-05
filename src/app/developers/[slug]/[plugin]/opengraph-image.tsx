import type { Developer } from "@/lib/catalog";
import { ogImage } from "@/lib/og";
import { createAnonClient } from "@/lib/supabase/anon";

export const alt = "Used plugin licenses on Plugin Resale";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
// Link previews are fetched by every social network and messenger: cached for an hour.
export const revalidate = 3600;

// Nothing is prerendered at build time: each one is rendered on first request, then cached for
// `revalidate` seconds. Without this export a dynamic route is never cached at all.
export function generateStaticParams() {
  return [];
}

export default async function Image({
  params,
}: {
  params: Promise<{ slug: string; plugin: string }>;
}) {
  const { slug, plugin: pluginSlug } = await params;
  const supabase = createAnonClient();
  const { data: developer } = await supabase
    .from("developers")
    .select("id, name, transferable")
    .eq("slug", slug)
    .maybeSingle<Pick<Developer, "id" | "name" | "transferable">>();
  const { data: plugin } = developer
    ? await supabase
        .from("plugins")
        .select("name")
        .eq("developer_id", developer.id)
        .eq("slug", pluginSlug)
        .maybeSingle<{ name: string }>()
    : { data: null };

  if (!developer || !plugin) return ogImage({ title: "Buy and sell used plugin licenses." });

  return ogImage({
    eyebrow: developer.name,
    title: plugin.name,
    transferable: developer.transferable,
    footer:
      developer.transferable === false
        ? "License transfer rules"
        : "Used licenses, free to buy, no commission",
  });
}
