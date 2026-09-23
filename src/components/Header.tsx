import Link from "next/link";
import { getCurrentUser } from "@/lib/supabase/user";

export async function Header() {
  const { user, profile } = await getCurrentUser();

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
            Developers
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
          {user ? (
            <Link href="/account" className="nav-link">
              {profile?.username ? `@${profile.username}` : "My account"}
            </Link>
          ) : (
            <Link href="/signin" className="nav-link">
              Sign in
            </Link>
          )}
          <Link href="/sell" className="btn btn-primary">
            Sell a plugin
          </Link>
        </div>
      </div>
    </header>
  );
}
