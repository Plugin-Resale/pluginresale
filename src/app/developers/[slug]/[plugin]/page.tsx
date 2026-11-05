import type { Metadata } from "next";
import Link from "@/components/Link";
import { Suspense, cache } from "react";
import { notFound } from "next/navigation";
import { BuyNew } from "@/components/BuyNew";
import { ListingGrid } from "@/components/ListingCard";
import { TransferRules } from "@/components/TransferRules";
import {
  CATEGORIES,
  DEVELOPER_COLUMNS,
  productName,
  type Developer,
  type ListingCard,
  type Plugin,
  type ShopLinks,
} from "@/lib/catalog";
import { pluginImageUrl } from "@/lib/images";
import { createAnonClient } from "@/lib/supabase/anon";
import { AlertButton, AlertNotice } from "./AlertActions";

// Rendered once and served from the CDN for 10 minutes: this is the most crawled page type
// (~3,700 URLs). Only the alert notice and the "Alert set" state depend on the visitor, and
// AlertActions resolves those in the browser. A new listing shows up within 10 minutes.
export const revalidate = 600;

// Nothing is prerendered at build time: each one is rendered on first request, then cached for
// `revalidate` seconds. Without this export a dynamic route is never cached at all.
export function generateStaticParams() {
  return [];
}

type PluginRow = Plugin & ShopLinks & { image_path: string | null };

// generateMetadata and the page both need it: one pair of queries per request, not two.
const getPlugin = cache(async (developerSlug: string, pluginSlug: string) => {
  const supabase = createAnonClient();
  const { data: developer } = await supabase
    .from("developers")
    .select(DEVELOPER_COLUMNS)
    .eq("slug", developerSlug)
    .maybeSingle<Developer>();
  if (!developer) return null;
  const { data: plugin } = await supabase
    .from("plugins")
    .select("id, developer_id, name, slug, category, image_path, thomann_url, pluginboutique_url")
    .eq("developer_id", developer.id)
    .eq("slug", pluginSlug)
    .maybeSingle<PluginRow>();
  return plugin ? { developer, plugin } : null;
});

export async function generateMetadata({
  params,
}: PageProps<"/developers/[slug]/[plugin]">): Promise<Metadata> {
  const { slug, plugin: pluginSlug } = await params;
  const found = await getPlugin(slug, pluginSlug);
  if (!found) return {};
  const { developer, plugin } = found;
  const name = productName(developer.name, plugin.name);
  const title =
    developer.transferable === false ? `${name} license transfer` : `Used ${name} licenses`;
  const description =
    developer.transferable === false
      ? `${developer.name} doesn't allow license transfers, so ${plugin.name} can't be resold.`
      : `Buy a second-hand ${name} license from another producer, or sell yours. Free, no commission.`;
  const url = `/developers/${developer.slug}/${plugin.slug}`;
  return {
    title,
    description,
    alternates: { canonical: url },
    openGraph: { type: "website", siteName: "Plugin Resale", title, description, url },
  };
}

export default async function PluginPage({ params }: PageProps<"/developers/[slug]/[plugin]">) {
  const { slug, plugin: pluginSlug } = await params;
  const found = await getPlugin(slug, pluginSlug);
  if (!found) notFound();
  const { developer, plugin } = found;

  const path = `/developers/${developer.slug}/${plugin.slug}`;
  const name = productName(developer.name, plugin.name);
  const blocked = developer.transferable === false;

  const { data: listings } = blocked
    ? { data: [] as ListingCard[] }
    : await createAnonClient()
        .from("listing_cards")
        .select("*")
        .eq("plugin_id", plugin.id)
        .eq("status", "active")
        .order("created_at", { ascending: false })
        .returns<ListingCard[]>();

  const buyNew = <BuyNew links={plugin} placement="plugin" />;

  return (
    <main className="container page plugin-page">
      <nav aria-label="Breadcrumb" className="breadcrumb">
        <Link href="/developers">Developers</Link>
        <span aria-hidden="true">/</span>
        <Link href={`/developers/${developer.slug}`}>{developer.name}</Link>
        <span aria-hidden="true">/</span>
        <span>{plugin.name}</span>
      </nav>

      <div className="listing-hero">
        <div className="listing-hero-text">
          <span className="listing-dev">
            {developer.name} · {CATEGORIES[plugin.category]}
          </span>
          <h1>{plugin.name}</h1>
        </div>
        {plugin.image_path && (
          <div className="listing-hero-visual">
            {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
            <img src={pluginImageUrl(plugin.image_path)} alt={name} />
          </div>
        )}
      </div>

      {blocked ? (
        <>
          <p className="notice notice-error">
            {developer.name} doesn&apos;t allow license transfers, so {plugin.name} can&apos;t be
            resold here.
          </p>
          {buyNew}
          <TransferRules developer={developer} />
        </>
      ) : (
        <>
          <section>
            <h2 className="section-title">Used licenses for sale</h2>
            <Suspense>
              <AlertNotice />
            </Suspense>
            {listings && listings.length > 0 ? (
              <>
                <ListingGrid listings={listings} />
                <p className="hint">
                  Own one too? <Link href={`/sell?plugin=${plugin.id}`}>Sell yours</Link>, it&apos;s
                  free.
                </p>
              </>
            ) : (
              <div className="empty card">
                <p>
                  <strong>No one is selling {plugin.name} right now.</strong>
                </p>
                <p className="muted">Get an email as soon as someone lists it:</p>
                <div className="alert-actions">
                  <AlertButton pluginId={plugin.id} back={path} />
                  <Link href={`/sell?plugin=${plugin.id}`} className="btn">
                    I own it, sell it
                  </Link>
                </div>
              </div>
            )}
          </section>
          <TransferRules developer={developer} />
          {buyNew}
        </>
      )}
    </main>
  );
}
