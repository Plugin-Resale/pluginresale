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
  return {
    title: `${developer.name} license transfer rules`,
    description: developer.transferable
      ? `How to transfer a ${developer.name} license: fee, who pays, process and restrictions.`
      : `${developer.name} licenses can't be transferred to another user.`,
  };
}

export default async function DeveloperPage({ params }: PageProps<"/developers/[slug]">) {
  const developer = await getDeveloper((await params).slug);
  if (!developer) notFound();

  const supabase = await createClient();
  const { data: plugins } = await supabase
    .from("plugins")
    .select("id, developer_id, name, slug, category")
    .eq("developer_id", developer.id)
    .order("name")
    .returns<Plugin[]>();

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
