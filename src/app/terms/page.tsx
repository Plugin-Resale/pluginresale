import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service",
  description: "The terms that apply when you use Plugin Resale.",
};

export default function TermsPage() {
  return (
    <main className="narrow narrow-wide page legal">
      <h1 className="page-title">Terms of Service</h1>
      <p className="lead">Last updated 23 September 2026.</p>

      <p>
        Plugin Resale (pluginresale.com) is operated by SAS Boring Vic (&quot;we&quot;,
        &quot;us&quot;). [Registered address and SIRET to be added here before launch.] You can
        reach us at{" "}
        <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>. By creating an
        account or using the site, you agree to these terms.
      </p>

      <h2>1. What Plugin Resale is</h2>
      <p>
        Plugin Resale is a marketplace where users list and buy second-hand audio plugin
        licenses from each other. It is free to list and free to buy: we take no commission.
        Our revenue, if any, comes from advertising, never from your transactions.
      </p>

      <h2>2. Accounts</h2>
      <p>
        You need an account (email + magic link, no password) to sell, buy, message or review.
        You must provide a real, working email address and keep your account information
        accurate. You&apos;re responsible for what happens under your account.
      </p>

      <h2>3. Selling</h2>
      <p>Before publishing a listing, you confirm that:</p>
      <ul>
        <li>
          You own the license and it is not a Not-For-Resale, educational, or hardware-bundled
          license.
        </li>
        <li>
          You will uninstall the plugin and complete the developer&apos;s official transfer
          process once you&apos;re paid.
        </li>
      </ul>
      <p>
        Listing a license you don&apos;t own, or one that its developer doesn&apos;t allow to be
        transferred, is a breach of these terms and may get your listing removed and your
        account suspended.
      </p>

      <h2>4. Buying and payment</h2>
      <p>
        <strong>Plugin Resale is never a party to the payment.</strong> Buyers and sellers pay
        each other directly, via PayPal Goods &amp; Services. We don&apos;t process, hold, or
        touch the money at any point, and we don&apos;t charge a fee on it. PayPal&apos;s own
        terms and Buyer Protection apply to that payment, not ours.
      </p>
      <p>
        If a payment or a license transfer goes wrong, you resolve it directly with the other
        user and, if needed, through PayPal&apos;s Resolution Center. We don&apos;t mediate
        disputes, issue refunds, or guarantee that a transfer will happen.
      </p>

      <h2>5. Developer transfer rules</h2>
      <p>
        We publish each plugin developer&apos;s license-transfer policy (fees, process,
        restrictions) as a courtesy, sourced from the developer&apos;s own public information.
        These policies can change at any time and we don&apos;t control or guarantee them.
        Always check the developer&apos;s official source, linked on each developer page,
        before you pay.
      </p>

      <h2>6. Messages and reviews</h2>
      <p>
        Messages are for discussing a listing with the other party, not for spam or
        unsolicited offers. Reviews must reflect a real transaction and your honest experience
        of it; we can remove reviews or content that are abusive, fake, or posted in bad faith.
      </p>

      <h2>7. Prohibited uses</h2>
      <p>You agree not to:</p>
      <ul>
        <li>List a license you don&apos;t own or aren&apos;t entitled to transfer.</li>
        <li>Ask a buyer to pay with &quot;Friends &amp; Family&quot; instead of Goods &amp; Services.</li>
        <li>Scrape, spam, harass other users, or misuse the messaging or review system.</li>
        <li>Use the site for anything illegal, or try to circumvent these terms.</li>
      </ul>

      <h2>8. Content you post</h2>
      <p>
        You keep ownership of what you post (listing descriptions, messages, reviews), but you
        grant us the right to display it on the site so the marketplace can work. Plugin and
        developer names are used only to identify products for sale; Plugin Resale isn&apos;t
        affiliated with or endorsed by any plugin developer.
      </p>

      <h2>9. Disclaimer and liability</h2>
      <p>
        The site is provided &quot;as is&quot;. We don&apos;t verify that a seller genuinely
        owns a license, that a developer&apos;s transfer policy is current, or that a buyer and
        seller will complete their transaction in good faith. To the extent allowed by law,
        we&apos;re not liable for losses arising from a transaction, a failed license transfer,
        or content posted by users.
      </p>

      <h2>10. Suspension and termination</h2>
      <p>
        We can remove a listing, a review, or suspend an account that breaches these terms.
        You can stop using the site and ask us to delete your account at any time.
      </p>

      <h2>11. Changes</h2>
      <p>
        We may update these terms as the site evolves. We&apos;ll post the new version here
        with an updated date; continuing to use the site after a change means you accept it.
      </p>

      <h2>12. Governing law</h2>
      <p>These terms are governed by French law.</p>

      <h2>13. Contact</h2>
      <p>
        Questions about these terms:{" "}
        <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>.
      </p>
    </main>
  );
}
