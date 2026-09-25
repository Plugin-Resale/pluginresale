import type { Metadata } from "next";
import Link from "next/link";
import type { ReactNode } from "react";
import { getAllPosts } from "@/lib/blog";
import { FaqAutoOpen } from "./FaqAutoOpen";

export const metadata: Metadata = {
  title: "FAQ",
  description:
    "How Plugin Resale works: buying and selling second-hand plugin licenses, PayPal payments, license transfers, fees and safety.",
};

const EMAIL = <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>;

type Question = { id: string; q: string; a: ReactNode };
type Section = { id: string; title: string; questions: Question[] };

// `post` links to a blog post, or renders plain text while the post is still scheduled.
// Question ids are used in shareable links (/faq#id): don't rename them.
function sections(post: (slug: string, text: string) => ReactNode): Section[] {
  return [
    {
      id: "about",
      title: "About Plugin Resale",
      questions: [
        {
          id: "what-is-plugin-resale",
          q: "What is Plugin Resale?",
          a: (
            <p>
              A marketplace where private individuals buy and sell second-hand audio plugin
              licenses. We host the listings and put buyers and sellers in touch. Each sale is
              made directly between the buyer and the seller.
            </p>
          ),
        },
        {
          id: "reseller",
          q: "Is Plugin Resale a reseller?",
          a: (
            <p>
              No. We never own, buy or sell licenses ourselves, and we are not a party to the
              sales made on the site.
            </p>
          ),
        },
        {
          id: "cost",
          q: "How much does it cost?",
          a: (
            <p>
              Nothing. It&apos;s free to list, free to buy, and we take no commission on your
              sales. The only possible costs come from outside the site: PayPal&apos;s fees for
              the seller, and the developer&apos;s transfer fee if it has one.
            </p>
          ),
        },
        {
          id: "legal",
          q: "Is it legal to resell a plugin license?",
          a: (
            <p>
              It depends on each developer&apos;s license terms. Many developers allow transfers
              through their official process, some charge a fee, and some don&apos;t allow resale
              at all. That&apos;s why every listing shows the developer&apos;s transfer rules. More
              in {post("can-i-legally-resell-my-plugins", "Can I legally resell my audio plugins?")}.
            </p>
          ),
        },
        {
          id: "who-can-use",
          q: "Who can use the site?",
          a: (
            <p>
              Anyone aged 18 or over, as a private individual. Shops, resellers, developers and
              anyone selling as part of a business can&apos;t list licenses.
            </p>
          ),
        },
        {
          id: "account",
          q: "Do I need an account?",
          a: (
            <p>
              Only to sell, buy, message or leave a review. Browsing is open to everyone. You{" "}
              <Link href="/signin">sign in</Link> with your email: we send you a link, no
              password needed. Then you choose a username and accept the{" "}
              <Link href="/terms">Terms</Link>.
            </p>
          ),
        },
        {
          id: "notifications",
          q: "Will I get emails?",
          a: (
            <p>
              Besides your sign-in links, only about your own deals and conversations: when
              someone buys your listing, when
              the seller confirms your payment, when the buyer confirms they got the license, and
              when you receive a message. No newsletter, no advertising.
            </p>
          ),
        },
      ],
    },
    {
      id: "payment",
      title: "Payment",
      questions: [
        {
          id: "pay-on-site",
          q: "Can I pay on the site?",
          a: (
            <p>
              No. There is no payment on Plugin Resale. The buyer pays the seller directly with
              PayPal, and we never hold or touch the money.
            </p>
          ),
        },
        {
          id: "how-payment-works",
          q: "How does the payment work?",
          a: (
            <p>
              When you click &quot;Buy with PayPal&quot;, the listing is reserved for you and you
              see the seller&apos;s PayPal email. You send the price with PayPal{" "}
              <strong>Goods and Services</strong>, with &quot;Plugin Resale listing #&hellip;&quot;
              in the note (the exact text is shown on your purchase page).
            </p>
          ),
        },
        {
          id: "goods-and-services",
          q: "Why Goods and Services, and never Friends and Family?",
          a: (
            <p>
              Goods and Services is what gives the buyer access to PayPal Buyer Protection.
              Friends and Family has none. A seller who asks for Friends and Family breaks our{" "}
              <Link href="/terms">Terms</Link>: please <Link href="/report">report it</Link>.
            </p>
          ),
        },
        {
          id: "currency",
          q: "Which currency are prices in?",
          a: (
            <p>
              All prices on the site are in euros. If your PayPal account uses another currency,
              PayPal converts it when you pay, at its own exchange rate.
            </p>
          ),
        },
      ],
    },
    {
      id: "buying",
      title: "Buying",
      questions: [
        {
          id: "how-to-buy",
          q: "How do I buy a plugin?",
          a: (
            <ol>
              <li>
                <Link href="/signin">Sign in</Link>, then click &quot;Buy with PayPal&quot; on the
                listing. The listing is reserved for you.
              </li>
              <li>Pay the seller with PayPal Goods and Services.</li>
              <li>The seller confirms the payment and transfers the license to you.</li>
              <li>
                When the license shows up in your account at the developer, click &quot;I received
                the license&quot;.
              </li>
              <li>You and the seller rate each other.</li>
            </ol>
          ),
        },
        {
          id: "transferable",
          q: "How do I know a license can be transferred?",
          a: (
            <>
              <p>
                Every listing and every <Link href="/developers">developer page</Link> shows the
                developer&apos;s transfer rules, with a badge: <strong>Transferable</strong>,{" "}
                <strong>Not transferable</strong> or <strong>Policy not verified</strong>. Some
                developers add conditions (a limit on the number of transfers, or a country
                restriction, for example): they are listed under &quot;Restrictions&quot;.
              </p>
              <p>
                These rules are a summary we make from each developer&apos;s public information,
                for information only. Developers can change them at any time, so always check the
                official source (linked on each developer page) before you pay. More in{" "}
                {post("how-to-transfer-a-plugin-license", "How to transfer a plugin license")}.
              </p>
            </>
          ),
        },
        {
          id: "policy-not-verified",
          q: "What does \"Policy not verified\" mean?",
          a: (
            <p>
              We haven&apos;t found an official transfer policy for that developer yet. The listing
              is allowed, but before paying, ask the developer (or have the seller ask) whether
              the license can be transferred, and how. If they say no, don&apos;t buy.
            </p>
          ),
        },
        {
          id: "transfer-fees",
          q: "Are there transfer fees? Who pays them?",
          a: (
            <p>
              Some developers charge a fee to transfer a license. The developer page tells you
              the fee and who pays it according to the developer. If it&apos;s not clear, agree on
              it with the seller before paying, using &quot;Message seller&quot;.
            </p>
          ),
        },
        {
          id: "transfer-delay",
          q: "How long does a transfer take?",
          a: (
            <p>
              It depends on the developer: some transfers are instant from your account, others
              go through their support team. The usual delay is shown on the developer page.
            </p>
          ),
        },
        {
          id: "genuine",
          q: "How do I know the license is genuine?",
          a: (
            <p>
              The transfer goes through the developer&apos;s official process, so the license ends
              up registered in your own account at the developer: that&apos;s your proof. Only
              click &quot;I received the license&quot; once you see it there. Sellers also confirm,
              when they list, that they own the license and that it isn&apos;t an NFR,
              educational or bundled license.
            </p>
          ),
        },
        {
          id: "ask-seller",
          q: "Can I ask the seller a question before buying?",
          a: (
            <p>
              Yes. Use &quot;Message seller&quot; on the listing. You&apos;ll find your
              conversations in <Link href="/account">My account</Link>.
            </p>
          ),
        },
        {
          id: "make-an-offer",
          q: "Can I negotiate the price?",
          a: (
            <p>
              There&apos;s no offer button yet, but you can suggest a price to the seller with
              &quot;Message seller&quot;. If they agree, they relist at the new price and you buy
              that listing.
            </p>
          ),
        },
        {
          id: "follow-purchase",
          q: "Where do I follow my purchase?",
          a: (
            <p>
              In <Link href="/account">My account</Link>, under My purchases. Each purchase has
              its own page with the payment instructions, the current step and the developer&apos;s
              transfer rules.
            </p>
          ),
        },
        {
          id: "cancel",
          q: "Can I cancel a purchase?",
          a: (
            <p>
              Yes, as long as the seller hasn&apos;t confirmed that your payment arrived. The
              seller can cancel too, until that same point. The listing then goes back online.
              Once the payment is confirmed, the purchase can&apos;t be cancelled on the site:
              sort it out with the seller, or through PayPal.
            </p>
          ),
        },
        {
          id: "seller-not-responding",
          q: "The seller doesn't answer. What do I do?",
          a: (
            <p>
              If you haven&apos;t paid yet, cancel the purchase from your purchase page and the
              listing goes back online. If you&apos;ve already paid and the seller stays silent,
              open a case in PayPal&apos;s Resolution Center and{" "}
              <Link href="/report">report the seller</Link> to us.
            </p>
          ),
        },
        {
          id: "no-license",
          q: "I paid but I never got the license. What can I do?",
          a: (
            <p>
              Contact the seller first. If that doesn&apos;t solve it, open a case in PayPal&apos;s
              Resolution Center. Plugin Resale doesn&apos;t handle refunds or disputes, but we do
              act on fraud: <Link href="/report">report the seller</Link>.
            </p>
          ),
        },
        {
          id: "withdrawal",
          q: "Do I have a 14-day right of withdrawal?",
          a: (
            <p>
              No. Every seller is a private individual, so the EU consumer rights that apply when
              buying from a business (like the 14-day withdrawal right) don&apos;t apply to these
              sales.
            </p>
          ),
        },
        {
          id: "buy-safely",
          q: "Any tips to buy safely?",
          a: (
            <p>
              Check the transfer rules and the seller&apos;s reviews, always pay with Goods and
              Services, and follow the purchase from your purchase page. More in{" "}
              {post("how-to-buy-used-plugins-safely", "How to buy a used plugin without getting scammed")}.
            </p>
          ),
        },
      ],
    },
    {
      id: "selling",
      title: "Selling",
      questions: [
        {
          id: "how-to-sell",
          q: "How do I sell a plugin?",
          a: (
            <p>
              Go to <Link href="/sell">Sell</Link>, pick your plugin, set your price, add a
              description and the PayPal email you want to be paid on. The developer&apos;s
              transfer rules are shown next to the form before you publish.
            </p>
          ),
        },
        {
          id: "plugin-missing",
          q: "My plugin isn't in the list. What do I do?",
          a: (
            <p>
              Add it yourself from the Sell form: pick the developer, type the plugin name and
              choose a category. If the developer itself is missing, email us at {EMAIL}.
            </p>
          ),
        },
        {
          id: "cant-sell",
          q: "Which licenses can't I sell?",
          a: (
            <p>
              Not-For-Resale (NFR), educational and hardware-bundled licenses, licenses you
              don&apos;t own, and licenses whose developer doesn&apos;t allow transfers. More in{" "}
              {post(
                "nfr-educational-bundled-licenses-resale",
                "NFR, educational, bundled, upgrade: which plugin licenses can you resell?",
              )}.
            </p>
          ),
        },
        {
          id: "daw",
          q: "Can I sell a DAW license?",
          a: (
            <p>
              Yes, if the DAW&apos;s publisher allows transfers. More in{" "}
              {post("selling-a-daw-license", "Can you sell your DAW license?")}.
            </p>
          ),
        },
        {
          id: "price",
          q: "How much should I ask for my plugin?",
          a: (
            <p>
              You set the price. Look at what the same plugin is listed for on the site, and
              remember that a transfer fee paid by the buyer makes your price less attractive.
              More in {post("how-much-is-my-used-plugin-worth", "How much is my used plugin worth?")}.
            </p>
          ),
        },
        {
          id: "paypal-email-private",
          q: "Is my PayPal email public?",
          a: (
            <p>
              No. It&apos;s only shown to the buyer of an ongoing purchase of your listing.
            </p>
          ),
        },
        {
          id: "get-paid",
          q: "When do I get paid?",
          a: (
            <p>
              The buyer pays you directly on PayPal before the transfer. Check your PayPal
              account, and only click &quot;I received the payment&quot; once the money has
              arrived. Never start the transfer before that.
            </p>
          ),
        },
        {
          id: "after-sale",
          q: "What do I do after the sale?",
          a: (
            <p>
              Uninstall the plugin and transfer the license to the buyer following the
              developer&apos;s official process. The buyer confirms once it&apos;s in their account,
              and you rate each other. You follow each sale in{" "}
              <Link href="/account">My account</Link>, under My sales.
            </p>
          ),
        },
        {
          id: "change-price",
          q: "Can I change my price or my listing?",
          a: (
            <p>
              Not yet. Remove the listing and publish a new one with the right details: your
              PayPal email is filled in for you.
            </p>
          ),
        },
        {
          id: "remove-listing",
          q: "Can I remove my listing?",
          a: (
            <p>
              Yes, at any time before someone buys it, with the &quot;Remove listing&quot; button
              on your listing. You can put it back online later from the same place.
            </p>
          ),
        },
        {
          id: "taxes",
          q: "Do I have to declare my sales?",
          a: (
            <p>
              You are responsible for declaring any income from your sales where the law requires
              it. In France, see{" "}
              <a href="https://www.impots.gouv.fr" target="_blank" rel="noopener noreferrer">
                impots.gouv.fr
              </a>{" "}
              and{" "}
              <a href="https://www.urssaf.fr" target="_blank" rel="noopener noreferrer">
                urssaf.fr
              </a>
              ; elsewhere, your national tax authority.
            </p>
          ),
        },
      ],
    },
    {
      id: "trust",
      title: "Trust and safety",
      questions: [
        {
          id: "reviews",
          q: "How do reviews work?",
          a: (
            <p>
              After a completed deal, the buyer and the seller can rate each other once, from 1
              to 5, with an optional comment. Reviews appear on each user&apos;s public profile.
            </p>
          ),
        },
        {
          id: "report",
          q: "How do I report a listing or a user?",
          a: (
            <p>
              Click &quot;Report this listing&quot; on the listing, or use the{" "}
              <Link href="/report">report form</Link>. Every report is reviewed by a person.
            </p>
          ),
        },
        {
          id: "wrong-rules",
          q: "The transfer rules for a developer are wrong.",
          a: (
            <p>
              Tell us at {EMAIL}, ideally with a link to the developer&apos;s official page, and
              we&apos;ll correct them quickly.
            </p>
          ),
        },
        {
          id: "delete-account",
          q: "How do I delete my account?",
          a: (
            <p>
              From <Link href="/account">My account</Link>, once no purchase or sale is in
              progress. Your listings go offline and your email and PayPal emails are erased.
              Past deals and reviews stay visible to the other side, under an anonymous name.
            </p>
          ),
        },
        {
          id: "contact",
          q: "How do I contact you?",
          a: <p>Email us at {EMAIL}.</p>,
        },
      ],
    },
  ];
}

export default async function FaqPage() {
  const published = new Set((await getAllPosts()).map((p) => p.slug));
  const post = (slug: string, text: string) =>
    published.has(slug) ? <Link href={`/blog/${slug}`}>{text}</Link> : <em>{text}</em>;
  const all = sections(post);

  return (
    <main className="narrow narrow-wide page legal faq">
      <FaqAutoOpen />
      <h1 className="page-title">FAQ</h1>
      <p className="lead">
        Everything about buying and selling second-hand plugin licenses on Plugin Resale.
      </p>

      <nav className="faq-nav" aria-label="FAQ sections">
        {all.map((section) => (
          <a key={section.id} href={`#${section.id}`} className="chip">
            {section.title}
          </a>
        ))}
      </nav>

      {all.map((section) => (
        <section key={section.id} id={section.id}>
          <h2>{section.title}</h2>
          {section.questions.map(({ id, q, a }) => (
            <details key={id} id={id} className="faq-item">
              <summary>{q}</summary>
              <div className="faq-answer">{a}</div>
            </details>
          ))}
        </section>
      ))}

      <aside className="card faq-contact">
        <h2>Still have a question?</h2>
        <p>Email us at {EMAIL}, we&apos;re happy to help.</p>
        <div className="faq-contact-actions">
          <Link href="/browse" className="btn">
            Browse plugins
          </Link>
          <Link href="/sell" className="btn btn-primary">
            Sell a plugin
          </Link>
        </div>
      </aside>
    </main>
  );
}
