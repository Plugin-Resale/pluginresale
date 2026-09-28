import type { Metadata } from "next";
import Link from "next/link";
import { cache } from "react";
import { notFound } from "next/navigation";
import { BuyNew } from "@/components/BuyNew";
import { ListingGrid } from "@/components/ListingCard";
import { TransferRules } from "@/components/TransferRules";
import {
  CATEGORIES,
  DEVELOPER_COLUMNS,
  type Developer,
  type ListingCard,
  type Plugin,
  type ShopLinks,
} from "@/lib/catalog";
import { pluginImageUrl } from "@/lib/images";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { createAlert } from "../../../browse/actions";

type PluginRow = Plugin & ShopLinks & { image_path: string | null };

// generateMetadata and the page both need it: one pair of queries per request, not two.
const getPlugin = cache(async (developerSlug: string, pluginSlug: string) => {
  const supabase = await createClient();
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
  const name = `${developer.name} ${plugin.name}`;
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

export default async function PluginPage({
  params,
  searchParams,
}: PageProps<"/developers/[slug]/[plugin]">) {
  const { slug, plugin: pluginSlug } = await params;
  const found = await getPlugin(slug, pluginSlug);
  if (!found) notFound();
  const { developer, plugin } = found;
  const { alert: alertNotice } = await searchParams;

  const path = `/developers/${developer.slug}/${plugin.slug}`;
  const name = `${developer.name} ${plugin.name}`;
  const blocked = developer.transferable === false;

  const supabase = await createClient();
  const [{ data: listings }, { user }] = await Promise.all([
    blocked
      ? Promise.resolve({ data: [] as ListingCard[] })
      : supabase
          .from("listing_cards")
          .select("*")
          .eq("plugin_id", plugin.id)
          .eq("status", "active")
          .order("created_at", { ascending: false })
          .returns<ListingCard[]>(),
    getCurrentUser(),
  ]);
  const { data: alert } =
    user && !blocked
      ? await supabase
          .from("listing_alerts")
          .select("plugin_id")
          .eq("plugin_id", plugin.id)
          .maybeSingle()
      : { data: null };

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
            {alertNotice === "set" && (
              <p className="notice notice-success">
                Alert set. We&apos;ll email you as soon as someone lists it. Manage your alerts in{" "}
                <Link href="/account#alerts">My account</Link>.
              </p>
            )}
            {alertNotice === "error" && (
              <p className="notice notice-error">Something went wrong. Please try again.</p>
            )}
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
                  {alert ? (
                    <span className="badge badge-ok">✓ Alert set</span>
                  ) : (
                    // Signed out: createAlert sends them to sign in first, then back here.
                    <form action={createAlert}>
                      <input type="hidden" name="plugin_id" value={plugin.id} />
                      <input type="hidden" name="back" value={path} />
                      <button className="btn btn-primary" type="submit">
                        Alert me
                      </button>
                    </form>
                  )}
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
