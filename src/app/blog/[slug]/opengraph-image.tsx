import { getPost } from "@/lib/blog";
import { ogImage } from "@/lib/og";

export const alt = "Plugin Resale blog";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const post = await getPost((await params).slug);
  return ogImage({
    eyebrow: "Blog",
    title: post?.title ?? "Buying and selling used plugin licenses",
    footer: post ? `${post.readingMinutes} min read` : undefined,
  });
}
