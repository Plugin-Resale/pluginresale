import Link from "next/link";
import { formatPrice, type ListingCard as Listing } from "@/lib/catalog";
import { Rating } from "./Rating";
import { TransferBadge } from "./TransferBadge";

export function ListingCard({ listing }: { listing: Listing }) {
  return (
    <Link href={`/listings/${listing.id}`} className="listing-card">
      <div className="listing-thumb">
        <span className="listing-dev">{listing.developer_name}</span>
        <span className="listing-name">{listing.plugin_name}</span>
      </div>
      <div className="listing-body">
        <div className="listing-row">
          <span className="price">{formatPrice(listing.price_eur)}</span>
          {listing.status === "active" ? (
            <TransferBadge transferable={listing.transferable} />
          ) : (
            <span className="badge badge-muted">
              {listing.status === "reserved" ? "Reserved" : "Sold"}
            </span>
          )}
        </div>
        <span className="listing-seller">
          @{listing.seller_username} ·{" "}
          <Rating avg={listing.seller_avg_rating} count={listing.seller_review_count} />
        </span>
      </div>
    </Link>
  );
}

export function ListingGrid({ listings }: { listings: Listing[] }) {
  return (
    <ul className="listing-grid">
      {listings.map((listing) => (
        <li key={listing.id}>
          <ListingCard listing={listing} />
        </li>
      ))}
    </ul>
  );
}
