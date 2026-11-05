import { readFile } from "node:fs/promises";
import path from "node:path";
import { getPost } from "@/lib/blog";
import { ogImage } from "@/lib/og";

export const alt = "Plugin Resale blog";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
// Cached for an hour: the image only changes with a redeploy, but the post may not be published
// yet (scheduled posts), so it is not fixed at build time.
export const revalidate = 3600;

// Nothing is prerendered at build time: each one is rendered on first request, then cached for
// `revalidate` seconds. Without this export a dynamic route is never cached at all.
export function generateStaticParams() {
  return [];
}

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const post = await getPost((await params).slug);

  // A post with an `image` in its front matter gets that photo next to the title.
  let photo: string | undefined;
  if (post?.image) {
    const data = await readFile(path.join(process.cwd(), "public", post.image));
    const type = post.image.endsWith(".png") ? "image/png" : "image/jpeg";
    photo = `data:${type};base64,${data.toString("base64")}`;
  }

  return ogImage({
    eyebrow: "Blog",
    title: post?.title ?? "Buying and selling used plugin licenses",
    footer: post ? `${post.readingMinutes} min read` : undefined,
    photo,
  });
}
