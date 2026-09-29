import type { Metadata } from "next";
import Link from "next/link";
import { cache } from "react";
import { notFound } from "next/navigation";
import { TransferRules } from "@/components/TransferRules";
import { getPostsForDeveloper } from "@/lib/blog";
import { CATEGORIES, DEVELOPER_COLUMNS, type Developer, type Plugin } from "@/lib/catalog";
import { developerDescription, developerFaq } from "@/lib/developer-faq";
import { createClient } from "@/lib/supabase/server";

// generateMetadata and the page both need it: one database query per request, not two.
const getDeveloper = cache(async (slug: string) => {
  const supabase = await createClient();
  const { data } = await supabase
    .from("developers")
    .select(DEVELOPER_COLUMNS)
    .eq("slug", slug)
    .maybeSingle<Developer>();
  return data;
});

export async function generateMetadata({
  params,
}: PageProps<"/developers/[slug]">): Promise<Metadata> {
  const developer = await getDeveloper((await params).slug);
  if (!developer) return {};
  const title = `${developer.name} License Transfer: Rules, Fees & How to Resell`;
  const description = developerDescription(developer);
  return {
    title: { absolute: `${title} | Plugin Resale` },
    description,
    alternates: { canonical: `/developers/${developer.slug}` },
    openGraph: {
      type: "website",
      siteName: "Plugin Resale",
      title,
      description,
      url: `/developers/${developer.slug}`,
    },
  };
}

export default async function DeveloperPage({ params }: PageProps<"/developers/[slug]">) {
  const developer = await getDeveloper((await params).slug);
  if (!developer) notFound();

  const supabase = await createClient();

  const [{ count: listingCount }, posts] = await Promise.all([
    supabase
      .from("listing_cards")
      .select("id", { count: "exact", head: true })
      .eq("developer_slug", developer.slug)
      .eq("status", "active"),
    getPostsForDeveloper(developer.slug),
  ]);
  const faq = developerFaq(developer);
  const faqJsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faq.map(({ question, answer }) => ({
      "@type": "Question",
      name: question,
      acceptedAnswer: { "@type": "Answer", text: answer },
    })),
  };

  // A single select caps out at 1,000 rows: some developers (Native Instruments, Toontrack,
  // 8dio...) have more plugins than that, so page through until a batch comes back short.
  const PAGE_SIZE = 1000;
  const plugins: Plugin[] = [];
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data: page, error } = await supabase
      .from("plugins")
      .select("id, developer_id, name, slug, category")
      .eq("developer_id", developer.id)
      .order("name")
      .range(from, from + PAGE_SIZE - 1)
      .returns<Plugin[]>();
    if (error) throw error;
    plugins.push(...page);
    if (page.length < PAGE_SIZE) break;
  }

  return (
    <main className="container page">
      <nav aria-label="Breadcrumb" className="breadcrumb">
        <Link href="/developers">Developers</Link>
        <span aria-hidden="true">/</span>
        <span>{developer.name}</span>
      </nav>
      <h1 className="page-title">How to transfer a {developer.name} license</h1>
      {developer.website && (
        <p className="lead">
          <a href={developer.website} target="_blank" rel="noopener noreferrer">
            {developer.website.replace(/^https?:\/\//, "")}
          </a>
        </p>
      )}

      <div className="dev-layout">
        <div className="dev-main">
          <TransferRules developer={developer} />

          <ul className="dev-links">
            {developer.transferable !== false &&
              (listingCount ? (
                <li>
                  <Link href={`/browse?dev=${developer.slug}`}>
                    {listingCount} used {developer.name}{" "}
                    {listingCount === 1 ? "license" : "licenses"} for sale
                  </Link>
                </li>
              ) : (
                <li>
                  No used {developer.name} license for sale right now.{" "}
                  <Link href="/sell">Sell yours for free</Link>
                </li>
              ))}
            {posts.map((post) => (
              <li key={post.slug}>
                Guide: <Link href={`/blog/${post.slug}`}>{post.title}</Link>
              </li>
            ))}
          </ul>

          <section className="dev-faq">
            <h2 className="section-title">{developer.name} license transfer FAQ</h2>
            {faq.map(({ question, answer }) => (
              <div key={question}>
                <h3>{question}</h3>
                <p>{answer}</p>
              </div>
            ))}
          </section>
        </div>

        {plugins && plugins.length > 0 && (
          <section>
            <h2 className="section-title">Plugins</h2>
            <ul className="plugin-list">
              {plugins.map((plugin) => (
                <li key={plugin.id}>
                  <Link href={`/developers/${developer.slug}/${plugin.slug}`}>{plugin.name}</Link>
                  <span className="muted">{CATEGORIES[plugin.category]}</span>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd).replace(/</g, "\\u003c") }}
      />
    </main>
  );
}
