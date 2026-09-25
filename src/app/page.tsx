import Link from "next/link";
import { ListingGrid } from "@/components/ListingCard";
import { CATEGORIES, type ListingCard } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";

const STEPS = [
  {
    title: "List your license",
    text: "Pick the plugin, set your price. We show the developer's transfer rules and fees before you publish.",
  },
  {
    title: "Get paid via PayPal",
    text: "The buyer pays you directly with PayPal Goods & Services. Plugin Resale never holds the money.",
  },
  {
    title: "Transfer the license",
    text: "Follow the developer's transfer process. Once it's done, buyer and seller rate each other.",
  },
];

export default async function Home() {
  const supabase = await createClient();
  const [{ data: listings }, { data: developers }] = await Promise.all([
    supabase
      .from("listing_cards")
      .select("*")
      .eq("status", "active")
      .order("created_at", { ascending: false })
      .limit(8)
      .returns<ListingCard[]>(),
    supabase
      .from("developers")
      .select("name, slug")
      .in("slug", ["fabfilter", "soundtoys", "izotope", "waves", "native-instruments", "arturia"])
      .order("name"),
  ]);

  return (
    <main>
      <section className="container hero">
        <div className="hero-text">
          <p className="eyebrow">Second-hand audio plugin licenses</p>
          <h1>
            Your unused plugins
            <br />
            are money sleeping.
          </h1>
          <p className="lead">
            Buy and sell used plugin licenses from other producers and engineers. Buyers pay
            sellers directly with PayPal. Free to list, free to buy.
          </p>
          <form action="/browse" className="hero-search" role="search">
            <label htmlFor="hero-q" className="sr-only">
              Search plugins
            </label>
            <input
              id="hero-q"
              name="q"
              className="input input-lg"
              placeholder="Try “Pro-Q”, “Decapitator”, “Ozone”…"
            />
            <button className="btn btn-primary btn-lg" type="submit">
              Search
            </button>
          </form>
        </div>
        <aside className="hero-aside">
          <span className="rules-panel-eyebrow">Selling?</span>
          <h2>List a plugin in two minutes.</h2>
          <ul className="ticks">
            <li>Free to list, no commission</li>
            <li>Developer transfer rules pre-filled</li>
            <li>Paid straight to your PayPal</li>
          </ul>
          <Link href="/sell" className="btn btn-primary">
            Sell a plugin
          </Link>
        </aside>
      </section>

      <nav className="container chips" aria-label="Categories">
        {Object.entries(CATEGORIES).map(([value, label]) => (
          <Link key={value} href={`/browse?cat=${value}`} className="chip">
            {label}
          </Link>
        ))}
      </nav>

      <section className="container home-section">
        <div className="section-head">
          <h2 className="h2">Just listed</h2>
          <Link href="/browse" className="more-link">
            See all listings →
          </Link>
        </div>
        {listings && listings.length > 0 ? (
          <ListingGrid listings={listings} />
        ) : (
          <div className="empty card">
            <p>No listings yet. Be the first to sell a plugin.</p>
            <Link href="/sell" className="btn btn-primary">
              Sell a plugin
            </Link>
          </div>
        )}
      </section>

      <section className="how">
        <div className="container">
          <h2 className="h2">How it works</h2>
          <ol className="steps">
            {STEPS.map((step, i) => (
              <li key={step.title}>
                <span className="step-num">0{i + 1}</span>
                <h3>{step.title}</h3>
                <p>{step.text}</p>
              </li>
            ))}
          </ol>
          <p className="how-more">
            Payment, transfers, safety: <Link href="/faq">read the FAQ →</Link>
          </p>
        </div>
      </section>

      <section className="container home-section">
        <div className="section-head">
          <div>
            <h2 className="h2">Know the transfer rules before you buy</h2>
            <p className="muted">
              Every developer handles license transfers differently. We keep a public database of
              their policies.
            </p>
          </div>
          <Link href="/developers" className="btn">
            All developers
          </Link>
        </div>
        <ul className="dev-teaser">
          {developers?.map((d) => (
            <li key={d.slug}>
              <Link href={`/developers/${d.slug}`} className="dev-card">
                <span className="dev-card-name">{d.name}</span>
                <span className="dev-card-link">Transfer rules →</span>
              </Link>
            </li>
          ))}
        </ul>
      </section>
    </main>
  );
}
