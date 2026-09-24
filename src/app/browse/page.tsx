import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { ListingGrid } from "@/components/ListingCard";
import { CATEGORIES, type Category, type ListingCard } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";
import { DeveloperFilter } from "./DeveloperFilter";
import { FiltersDisclosure } from "./FiltersDisclosure";

export const metadata: Metadata = {
  title: "Browse second-hand plugin licenses",
  description: "Used audio plugin licenses for sale: EQ, compression, reverb, synths and more.",
};

const PAGE_SIZE = 24;

const SORTS = {
  newest: { label: "Newest", column: "created_at", ascending: false },
  "price-asc": { label: "Price: low to high", column: "price_eur", ascending: true },
  "price-desc": { label: "Price: high to low", column: "price_eur", ascending: false },
} as const;
type Sort = keyof typeof SORTS;

type Params = Record<string, string | string[] | undefined>;

const list = (v: string | string[] | undefined) => (v === undefined ? [] : [v].flat());
const first = (v: string | string[] | undefined) => list(v)[0] ?? "";

function parseFilters(params: Params) {
  const price = (v: string) => (/^\d+(\.\d+)?$/.test(v) ? Number(v) : null);
  const sort = first(params.sort);
  return {
    // Keep only characters that are safe inside a PostgREST filter.
    q: first(params.q).replace(/[^\p{L}\p{N}\s.'-]/gu, " ").trim().slice(0, 60),
    categories: list(params.cat).filter((c): c is Category => c in CATEGORIES),
    developers: list(params.dev).filter((d) => /^[a-z0-9-]+$/.test(d)),
    min: price(first(params.min)),
    max: price(first(params.max)),
    transferableOnly: first(params.transferable) === "1",
    noFee: first(params.nofee) === "1",
    sort: (sort in SORTS ? sort : "newest") as Sort,
    page: Math.max(1, Math.floor(Number(first(params.page))) || 1),
  };
}

type Filters = ReturnType<typeof parseFilters>;

function pageHref(filters: Filters, page: number) {
  const qs = new URLSearchParams();
  if (filters.q) qs.set("q", filters.q);
  filters.categories.forEach((c) => qs.append("cat", c));
  filters.developers.forEach((d) => qs.append("dev", d));
  if (filters.min !== null) qs.set("min", String(filters.min));
  if (filters.max !== null) qs.set("max", String(filters.max));
  if (filters.transferableOnly) qs.set("transferable", "1");
  if (filters.noFee) qs.set("nofee", "1");
  if (filters.sort !== "newest") qs.set("sort", filters.sort);
  if (page > 1) qs.set("page", String(page));
  const s = qs.toString();
  return s ? `/browse?${s}` : "/browse";
}

export default async function BrowsePage({ searchParams }: PageProps<"/browse">) {
  const filters = parseFilters(await searchParams);
  const supabase = await createClient();

  let query = supabase.from("listing_cards").select("*", { count: "exact" }).eq("status", "active");
  if (filters.q) {
    const term = `*${filters.q}*`;
    query = query.or(`plugin_name.ilike.${term},developer_name.ilike.${term}`);
  }
  if (filters.categories.length) query = query.in("category", filters.categories);
  if (filters.developers.length) query = query.in("developer_slug", filters.developers);
  if (filters.min !== null) query = query.gte("price_eur", filters.min);
  if (filters.max !== null) query = query.lte("price_eur", filters.max);
  if (filters.transferableOnly) query = query.eq("transferable", true);
  if (filters.noFee) query = query.eq("no_fee", true);

  const sort = SORTS[filters.sort];
  const from = (filters.page - 1) * PAGE_SIZE;
  const [{ data: listings, count, error }, { data: developers }] = await Promise.all([
    query
      .order(sort.column, { ascending: sort.ascending })
      .order("id", { ascending: false })
      .range(from, from + PAGE_SIZE - 1)
      .returns<ListingCard[]>(),
    supabase.from("developers").select("name, slug").not("transferable", "is", false).order("name"),
  ]);
  // Page past the last result (e.g. an old link): go back to the first page.
  if (error?.code === "PGRST103") redirect(pageHref(filters, 1));
  if (error) throw error;

  const total = count ?? 0;
  const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  const title =
    filters.categories.length === 1 ? `${CATEGORIES[filters.categories[0]]} plugins` : "Browse";

  return (
    <main className="container page browse-layout">
      <FiltersDisclosure>
        <form action="/browse" className="filters-form">
          <fieldset>
            <legend>
              <label htmlFor="browse-q">Search</label>
            </legend>
            <input
              id="browse-q"
              name="q"
              className="input"
              placeholder="Plugin or developer"
              defaultValue={filters.q}
            />
          </fieldset>
          <input type="hidden" name="sort" value={filters.sort} />

          <fieldset>
            <legend>Category</legend>
            {Object.entries(CATEGORIES).map(([value, label]) => (
              <label key={value} className="check">
                <input
                  type="checkbox"
                  name="cat"
                  value={value}
                  defaultChecked={filters.categories.includes(value as Category)}
                />
                {label}
              </label>
            ))}
          </fieldset>

          <DeveloperFilter developers={developers ?? []} selected={filters.developers} />

          <fieldset>
            <legend>Price (€)</legend>
            <div className="price-range">
              <label htmlFor="min" className="sr-only">
                Minimum price
              </label>
              <input
                id="min"
                name="min"
                className="input"
                inputMode="decimal"
                placeholder="Min"
                defaultValue={filters.min ?? ""}
              />
              <span aria-hidden="true">–</span>
              <label htmlFor="max" className="sr-only">
                Maximum price
              </label>
              <input
                id="max"
                name="max"
                className="input"
                inputMode="decimal"
                placeholder="Max"
                defaultValue={filters.max ?? ""}
              />
            </div>
          </fieldset>

          <fieldset>
            <legend>Transfer</legend>
            <label className="check">
              <input
                type="checkbox"
                name="transferable"
                value="1"
                defaultChecked={filters.transferableOnly}
              />
              Transferable only
            </label>
            <label className="check">
              <input type="checkbox" name="nofee" value="1" defaultChecked={filters.noFee} />
              No developer fee
            </label>
          </fieldset>

          <button className="btn btn-primary btn-block" type="submit">
            Apply filters
          </button>
          <Link href="/browse" className="reset-link">
            Reset all
          </Link>
        </form>
      </FiltersDisclosure>

      <div className="browse-results">
        <div className="browse-head">
          <div>
            <h1 className="section-title">{title}</h1>
            <p className="muted">
              {filters.q && <>Results for “{filters.q}” · </>}
              {total} {total === 1 ? "listing" : "listings"}
            </p>
          </div>
          <form action="/browse" className="sort-form">
            {Object.entries({
              q: filters.q,
              min: filters.min ?? "",
              max: filters.max ?? "",
              transferable: filters.transferableOnly ? "1" : "",
              nofee: filters.noFee ? "1" : "",
            })
              .filter(([, v]) => v !== "")
              .map(([k, v]) => (
                <input key={k} type="hidden" name={k} value={v} />
              ))}
            {filters.categories.map((c) => (
              <input key={c} type="hidden" name="cat" value={c} />
            ))}
            {filters.developers.map((d) => (
              <input key={d} type="hidden" name="dev" value={d} />
            ))}
            <label htmlFor="sort" className="muted">
              Sort by
            </label>
            <select id="sort" name="sort" className="input" defaultValue={filters.sort}>
              {Object.entries(SORTS).map(([value, s]) => (
                <option key={value} value={value}>
                  {s.label}
                </option>
              ))}
            </select>
            <button className="btn" type="submit">
              Sort
            </button>
          </form>
        </div>

        {listings.length > 0 ? (
          <ListingGrid listings={listings} />
        ) : (
          <div className="empty card">
            <p>No listings match these filters yet.</p>
            <Link href="/sell" className="btn btn-primary">
              Sell a plugin
            </Link>
          </div>
        )}

        {pages > 1 && (
          <nav aria-label="Pagination" className="pagination">
            {filters.page > 1 && (
              <Link className="btn" href={pageHref(filters, filters.page - 1)}>
                ← Previous
              </Link>
            )}
            <span className="muted">
              Page {filters.page} of {pages}
            </span>
            {filters.page < pages && (
              <Link className="btn" href={pageHref(filters, filters.page + 1)}>
                Next →
              </Link>
            )}
          </nav>
        )}
      </div>
    </main>
  );
}
