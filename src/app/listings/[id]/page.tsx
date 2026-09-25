import type { Metadata } from "next";
import { signInUrl } from "@/lib/next-path";
import Link from "next/link";
import { cache } from "react";
import { notFound } from "next/navigation";
import { ListingGrid } from "@/components/ListingCard";
import { Rating } from "@/components/Rating";
import { ShareButton } from "@/components/ShareButton";
import { TransferRules } from "@/components/TransferRules";
import {
  CATEGORIES,
  DEVELOPER_COLUMNS,
  formatDate,
  formatPrice,
  type Developer,
  type ListingCard,
} from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { setListingStatus } from "../../account/actions";
import { startDeal } from "../../deals/actions";

const BUY_ERRORS: Record<string, string> = {
  unavailable: "Someone just reserved this license. It may come back if their purchase is cancelled.",
  own: "This is your own listing.",
  unknown: "Something went wrong. Please try again.",
};

// generateMetadata and the page both need it: one database query per request, not two.
const getListing = cache(async (rawId: string) => {
  const id = Number(rawId);
  if (!Number.isInteger(id) || id <= 0) return null;
  const supabase = await createClient();
  const { data } = await supabase
    .from("listing_cards")
    .select("*")
    .eq("id", id)
    .maybeSingle<ListingCard>();
  return data;
});

export async function generateMetadata({ params }: PageProps<"/listings/[id]">): Promise<Metadata> {
  const listing = await getListing((await params).id);
  if (!listing) return {};
  const title = `${listing.developer_name} ${listing.plugin_name} for ${formatPrice(listing.price_eur)}`;
  const description = `Second-hand ${listing.developer_name} ${listing.plugin_name} license, sold by @${listing.seller_username}.`;
  return {
    title,
    description,
    alternates: { canonical: `/listings/${listing.id}` },
    openGraph: {
      type: "website",
      siteName: "Plugin Resale",
      title,
      description,
      url: `/listings/${listing.id}`,
    },
  };
}

export default async function ListingPage({
  params,
  searchParams,
}: PageProps<"/listings/[id]">) {
  const listing = await getListing((await params).id);
  if (!listing) notFound();
  const { published, error: buyError } = await searchParams;

  const supabase = await createClient();
  const [{ user }, { data: developer }, { data: more }] = await Promise.all([
    getCurrentUser(),
    supabase
      .from("developers")
      .select(DEVELOPER_COLUMNS)
      .eq("id", listing.developer_id)
      .single<Developer>(),
    supabase
      .from("listing_cards")
      .select("*")
      .eq("developer_id", listing.developer_id)
      .eq("status", "active")
      .neq("id", listing.id)
      .order("created_at", { ascending: false })
      .limit(4)
      .returns<ListingCard[]>(),
  ]);

  const isSeller = user?.id === listing.seller_id;
  const url = `https://www.pluginresale.com/listings/${listing.id}`;
  const title = `${listing.developer_name} ${listing.plugin_name}`;
  const price = formatPrice(listing.price_eur);
  const share = {
    url,
    title: `${title} for ${price}`,
    text: isSeller
      ? `I'm selling my ${title} license for ${price} on Plugin Resale`
      : `${title}, used license for ${price} on Plugin Resale`,
  };

  // Lets Google show the price and availability under the link in search results.
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: title,
    description:
      listing.description || `Second-hand ${title} license, sold by a private seller.`,
    image: `${url}/opengraph-image`,
    brand: { "@type": "Brand", name: listing.developer_name },
    category: CATEGORIES[listing.category],
    offers: {
      "@type": "Offer",
      url,
      price: Number(listing.price_eur).toFixed(2),
      priceCurrency: "EUR",
      itemCondition: "https://schema.org/UsedCondition",
      availability:
        listing.status === "active"
          ? "https://schema.org/InStock"
          : listing.status === "sold"
            ? "https://schema.org/SoldOut"
            : "https://schema.org/OutOfStock",
      seller: { "@type": "Person", name: listing.seller_username },
    },
  };
  const { data: myDeal } = user
    ? await supabase
        .from("deals")
        .select("id")
        .eq("listing_id", listing.id)
        .eq("buyer_id", user.id)
        .in("status", ["requested", "paid"])
        .maybeSingle()
    : { data: null };

  return (
    <main className="container page">
      <nav aria-label="Breadcrumb" className="breadcrumb">
        <Link href="/browse">Browse</Link>
        <span aria-hidden="true">/</span>
        <Link href={`/browse?cat=${listing.category}`}>{CATEGORIES[listing.category]}</Link>
        <span aria-hidden="true">/</span>
        <span>
          {listing.developer_name} {listing.plugin_name}
        </span>
      </nav>

      {published && isSeller && listing.status === "active" && (
        <div className="notice notice-success share-notice">
          <p>
            <strong>Your listing is live.</strong> Share it where producers hang out (Instagram,
            WhatsApp, Facebook groups, Discord…) to sell faster.
          </p>
          <ShareButton {...share} label="Share my listing" className="btn btn-primary" />
        </div>
      )}
      {listing.status !== "active" && (
        <p className="notice notice-error">
          {listing.status === "removed"
            ? "This listing was removed and is only visible to you."
            : listing.status === "reserved"
              ? "This license is reserved: a buyer is completing the purchase."
              : "This license has been sold."}
        </p>
      )}

      <div className="listing-layout">
        <div className="listing-main">
          <div className="listing-hero">
            <span className="listing-dev">
              {listing.developer_name} · {CATEGORIES[listing.category]}
            </span>
            <div>
              <h1>{listing.plugin_name}</h1>
              <div className="tags">
                {listing.version && <span className="tag">v{listing.version}</span>}
                {listing.formats.map((f) => (
                  <span key={f} className="tag">
                    {f}
                  </span>
                ))}
              </div>
            </div>
          </div>

          <section className="listing-note">
            <h2 className="section-title">Seller&apos;s note</h2>
            <p className="seller-note">
              {listing.description || "The seller didn't add a description."}
            </p>
          </section>

          {developer && <TransferRules developer={developer} />}

          {more && more.length > 0 && (
            <section className="listing-more">
              <h2 className="section-title">More from {listing.developer_name}</h2>
              <ListingGrid listings={more} />
            </section>
          )}
        </div>

        <aside className="listing-side">
          <div className="card price-card">
            <span className="price price-lg">{formatPrice(listing.price_eur)}</span>
            <span className="muted listing-id">Listing #{listing.id}</span>
            {buyError === "username" && (
              <p className="notice notice-error">
                Choose a username in{" "}
                <Link href={`/account?next=/listings/${listing.id}`}>My account</Link> before
                buying.
              </p>
            )}
            {typeof buyError === "string" && BUY_ERRORS[buyError] && (
              <p className="notice notice-error">{BUY_ERRORS[buyError]}</p>
            )}
            {isSeller && listing.status === "active" && (
              <ShareButton {...share} label="Share my listing" className="btn btn-primary btn-lg" />
            )}
            {isSeller ? (
              <form action={setListingStatus}>
                <input type="hidden" name="id" value={listing.id} />
                {listing.status === "active" && (
                  <button className="btn btn-block" name="status" value="removed">
                    Remove listing
                  </button>
                )}
                {listing.status === "removed" && (
                  <button className="btn btn-primary btn-block" name="status" value="active">
                    Put back online
                  </button>
                )}
              </form>
            ) : myDeal ? (
              <Link href={`/deals/${myDeal.id}`} className="btn btn-primary btn-lg">
                Go to your purchase
              </Link>
            ) : listing.status === "active" ? (
              <>
                {user ? (
                  <form action={startDeal} className="buy-form">
                    <input type="hidden" name="listing_id" value={listing.id} />
                    <button className="btn btn-primary btn-lg btn-block" type="submit">
                      Buy with PayPal
                    </button>
                  </form>
                ) : (
                  <Link href={signInUrl(`/listings/${listing.id}`)} className="btn btn-primary btn-lg">
                    Sign in to buy
                  </Link>
                )}
                <Link
                  href={user ? `/listings/${listing.id}/messages` : signInUrl(`/listings/${listing.id}/messages`)}
                  className="btn btn-lg"
                >
                  Message seller
                </Link>
                <p className="hint">
                  Buying reserves the license for you and shows you the seller&apos;s PayPal
                  details.
                </p>
              </>
            ) : null}
            <p className="hint">
              You pay the seller directly with PayPal Goods &amp; Services, which may be covered by
              PayPal Buyer Protection under PayPal&apos;s own terms. Plugin Resale never holds your
              money.
            </p>
            <p className="private-seller">
              <strong>Private seller.</strong> The EU consumer rights that apply when buying from
              a business (14-day withdrawal, legal guarantee) don&apos;t apply to this sale.
            </p>
          </div>

          <Link href={`/u/${listing.seller_username}`} className="card seller-card">
            <span className="avatar" aria-hidden="true">
              {listing.seller_username?.[0]?.toUpperCase()}
            </span>
            <div>
              <strong>@{listing.seller_username}</strong>
              <p className="muted">Member since {formatDate(listing.seller_since.slice(0, 10))}</p>
              <p className="muted">
                <Rating avg={listing.seller_avg_rating} count={listing.seller_review_count} />
              </p>
            </div>
          </Link>

          {!isSeller && listing.status === "active" && (
            <ShareButton {...share} label="Share this listing" className="share-link" />
          )}
          <Link className="report-link" href={`/report?listing=${listing.id}`}>
            Report this listing
          </Link>
        </aside>
      </div>

      {listing.status !== "removed" && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }}
        />
      )}
    </main>
  );
}
