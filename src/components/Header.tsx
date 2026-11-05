import { AccountLink } from "@/components/AccountLink";
import Link from "@/components/Link";

// No session read here on purpose: the account link resolves it in the browser (AccountLink),
// so the header never makes a page dynamic. See AccountLink for why.
export function Header() {
  return (
    <header className="site-header">
      <div className="container">
        <Link href="/" className="logo">
          plugin<span>resale</span>
        </Link>
        <nav className="site-nav" aria-label="Main">
          <Link href="/browse" className="nav-link">
            Browse
          </Link>
          <Link href="/developers" className="nav-link">
            Transfer rules
          </Link>
          <Link href="/blog" className="nav-link">
            Blog
          </Link>
        </nav>
        <form action="/browse" className="header-search" role="search">
          <label htmlFor="header-q" className="sr-only">
            Search plugins
          </label>
          <input
            id="header-q"
            name="q"
            className="input"
            placeholder="Search a plugin or developer"
          />
        </form>
        <div className="header-actions">
          <AccountLink />
          <Link href="/sell" className="btn btn-primary">
            Sell a plugin
          </Link>
        </div>
      </div>
    </header>
  );
}
