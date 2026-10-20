import type { Metadata } from "next";
import Link from "next/link";
import { formatPostDate, getAllPosts, type PostMeta } from "@/lib/blog";
import { pluginImageUrl } from "@/lib/images";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "Blog",
  description:
    "Guides and news about buying and selling second-hand audio plugin licenses: resale rights, license transfers, safe payments.",
  alternates: { canonical: "/blog" },
};

type Cover =
  | { kind: "photo"; src: string; alt: string }
  | { kind: "plugin"; src: string; alt: string }
  | { kind: "text"; kicker: string; label: string };

type DevPlugin = { developer_id: string; name: string; image_path: string };

// One visual per post, never guessed:
// 1. the post's own photo (front matter `image:`, the interviews),
// 2. for a developer guide (front matter `developer:`), the official visual of one of that
//    developer's plugins (plugins.image_path), preferring a plugin named in the title,
// 3. otherwise a plain text block, like a listing without a plugin visual.
async function getCovers(posts: PostMeta[]): Promise<Map<string, Cover>> {
  const covers = new Map<string, Cover>();
  const devSlugs = [
    ...new Set(posts.filter((p) => !p.image && p.developer).map((p) => p.developer!)),
  ];

  const developers = new Map<string, { id: string; name: string }>();
  const pluginsByDev = new Map<string, DevPlugin[]>();
  if (devSlugs.length > 0) {
    const supabase = await createClient();
    const { data: devs } = await supabase
      .from("developers")
      .select("id, name, slug")
      .in("slug", devSlugs);
    for (const d of devs ?? []) developers.set(d.slug, { id: d.id, name: d.name });

    const ids = [...developers.values()].map((d) => d.id);
    if (ids.length > 0) {
      const { data: plugins } = await supabase
        .from("plugins")
        .select("developer_id, name, image_path")
        .in("developer_id", ids)
        .not("image_path", "is", null)
        .order("name")
        .returns<DevPlugin[]>();
      for (const p of plugins ?? []) {
        const list = pluginsByDev.get(p.developer_id) ?? [];
        list.push(p);
        pluginsByDev.set(p.developer_id, list);
      }
    }
  }

  for (const post of posts) {
    if (post.image) {
      covers.set(post.slug, { kind: "photo", src: post.image, alt: "" });
      continue;
    }
    const dev = post.developer ? developers.get(post.developer) : undefined;
    if (dev) {
      const plugins = pluginsByDev.get(dev.id) ?? [];
      const title = post.title.toLowerCase();
      const named = plugins
        .filter((p) => title.includes(p.name.toLowerCase().replace(/\s+\d+(\.\d+)?$/, "")))
        .sort((a, b) => b.name.length - a.name.length)[0];
      const plugin = named ?? plugins[0];
      covers.set(
        post.slug,
        plugin
          ? { kind: "plugin", src: pluginImageUrl(plugin.image_path), alt: "" }
          : { kind: "text", kicker: "Transfer guide", label: dev.name },
      );
      continue;
    }
    covers.set(post.slug, { kind: "text", kicker: "Guide", label: "Plugin Resale" });
  }
  return covers;
}

export default async function BlogPage() {
  const posts = await getAllPosts();
  const covers = await getCovers(posts);

  return (
    <main className="narrow narrow-wide page blog-page">
      <p className="eyebrow">Blog</p>
      <h1 className="page-title">Guides for buying and selling used plugins</h1>
      <p className="lead">
        Resale rights, license transfers and how to trade safely with other musicians.
      </p>

      {posts.length === 0 ? (
        <p className="empty">No articles yet.</p>
      ) : (
        <ul className="post-list">
          {posts.map((post) => {
            const cover = covers.get(post.slug)!;
            return (
              <li key={post.slug}>
                <Link href={`/blog/${post.slug}`} className="post-card post-card-cover">
                  {cover.kind === "text" ? (
                    <span className="post-thumb post-thumb-text" aria-hidden="true">
                      <span className="post-thumb-kicker">{cover.kicker}</span>
                      <span className="post-thumb-label">{cover.label}</span>
                    </span>
                  ) : (
                    <span className={`post-thumb post-thumb-${cover.kind}`}>
                      {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
                      <img src={cover.src} alt={cover.alt} loading="lazy" />
                    </span>
                  )}
                  <span className="post-card-body">
                    <span className="post-meta">
                      <time dateTime={post.date}>{formatPostDate(post.date)}</time> ·{" "}
                      {post.readingMinutes} min read
                    </span>
                    <span className="post-card-title">{post.title}</span>
                    <span className="post-card-desc">{post.description}</span>
                    <span className="more-link">Read the article →</span>
                  </span>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </main>
  );
}
