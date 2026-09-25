import type { Developer } from "@/lib/catalog";
import { ogImage } from "@/lib/og";
import { createClient } from "@/lib/supabase/server";

export const alt = "Developer license transfer rules on Plugin Resale";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const supabase = await createClient();
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
