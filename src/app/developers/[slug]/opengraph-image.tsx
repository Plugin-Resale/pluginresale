import type { Developer } from "@/lib/catalog";
import { ogImage } from "@/lib/og";
import { createAnonClient } from "@/lib/supabase/anon";

export const alt = "Developer license transfer rules on Plugin Resale";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
// Link previews are fetched by every social network and messenger: cached for an hour.
export const revalidate = 3600;

// Nothing is prerendered at build time: each one is rendered on first request, then cached for
// `revalidate` seconds. Without this export a dynamic route is never cached at all.
export function generateStaticParams() {
  return [];
}

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const supabase = createAnonClient();
  const { data: developer } = await supabase
    .from("developers")
    .select("name, transferable")
    .eq("slug", (await params).slug)
    .maybeSingle<Pick<Developer, "name" | "transferable">>();

  if (!developer) return ogImage({ title: "Every developer's license transfer rules." });

  return ogImage({
    eyebrow: "License transfer rules",
    title: developer.name,
    transferable: developer.transferable,
    footer: "Fee, who pays, process and restrictions",
  });
}
