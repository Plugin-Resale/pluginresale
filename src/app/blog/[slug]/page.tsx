import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { formatPostDate, getPost } from "@/lib/blog";

export async function generateMetadata({ params }: PageProps<"/blog/[slug]">): Promise<Metadata> {
  const post = await getPost((await params).slug);
  if (!post) return {};
  return {
    title: post.title,
    description: post.description,
    alternates: { canonical: `/blog/${post.slug}` },
    openGraph: {
      type: "article",
      title: post.title,
      description: post.description,
      url: `/blog/${post.slug}`,
      siteName: "Plugin Resale",
      publishedTime: post.date,
      modifiedTime: post.updated ?? post.date,
    },
  };
}

export default async function BlogPostPage({ params }: PageProps<"/blog/[slug]">) {
  const post = await getPost((await params).slug);
  if (!post) notFound();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    headline: post.title,
    description: post.description,
    datePublished: post.date,
    dateModified: post.updated ?? post.date,
    mainEntityOfPage: `https://www.pluginresale.com/blog/${post.slug}`,
    ...(post.image && { image: `https://www.pluginresale.com${post.image}` }),
    author: { "@type": "Organization", name: "Plugin Resale", url: "https://www.pluginresale.com" },
    publisher: { "@type": "Organization", name: "Plugin Resale", url: "https://www.pluginresale.com" },
  };

  return (
    <main className="narrow narrow-wide page blog-page">
      <nav aria-label="Breadcrumb" className="breadcrumb">
        <Link href="/blog">Blog</Link>
      </nav>

      <article className="post">
        <h1 className="page-title">{post.title}</h1>
        <p className="post-meta">
          <time dateTime={post.date}>{formatPostDate(post.date)}</time>
          {post.updated && post.updated !== post.date && (
            <>
              {" "}
              · Updated <time dateTime={post.updated}>{formatPostDate(post.updated)}</time>
            </>
          )}{" "}
          · {post.readingMinutes} min read
        </p>
        {/* Post HTML is rendered from our own Markdown files in content/blog, never user input. */}
        <div className="post-body" dangerouslySetInnerHTML={{ __html: post.html }} />
      </article>

      <aside className="post-cta card">
        <h2 className="section-title">Got a plugin you no longer use?</h2>
        <p>
          List it for free on Plugin Resale: no fees, no commission, and the developer&apos;s
          transfer rules shown right next to your listing.
        </p>
        <Link href="/sell" className="btn btn-primary">
          Sell a plugin
        </Link>{" "}
        <Link href="/browse" className="btn">
          Browse listings
        </Link>
      </aside>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }}
      />
    </main>
  );
}
