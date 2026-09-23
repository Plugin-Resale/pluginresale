import type { Metadata } from "next";
import { redirect } from "next/navigation";
import Link from "next/link";
import { formatPrice, type ListingCard } from "@/lib/catalog";
import { DEAL_STATUS_LABELS, type Deal } from "@/lib/deals";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { UsernameForm } from "./UsernameForm";

export const metadata: Metadata = { title: "My account" };

const STATUS_LABELS = { active: "Online", reserved: "Reserved", sold: "Sold", removed: "Removed" };

export default async function AccountPage() {
  const { user, profile } = await getCurrentUser();
  if (!user) redirect("/signin");

  const supabase = await createClient();
  const { data: listings } = await supabase
    .from("listing_cards")
    .select("*")
    .eq("seller_id", user.id)
    .order("created_at", { ascending: false })
    .returns<ListingCard[]>();

  // RLS returns only deals where the user is the buyer or the seller.
  const { data: deals } = await supabase
    .from("deals")
    .select("*")
    .order("created_at", { ascending: false })
    .returns<Deal[]>();
  const dealListingIds = [...new Set((deals ?? []).map((d) => d.listing_id))];
  const { data: dealListings } = dealListingIds.length
    ? await supabase
        .from("listing_cards")
        .select("id, developer_name, plugin_name")
        .in("id", dealListingIds)
    : { data: [] };
  const titleOf = (listingId: number) => {
    const l = dealListings?.find((x) => x.id === listingId);
    return l ? `${l.developer_name} ${l.plugin_name}` : `Listing #${listingId}`;
  };
  const purchases = (deals ?? []).filter((d) => d.buyer_id === user.id);
  const sales = (deals ?? []).filter((d) => d.seller_id === user.id);

  return (
    <main className="narrow narrow-wide">
      <div className="card">
        <h1>My account</h1>
        <p className="muted" style={{ margin: 0 }}>
          Signed in as <strong>{user.email}</strong>
        </p>
        {!profile?.username && (
          <p className="notice notice-success">
            Welcome! Choose a username to finish setting up your account.
          </p>
        )}
        <UsernameForm current={profile?.username ?? null} />
      </div>

      <section className="card account-section">
        <div className="account-section-head">
          <h2>My listings</h2>
          <Link href="/sell" className="btn btn-primary">
            Sell a plugin
          </Link>
        </div>
        {listings && listings.length > 0 ? (
          <ul className="my-listings">
            {listings.map((l) => (
              <li key={l.id}>
                <Link href={`/listings/${l.id}`}>
                  {l.developer_name} {l.plugin_name}
                </Link>
                <span className="price">{formatPrice(l.price_eur)}</span>
                <span className={`badge ${l.status === "active" ? "badge-ok" : "badge-muted"}`}>
                  {STATUS_LABELS[l.status]}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <p className="muted">You haven&apos;t listed anything yet.</p>
        )}
      </section>

      {[
        { title: "My sales", items: sales, empty: "No sales yet." },
        { title: "My purchases", items: purchases, empty: "No purchases yet." },
      ].map((section) => (
        <section key={section.title} className="card account-section">
          <h2 className="account-title">{section.title}</h2>
          {section.items.length > 0 ? (
            <ul className="my-listings">
              {section.items.map((d) => (
                <li key={d.id}>
                  <Link href={`/deals/${d.id}`}>{titleOf(d.listing_id)}</Link>
                  <span className="price">{formatPrice(d.price_eur)}</span>
                  <span
                    className={`badge ${
                      d.status === "requested" || d.status === "paid" ? "badge-ok" : "badge-muted"
                    }`}
                  >
                    {DEAL_STATUS_LABELS[d.status]}
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="muted">{section.empty}</p>
          )}
        </section>
      ))}

      <form action="/auth/signout" method="post" style={{ marginTop: 16, textAlign: "center" }}>
        <button className="btn" type="submit">
          Sign out
        </button>
      </form>
    </main>
  );
}
