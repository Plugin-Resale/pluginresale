import type { Metadata } from "next";
import { redirect } from "next/navigation";
import Link from "next/link";
import { formatPrice, type ListingCard } from "@/lib/catalog";
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

      <form action="/auth/signout" method="post" style={{ marginTop: 16, textAlign: "center" }}>
        <button className="btn" type="submit">
          Sign out
        </button>
      </form>
    </main>
  );
}
