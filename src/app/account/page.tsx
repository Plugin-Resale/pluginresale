import type { Metadata } from "next";
import { redirect } from "next/navigation";
import Link from "next/link";
import { formatPrice, type ListingCard } from "@/lib/catalog";
import { DEAL_STATUS_LABELS, type Deal } from "@/lib/deals";
import type { Message } from "@/lib/messages";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { DeleteAccountForm } from "./DeleteAccountForm";
import { UsernameForm } from "./UsernameForm";

export const metadata: Metadata = { title: "My account" };

const STATUS_LABELS = { active: "Online", reserved: "Reserved", sold: "Sold", removed: "Removed" };

export default async function AccountPage({ searchParams }: PageProps<"/account">) {
  const { user, profile } = await getCurrentUser();
  if (!user) redirect("/signin");
  const { next } = await searchParams;

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

  // RLS returns only messages where the user is the sender or recipient.
  const { data: messages } = await supabase
    .from("messages")
    .select("*")
    .order("created_at", { ascending: false })
    .returns<Message[]>();
  const conversations = new Map<string, { listingId: number; otherId: string; last: Message }>();
  for (const m of messages ?? []) {
    const otherId = m.from_id === user.id ? m.to_id : m.from_id;
    const key = `${m.listing_id}:${otherId}`;
    if (!conversations.has(key)) conversations.set(key, { listingId: m.listing_id, otherId, last: m });
  }
  const convoListingIds = [...new Set([...conversations.values()].map((c) => c.listingId))];
  const { data: convoListings } = convoListingIds.length
    ? await supabase
        .from("listing_cards")
        .select("id, developer_name, plugin_name, seller_id")
        .in("id", convoListingIds)
    : { data: [] };
  const convoOtherIds = [...new Set([...conversations.values()].map((c) => c.otherId))];
  const { data: convoProfiles } = convoOtherIds.length
    ? await supabase.from("profiles").select("id, username").in("id", convoOtherIds)
    : { data: [] };

  return (
    <main className="narrow narrow-wide">
      <div className="card">
        <h1>My account</h1>
        <p className="muted" style={{ margin: 0 }}>
          Signed in as <strong>{user.email}</strong>
        </p>
        {!profile?.username ? (
          <p className="notice notice-success">
            Welcome! Choose a username and accept the Terms to finish setting up your account.
          </p>
        ) : (
          !profile.terms_accepted_at && (
            <p className="notice notice-success">
              We&apos;ve updated our Terms of Service. Please accept them below to keep selling
              and buying.
            </p>
          )
        )}
        <UsernameForm
          current={profile?.username ?? null}
          termsAccepted={Boolean(profile?.terms_accepted_at)}
          next={typeof next === "string" ? next : undefined}
        />
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

      <section className="card account-section">
        <h2 className="account-title">Messages</h2>
        {conversations.size > 0 ? (
          <ul className="my-listings">
            {[...conversations.values()].map(({ listingId, otherId, last }) => {
              const l = convoListings?.find((x) => x.id === listingId);
              const isSeller = l?.seller_id === user.id;
              const username = convoProfiles?.find((p) => p.id === otherId)?.username ?? "user";
              return (
                <li key={`${listingId}:${otherId}`}>
                  <Link
                    href={`/listings/${listingId}/messages${isSeller ? `?with=${otherId}` : ""}`}
                  >
                    {l ? `${l.developer_name} ${l.plugin_name}` : `Listing #${listingId}`} · @
                    {username}
                  </Link>
                  <span className="muted">{last.body.slice(0, 60)}</span>
                </li>
              );
            })}
          </ul>
        ) : (
          <p className="muted">No messages yet.</p>
        )}
      </section>

      <form action="/auth/signout" method="post" style={{ marginTop: 16, textAlign: "center" }}>
        <button className="btn" type="submit">
          Sign out
        </button>
      </form>

      <DeleteAccountForm />
    </main>
  );
}
