import Link from "next/link";

export function Footer() {
  return (
    <footer className="site-footer">
      <div className="container">
        <div className="footer-about">
          <Link href="/" className="logo">
            plugin<span>resale</span>
          </Link>
          <p>
            Payments are made directly between users via PayPal. Plugin Resale is not a party to
            the transaction and does not handle refunds or disputes.
          </p>
        </div>
        <nav className="footer-links" aria-label="Footer">
          <Link href="/developers">Transfer rules</Link>
          <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>
        </nav>
      </div>
    </footer>
  );
}
