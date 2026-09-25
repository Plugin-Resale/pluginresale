import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Page not found",
};

// Unknown URLs, removed listings, unpublished blog posts: keep the visitor on the site.
export default function NotFound() {
  return (
    <main className="container page not-found">
      <p className="eyebrow">404</p>
      <h1 className="page-title">This page doesn&apos;t exist.</h1>
      <p className="lead">
        The link may be broken, or the listing may have been removed. Try a search instead.
      </p>
      <form action="/browse" className="hero-search" role="search">
        <label htmlFor="notfound-q" className="sr-only">
          Search plugins
        </label>
        <input
          id="notfound-q"
          name="q"
          className="input input-lg"
          placeholder="Try “Pro-Q”, “Decapitator”, “Ozone”…"
        />
        <button className="btn btn-primary btn-lg" type="submit">
          Search
        </button>
      </form>
      <nav className="not-found-links" aria-label="Main sections">
        <Link href="/browse">Browse listings</Link>
        <Link href="/developers">Developer transfer rules</Link>
        <Link href="/blog">Blog</Link>
        <Link href="/">Home</Link>
      </nav>
    </main>
  );
}
