import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { TransferRules } from "@/components/TransferRules";
import { CATEGORIES, DEVELOPER_COLUMNS, type Developer, type Plugin } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";

async function getDeveloper(slug: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("developers")
    .select(DEVELOPER_COLUMNS)
    .eq("slug", slug)
    .maybeSingle<Developer>();
  return data;
}

export async function generateMetadata({
  params,
}: PageProps<"/developers/[slug]">): Promise<Metadata> {
  const developer = await getDeveloper((await params).slug);
  if (!developer) return {};
  const title = `${developer.name} license transfer rules`;
  const description =
    developer.transferable === null
      ? `${developer.name} license transfers: no official policy found yet, check with the developer.`
      : developer.transferable
        ? `How to transfer a ${developer.name} license: fee, who pays, process and restrictions.`
        : `${developer.name} licenses can't be transferred to another user.`;
  return {
    title,
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
      <h1 className="page-title">{developer.name}</h1>
      {developer.website && (
        <p className="lead">
          <a href={developer.website} target="_blank" rel="noopener noreferrer">
            {developer.website.replace(/^https?:\/\//, "")}
          </a>
        </p>
      )}

      <div className="dev-layout">
        <TransferRules developer={developer} />

        {plugins && plugins.length > 0 && (
          <section>
            <h2 className="section-title">Plugins</h2>
            <ul className="plugin-list">
              {plugins.map((plugin) => (
                <li key={plugin.id}>
                  <span>{plugin.name}</span>
                  <span className="muted">{CATEGORIES[plugin.category]}</span>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </main>
  );
}
