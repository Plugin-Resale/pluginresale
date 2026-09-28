import { buyNewLink, type Placement } from "@/lib/affiliate";
import type { ShopLinks } from "@/lib/catalog";

const DISCLOSURE = "Affiliate link: we may earn a commission, it doesn't change your price.";

// The "buy it new" fallback, only where no used copy can be bought: plugin page, empty search,
// reserved or sold listing, never next to an active listing. Nothing when no shop page is set.
export function BuyNew({
  links,
  placement,
  compact = false,
}: {
  links: ShopLinks;
  placement: Placement;
  compact?: boolean;
}) {
  const link = buyNewLink(links, placement);
  if (!link) return null;

  if (compact) {
    return (
      <p className="buy-new-inline">
        Or buy it new at{" "}
        <a href={link.url} target="_blank" rel="sponsored noopener">
          {link.shop}
        </a>{" "}
        <span className="muted">(affiliate link)</span>
      </p>
    );
  }

  return (
    <aside className="card buy-new">
      <p>
        <strong>Prefer a new license?</strong>
      </p>
      <a className="btn" href={link.url} target="_blank" rel="sponsored noopener">
        Buy it new at {link.shop} →
      </a>
      <p className="hint">{DISCLOSURE}</p>
    </aside>
  );
}
