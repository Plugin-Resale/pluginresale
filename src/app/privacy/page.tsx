import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: "What data Plugin Resale collects and why, and your rights over it.",
};

export default function PrivacyPage() {
  return (
    <main className="narrow narrow-wide page legal">
      <h1 className="page-title">Privacy Policy</h1>
      <p className="lead">Last updated 23 September 2026.</p>

      <p>
        This policy explains what personal data Plugin Resale (pluginresale.com) collects and
        why. The data controller is SAS Boring Vic. [Registered address and SIRET to be added
        here before launch.] Contact us about privacy at{" "}
        <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>.
      </p>

      <h2>1. Data we collect</h2>
      <ul>
        <li>
          <strong>Account:</strong> your email address (to sign you in with a magic link) and
          the username you choose.
        </li>
        <li>
          <strong>Listings:</strong> the plugin, price, description and PayPal email you enter
          when selling. Your PayPal email is never shown publicly — only to the buyer of an
          active purchase.
        </li>
        <li>
          <strong>Deals, messages and reviews:</strong> records of purchases (status,
          timestamps, price), the messages you exchange with other users, and reviews you
          write or receive.
        </li>
        <li>
          <strong>Technical data:</strong> standard server logs (IP address, browser) kept by
          our hosting providers for security and reliability.
        </li>
      </ul>
      <p>We don&apos;t currently use analytics or advertising cookies.</p>

      <h2>2. Why we collect it</h2>
      <p>
        To run the marketplace: create your account, let you list and buy, connect buyers and
        sellers, show trust signals like ratings, and send you the notification emails a deal
        or message needs. We also use it to prevent fraud and abuse. We don&apos;t sell your
        data.
      </p>

      <h2>3. Who we share it with</h2>
      <p>These service providers process data on our behalf, only as needed to run the site:</p>
      <ul>
        <li>
          <strong>Supabase</strong> — our database, authentication and hosting for your account
          data.
        </li>
        <li>
          <strong>Resend</strong> — sends our sign-in and notification emails.
        </li>
        <li>
          <strong>Vercel</strong> — hosts the website.
        </li>
      </ul>
      <p>
        <strong>PayPal is not one of these.</strong> When you buy or sell, payment happens
        directly between you and the other user on PayPal&apos;s own platform — we only display
        the seller&apos;s PayPal email to the buyer, we don&apos;t send them any data on your
        behalf.
      </p>

      <h2>4. Cookies</h2>
      <p>
        We use one strictly necessary cookie to keep you signed in. It&apos;s required for the
        site to work and doesn&apos;t need consent under EU law. If we ever add advertising or
        analytics that use non-essential cookies, we&apos;ll ask for your consent first and
        update this page.
      </p>

      <h2>5. How long we keep it</h2>
      <p>
        We keep your account and its history for as long as your account is active. If you
        delete your account, we remove your personal data, except what we must keep for legal
        reasons (e.g. records of a specific deal already reviewed by both sides may be kept in
        anonymised form).
      </p>

      <h2>6. Your rights</h2>
      <p>Under GDPR, you can ask us to:</p>
      <ul>
        <li>Access the personal data we hold about you.</li>
        <li>Correct it if it&apos;s inaccurate.</li>
        <li>Delete your account and personal data.</li>
        <li>Export your data.</li>
        <li>Object to or restrict how we use it.</li>
      </ul>
      <p>
        Email <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a> to exercise
        any of these. You can also lodge a complaint with your national data protection
        authority (in France, the CNIL).
      </p>

      <h2>7. Security</h2>
      <p>
        Your data is protected by row-level security rules in our database — each table
        enforces exactly who can read or write it — and all traffic to the site is encrypted
        (HTTPS).
      </p>

      <h2>8. International transfers</h2>
      <p>
        Our service providers may process data outside the EU. When they do, they rely on
        recognised safeguards such as the EU Standard Contractual Clauses.
      </p>

      <h2>9. Children</h2>
      <p>Plugin Resale isn&apos;t intended for anyone under 16.</p>

      <h2>10. Changes</h2>
      <p>
        We may update this policy as the site evolves. We&apos;ll post the new version here
        with an updated date.
      </p>
    </main>
  );
}
