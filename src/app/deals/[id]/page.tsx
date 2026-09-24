import type { Metadata } from "next";
import { signInUrl } from "@/lib/next-path";
import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { TransferRules } from "@/components/TransferRules";
import {
  DEVELOPER_COLUMNS,
  formatPrice,
  type Developer,
  type ListingCard,
} from "@/lib/catalog";
import type { Deal } from "@/lib/deals";
import type { Review } from "@/lib/reviews";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { addReview, advanceDeal } from "../actions";

export const metadata: Metadata = { title: "Purchase", robots: { index: false } };

const STEPS = ["Reserved", "Payment sent", "Payment received", "License received"];

function stepIndex(deal: Deal) {
  if (deal.status === "completed") return 4;
  if (deal.status === "paid") return 3;
  return 1;
}

function StepButton({ deal, step, label, primary = false }: {
  deal: Deal;
  step: "paid" | "completed" | "cancel";
  label: string;
  primary?: boolean;
}) {
  return (
    <form action={advanceDeal}>
      <input type="hidden" name="deal_id" value={deal.id} />
      <input type="hidden" name="step" value={step} />
      <button className={`btn btn-block ${primary ? "btn-primary btn-lg" : ""}`} type="submit">
        {label}
      </button>
    </form>
  );
}

export default async function DealPage({ params, searchParams }: PageProps<"/deals/[id]">) {
  const { user } = await getCurrentUser();
  const { id: rawId } = await params;
  if (!user) redirect(signInUrl(`/deals/${rawId}`));

  const id = Number(rawId);
  if (!Number.isInteger(id)) notFound();
  const { error: actionError } = await searchParams;

  const supabase = await createClient();
  // RLS: only the buyer and the seller can read the deal.
  const { data: deal } = await supabase.from("deals").select("*").eq("id", id).maybeSingle<Deal>();
  if (!deal) notFound();

  const isBuyer = deal.buyer_id === user.id;
  const [{ data: listing }, { data: buyer }, { data: privateInfo }] = await Promise.all([
    supabase.from("listing_cards").select("*").eq("id", deal.listing_id).single<ListingCard>(),
    supabase.from("profiles").select("username").eq("id", deal.buyer_id).single(),
    // RLS: visible to the seller, and to the buyer while the deal is open.
    supabase
      .from("listing_private")
      .select("paypal_email")
      .eq("listing_id", deal.listing_id)
      .maybeSingle(),
  ]);
  if (!listing) notFound();

  const { data: developer } = await supabase
    .from("developers")
    .select(DEVELOPER_COLUMNS)
    .eq("id", listing.developer_id)
    .single<Developer>();

  // Reviews are public, so no RLS filtering: both sides' reviews for this deal come back.
  const { data: reviews } =
    deal.status === "completed"
      ? await supabase.from("reviews").select("*").eq("deal_id", deal.id).returns<Review[]>()
      : { data: null };
  const myReview = reviews?.find((r) => r.author_id === user.id) ?? null;
  const otherUsername = isBuyer ? listing.seller_username : buyer?.username;

  const price = formatPrice(deal.price_eur);
  const current = stepIndex(deal);

  return (
    <main className="container page">
      <nav aria-label="Breadcrumb" className="breadcrumb">
        <Link href="/account">My account</Link>
        <span aria-hidden="true">/</span>
        <span>
          {isBuyer ? "Purchase" : "Sale"} #{deal.id}
        </span>
      </nav>
      <h1 className="page-title">
        {listing.developer_name} {listing.plugin_name}
      </h1>
      <p className="lead">
        {price} · {isBuyer ? `sold by @${listing.seller_username}` : `bought by @${buyer?.username}`}{" "}
        · <Link href={`/listings/${listing.id}`}>Listing #{listing.id}</Link>
      </p>

      {actionError && (
        <p className="notice notice-error">
          That action isn&apos;t possible anymore. The page below shows the current status.
        </p>
      )}

      {deal.status === "cancelled" ? (
        <div className="card">
          <h2 className="section-title">This purchase was cancelled</h2>
          <p className="muted">
            {deal.cancelled_by === user.id ? "You" : isBuyer ? "The seller" : "The buyer"} cancelled
            it before the payment was confirmed. The listing is back online.
          </p>
        </div>
      ) : (
        <div className="deal-layout">
          <div className="deal-main">
            <ol className="deal-steps" aria-label="Progress">
              {STEPS.map((label, i) => (
                <li key={label} className={i < current ? "done" : i === current ? "current" : ""}>
                  {label}
                </li>
              ))}
            </ol>

            {deal.status === "requested" && isBuyer && (
              <section className="card deal-box">
                <h2 className="section-title">Pay the seller with PayPal</h2>
                <ol className="pay-steps">
                  <li>
                    Open PayPal and send <strong>{price}</strong> to:
                    <span className="paypal-email">{privateInfo?.paypal_email}</span>
                  </li>
                  <li>
                    Choose <strong>Goods and Services</strong>. Never &quot;Friends and
                    Family&quot;: it has no PayPal Buyer Protection at all.
                  </li>
                  <li>
                    In the note, write: <strong>Plugin Resale listing #{listing.id}</strong>
                  </li>
                </ol>
                <a
                  className="btn btn-primary btn-lg"
                  href="https://www.paypal.com/myaccount/transfer/homepage/pay"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Open PayPal
                </a>
                <p className="hint">
                  Once the seller confirms they received the payment, they start the license
                  transfer. Come back to this page (My account → My purchases) to follow it.
                </p>
              </section>
            )}

            {deal.status === "requested" && !isBuyer && (
              <section className="card deal-box">
                <h2 className="section-title">@{buyer?.username} wants to buy your license</h2>
                <p>
                  They were asked to send <strong>{price}</strong> to your PayPal (
                  {privateInfo?.paypal_email}) with <strong>Goods and Services</strong> and the note
                  &quot;Plugin Resale listing #{listing.id}&quot;.
                </p>
                <p>
                  Check your PayPal account. Only when the payment has arrived, confirm it below,
                  then start the license transfer.
                </p>
                <StepButton deal={deal} step="paid" label="I received the payment" primary />
              </section>
            )}

            {deal.status === "paid" && isBuyer && (
              <section className="card deal-box">
                <h2 className="section-title">The seller received your payment</h2>
                <p>
                  @{listing.seller_username} is now transferring the license to you, following{" "}
                  {listing.developer_name}&apos;s process (see below). When the license shows up in
                  your {listing.developer_name} account, confirm it here.
                </p>
                <StepButton deal={deal} step="completed" label="I received the license" primary />
                <p className="hint">
                  A problem with the payment or the transfer? Open a case in PayPal&apos;s
                  Resolution Center: Plugin Resale doesn&apos;t handle refunds or disputes.
                </p>
              </section>
            )}

            {deal.status === "paid" && !isBuyer && (
              <section className="card deal-box">
                <h2 className="section-title">Now transfer the license</h2>
                <p>
                  Uninstall the plugin and transfer the license to @{buyer?.username} following{" "}
                  {listing.developer_name}&apos;s process below. The buyer confirms on their side
                  once it&apos;s in their account, and the sale is complete.
                </p>
                <TaxNote />
              </section>
            )}

            {deal.status === "completed" && (
              <section className="card deal-box">
                <h2 className="section-title">Deal completed</h2>
                <p>
                  {isBuyer
                    ? "Enjoy your plugin! Thanks for buying second-hand."
                    : "The buyer confirmed they received the license. Thanks for selling on Plugin Resale."}
                </p>
                {!isBuyer && <TaxNote />}

                {myReview ? (
                  <p className="muted">
                    You rated @{otherUsername} {myReview.rating}★
                    {myReview.comment ? `: “${myReview.comment}”` : ""}
                  </p>
                ) : (
                  <form action={addReview} className="review-form">
                    <input type="hidden" name="deal_id" value={deal.id} />
                    <label className="field">
                      <span className="field-label">Rate @{otherUsername}</span>
                      <select className="input" name="rating" defaultValue="5" required>
                        {[5, 4, 3, 2, 1].map((n) => (
                          <option key={n} value={n}>
                            {n}★
                          </option>
                        ))}
                      </select>
                    </label>
                    <textarea
                      className="input textarea"
                      name="comment"
                      rows={2}
                      maxLength={1000}
                      placeholder="Optional comment…"
                    />
                    <button className="btn btn-primary" type="submit">
                      Leave a review
                    </button>
                  </form>
                )}
              </section>
            )}

            {deal.status === "requested" && (
              <StepButton
                deal={deal}
                step="cancel"
                label={isBuyer ? "Cancel this purchase" : "Cancel this sale"}
              />
            )}
          </div>

          {developer && deal.status !== "completed" && <TransferRules developer={developer} />}
        </div>
      )}
    </main>
  );
}

// French tax code (CGI art. 242 bis): platforms remind sellers of their tax obligations at each sale.
function TaxNote() {
  return (
    <p className="hint">
      Taxes: you&apos;re responsible for declaring any income from your sales where required. In
      France, see{" "}
      <a href="https://www.impots.gouv.fr" target="_blank" rel="noopener noreferrer">
        impots.gouv.fr
      </a>{" "}
      and{" "}
      <a href="https://www.urssaf.fr" target="_blank" rel="noopener noreferrer">
        urssaf.fr
      </a>
      ; elsewhere, your national tax authority.
    </p>
  );
}
