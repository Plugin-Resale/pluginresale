import type { Metadata } from "next";
import { signInUrl } from "@/lib/next-path";
import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import type { ReactNode } from "react";
import type { Message } from "@/lib/messages";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { sendMessage } from "./actions";

export const metadata: Metadata = { title: "Messages", robots: { index: false } };

export default async function ListingMessagesPage({
  params,
  searchParams,
}: PageProps<"/listings/[id]/messages">) {
  const { user } = await getCurrentUser();
  const { id: rawId } = await params;
  if (!user) redirect(signInUrl(`/listings/${rawId}/messages`));

  const id = Number(rawId);
  if (!Number.isInteger(id)) notFound();
  const { with: withParam, error: sendError } = await searchParams;

  const SEND_ERROR_MESSAGES: Record<string, ReactNode> = {
    username: (
      <>
        Choose a username in <Link href={`/account?next=/listings/${id}/messages`}>My account</Link>{" "}
        before messaging.
      </>
    ),
    empty: "Your message was empty.",
    unknown: "Something went wrong sending your message. Please try again.",
  };

  const supabase = await createClient();
  const { data: listing } = await supabase
    .from("listing_cards")
    .select("id, seller_id, seller_username, developer_name, plugin_name")
    .eq("id", id)
    .maybeSingle();
  if (!listing) notFound();

  const isSeller = listing.seller_id === user.id;
  const title = `${listing.developer_name} ${listing.plugin_name}`;
  const breadcrumb = (
    <nav aria-label="Breadcrumb" className="breadcrumb">
      <Link href="/account">My account</Link>
      <span aria-hidden="true">/</span>
      <Link href={`/listings/${id}`}>{title}</Link>
      <span aria-hidden="true">/</span>
      <span>Messages</span>
    </nav>
  );

  // Seller with no buyer picked: list who has messaged about this listing.
  if (isSeller && typeof withParam !== "string") {
    const { data: all } = await supabase
      .from("messages")
      .select("*")
      .eq("listing_id", id)
      .order("created_at", { ascending: false })
      .returns<Message[]>();

    const lastByBuyer = new Map<string, Message>();
    for (const m of all ?? []) {
      const buyerId = m.from_id === user.id ? m.to_id : m.from_id;
      if (!lastByBuyer.has(buyerId)) lastByBuyer.set(buyerId, m);
    }
    const buyerIds = [...lastByBuyer.keys()];
    const { data: profiles } = buyerIds.length
      ? await supabase.from("profiles").select("id, username").in("id", buyerIds)
      : { data: [] };
    const usernameOf = (buyerId: string) =>
      profiles?.find((p) => p.id === buyerId)?.username ?? "buyer";

    return (
      <main className="container page">
        {breadcrumb}
        <h1 className="page-title">Messages · {title}</h1>
        {lastByBuyer.size > 0 ? (
          <ul className="my-listings">
            {[...lastByBuyer.entries()].map(([buyerId, last]) => (
              <li key={buyerId}>
                <Link href={`/listings/${id}/messages?with=${buyerId}`}>
                  @{usernameOf(buyerId)}
                </Link>
                <span className="muted">{last.body.slice(0, 60)}</span>
              </li>
            ))}
          </ul>
        ) : (
          <p className="muted">No one has messaged you about this listing yet.</p>
        )}
      </main>
    );
  }

  const otherId = isSeller ? String(withParam) : listing.seller_id;
  const { data: messages } = await supabase
    .from("messages")
    .select("*")
    .eq("listing_id", id)
    .or(`from_id.eq.${otherId},to_id.eq.${otherId}`)
    .order("created_at", { ascending: true })
    .returns<Message[]>();

  if (isSeller && (!messages || messages.length === 0)) notFound();

  const otherUsername = isSeller
    ? (await supabase.from("profiles").select("username").eq("id", otherId).maybeSingle()).data
        ?.username
    : listing.seller_username;

  return (
    <main className="container page">
      {breadcrumb}
      {typeof sendError === "string" && SEND_ERROR_MESSAGES[sendError] && (
        <p className="notice notice-error">{SEND_ERROR_MESSAGES[sendError]}</p>
      )}
      <h1 className="page-title">
        {isSeller ? `Conversation with @${otherUsername ?? "buyer"}` : `Message @${otherUsername}`}
      </h1>

      <div className="card message-thread">
        {messages && messages.length > 0 ? (
          <ul className="message-list">
            {messages.map((m) => (
              <li key={m.id} className={m.from_id === user.id ? "mine" : ""}>
                <p>{m.body}</p>
                <time dateTime={m.created_at}>{new Date(m.created_at).toLocaleString()}</time>
              </li>
            ))}
          </ul>
        ) : (
          <p className="muted">No messages yet. Say hello!</p>
        )}
      </div>

      <form action={sendMessage} className="card message-form">
        <input type="hidden" name="listing_id" value={id} />
        <input type="hidden" name="to_id" value={otherId} />
        <textarea
          className="input textarea"
          name="body"
          rows={3}
          required
          maxLength={2000}
          placeholder="Write a message…"
        />
        <button className="btn btn-primary" type="submit">
          Send
        </button>
      </form>
    </main>
  );
}
