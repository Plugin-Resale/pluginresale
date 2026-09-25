import type { Metadata } from "next";
import Link from "next/link";
import type { ReactNode } from "react";
import { getAllPosts } from "@/lib/blog";

export const metadata: Metadata = {
  title: "FAQ",
  description:
    "How Plugin Resale works: buying and selling second-hand plugin licenses, PayPal payments, license transfers, fees and safety.",
};

const EMAIL = <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>;

type Question = { q: string; a: ReactNode };
type Section = { title: string; questions: Question[] };

// `post` links to a blog post, or renders plain text while the post is still scheduled.
function sections(post: (slug: string, text: string) => ReactNode): Section[] {
  return [
    {
      title: "About Plugin Resale",
      questions: [
        {
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
          q: "Is Plugin Resale a reseller?",
          a: (
            <p>
              No. We never own, buy or sell licenses ourselves, and we are not a party to the
              sales made on the site.
            </p>
          ),
        },
        {
          q: "How much does it cost?",
          a: (
            <p>
              Nothing. It&apos;s free to list, free to buy, and we take no commission on your
              sales.
            </p>
          ),
        },
        {
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
          q: "Who can use the site?",
          a: (
            <p>
              Anyone aged 18 or over, as a private individual. Shops, resellers, developers and
              anyone selling as part of a business can&apos;t list licenses.
            </p>
          ),
        },
        {
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
      ],
    },
    {
      title: "Payment",
      questions: [
        {
          q: "Can I pay on the site?",
          a: (
            <p>
              No. There is no payment on Plugin Resale. The buyer pays the seller directly with
              PayPal, and we never hold or touch the money.
            </p>
          ),
        },
        {
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
          q: "Which currency are prices in?",
          a: <p>All prices on the site are in euros.</p>,
        },
      ],
    },
    {
      title: "Buying",
      questions: [
        {
          q: "How do I buy a plugin?",
          a: (
            <ol>
              <li>Click &quot;Buy with PayPal&quot; on the listing.</li>
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
          q: "How do I know a license can be transferred?",
          a: (
            <>
              <p>
                Every listing and every <Link href="/developers">developer page</Link> shows the
                developer&apos;s transfer rules, with a badge: <strong>Transferable</strong>,{" "}
                <strong>Not transferable</strong> or <strong>Policy not verified</strong>.
              </p>
              <p>
                These rules are a summary we make from each developer&apos;s public information,
                for information only. Developers can change them at any time, so always check the
                official source (linked on each developer page) before you pay.
              </p>
            </>
          ),
        },
        {
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
          q: "How long does a transfer take?",
          a: (
            <p>
              It depends on the developer: some transfers are instant from your account, others
              go through their support team. The usual delay is shown on the developer page.
            </p>
          ),
        },
        {
          q: "Can I ask the seller a question before buying?",
          a: (
            <p>
              Yes. Use &quot;Message seller&quot; on the listing. You&apos;ll find your
              conversations in My account.
            </p>
          ),
        },
        {
          q: "Can I cancel a purchase?",
          a: (
            <p>
              Yes, as long as the seller hasn&apos;t confirmed that your payment arrived. The
              listing then goes back online.
            </p>
          ),
        },
        {
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
          q: "Any tips to buy safely?",
          a: (
            <p>
              Check the transfer rules and the seller&apos;s reviews, always pay with Goods and
              Services, and follow the purchase from your deal page. More in{" "}
              {post("how-to-buy-used-plugins-safely", "How to buy a used plugin without getting scammed")}.
            </p>
          ),
        },
      ],
    },
    {
      title: "Selling",
      questions: [
        {
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
          q: "My plugin isn't in the list. What do I do?",
          a: (
            <p>
              Add it yourself from the Sell form: pick the developer, type the plugin name and
              choose a category. If the developer itself is missing, email us at {EMAIL}.
            </p>
          ),
        },
        {
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
          q: "Can I sell a DAW license?",
          a: (
            <p>
              Yes, if the DAW&apos;s publisher allows transfers. More in{" "}
              {post("selling-a-daw-license", "Can you sell your DAW license?")}.
            </p>
          ),
        },
        {
          q: "How much should I ask for my plugin?",
          a: (
            <p>
              You set the price. More in{" "}
              {post("how-much-is-my-used-plugin-worth", "How much is my used plugin worth?")}.
            </p>
          ),
        },
        {
          q: "Is my PayPal email public?",
          a: (
            <p>
              No. It&apos;s only shown to the buyer of an ongoing purchase of your listing.
            </p>
          ),
        },
        {
          q: "When do I get paid?",
          a: (
            <p>
              The buyer pays you directly on PayPal before the transfer. Check your PayPal
              account, and only click &quot;I received the payment&quot; once the money has
              arrived.
            </p>
          ),
        },
        {
          q: "What do I do after the sale?",
          a: (
            <p>
              Uninstall the plugin and transfer the license to the buyer following the
              developer&apos;s official process. The buyer confirms once it&apos;s in their account,
              and you rate each other.
            </p>
          ),
        },
        {
          q: "Can I remove my listing?",
          a: <p>Yes, at any time, with the &quot;Remove listing&quot; button on your listing.</p>,
        },
        {
          q: "Do I have to declare my sales?",
          a: (
            <p>
              You are responsible for declaring any income from your sales where the law requires
              it. In France, see impots.gouv.fr and urssaf.fr; elsewhere, your national tax
              authority.
            </p>
          ),
        },
      ],
    },
    {
      title: "Trust and safety",
      questions: [
        {
          q: "How do reviews work?",
          a: (
            <p>
              After a completed deal, the buyer and the seller can rate each other once, from 1
              to 5, with an optional comment. Reviews appear on each user&apos;s public profile.
            </p>
          ),
        },
        {
          q: "How do I report a listing or a user?",
          a: (
            <p>
              Use the <Link href="/report">report form</Link>. Every report is reviewed by a
              person.
            </p>
          ),
        },
        {
          q: "The transfer rules for a developer are wrong.",
          a: <p>Tell us at {EMAIL} and we&apos;ll correct them quickly.</p>,
        },
        {
          q: "How do I delete my account?",
          a: (
            <p>
              From My account, once no purchase or sale is in progress.
            </p>
          ),
        },
        {
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

  return (
    <main className="narrow narrow-wide page legal faq">
      <h1 className="page-title">FAQ</h1>
      <p className="lead">
        Everything about buying and selling second-hand plugin licenses on Plugin Resale.
      </p>

      {sections(post).map((section) => (
        <section key={section.title}>
          <h2>{section.title}</h2>
          {section.questions.map(({ q, a }) => (
            <details key={q} className="faq-item">
              <summary>{q}</summary>
              <div className="faq-answer">{a}</div>
            </details>
          ))}
        </section>
      ))}
    </main>
  );
}
