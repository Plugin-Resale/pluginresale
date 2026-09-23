import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ListingGrid } from "@/components/ListingCard";
import { Rating } from "@/components/Rating";
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
  username: "Choose a username in My account before buying.",
  unavailable: "Someone just reserved this license. It may come back if their purchase is cancelled.",
  own: "This is your own listing.",
  unknown: "Something went wrong. Please try again.",
};

async function getListing(rawId: string) {
  const id = Number(rawId);
  if (!Number.isInteger(id) || id <= 0) return null;
  const supabase = await createClient();
  const { data } = await supabase
    .from("listing_cards")
    .select("*")
    .eq("id", id)
    .maybeSingle<ListingCard>();
  return data;
}

export async function generateMetadata({ params }: PageProps<"/listings/[id]">): Promise<Metadata> {
  const listing = await getListing((await params).id);
  if (!listing) return {};
  return {
    title: `${listing.developer_name} ${listing.plugin_name} for ${formatPrice(listing.price_eur)}`,
    description: `Second-hand ${listing.developer_name} ${listing.plugin_name} license, sold by @${listing.seller_username}.`,
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
  const { data: myDeal } = user
    ? await supabase
        .from("deals")
        .select("id")
        .eq("listing_id", listing.id)
        .eq("buyer_id", user.id)
        .in("status", ["requested", "paid"])
        .maybeSingle()
    : { data: null };
  const reportSubject = encodeURIComponent(`Report listing #${listing.id}`);

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

      {published && isSeller && (
        <p className="notice notice-success">
          Your listing is live. Buyers can now find it in Browse.
        </p>
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

          <section>
            <h2 className="section-title">Seller&apos;s note</h2>
            <p className="seller-note">
              {listing.description || "The seller didn't add a description."}
            </p>
          </section>

          {developer && <TransferRules developer={developer} />}

          {more && more.length > 0 && (
            <section>
              <h2 className="section-title">More from {listing.developer_name}</h2>
              <ListingGrid listings={more} />
            </section>
          )}
        </div>

        <aside className="listing-side">
          <div className="card price-card">
            <span className="price price-lg">{formatPrice(listing.price_eur)}</span>
            <span className="muted listing-id">Listing #{listing.id}</span>
            {typeof buyError === "string" && BUY_ERRORS[buyError] && (
              <p className="notice notice-error">{BUY_ERRORS[buyError]}</p>
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
                  <Link href="/signin" className="btn btn-primary btn-lg">
                    Sign in to buy
                  </Link>
                )}
                <Link
                  href={user ? `/listings/${listing.id}/messages` : "/signin"}
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
              You pay the seller directly with PayPal Goods &amp; Services, which gives you PayPal
              Buyer Protection. Plugin Resale never holds your money.
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

          <a
            className="report-link"
            href={`mailto:contact@pluginresale.com?subject=${reportSubject}`}
          >
            Report this listing
          </a>
        </aside>
      </div>
    </main>
  );
}
