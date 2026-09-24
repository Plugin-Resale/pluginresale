import type { Metadata } from "next";
import Link from "next/link";
import { formatPostDate, getAllPosts } from "@/lib/blog";

export const metadata: Metadata = {
  title: "Blog",
  description:
    "Guides and news about buying and selling second-hand audio plugin licenses: resale rights, license transfers, safe payments.",
  alternates: { canonical: "/blog" },
};

export default async function BlogPage() {
  const posts = await getAllPosts();

  return (
    <main className="narrow narrow-wide page">
      <p className="eyebrow">Blog</p>
      <h1 className="page-title">Guides for buying and selling used plugins</h1>
      <p className="lead">
        Resale rights, license transfers and how to trade safely with other musicians.
      </p>

      {posts.length === 0 ? (
        <p className="empty">No articles yet.</p>
      ) : (
        <ul className="post-list">
          {posts.map((post) => (
            <li key={post.slug}>
              <Link href={`/blog/${post.slug}`} className="post-card">
                <span className="post-meta">
                  <time dateTime={post.date}>{formatPostDate(post.date)}</time> ·{" "}
                  {post.readingMinutes} min read
                </span>
                <span className="post-card-title">{post.title}</span>
                <span className="post-card-desc">{post.description}</span>
                <span className="more-link">Read the article →</span>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}
