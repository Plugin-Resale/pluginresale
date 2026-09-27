import Link from "next/link";
import { formatPrice, type ListingCard as Listing } from "@/lib/catalog";
import { pluginImageUrl } from "@/lib/images";
import { Rating } from "./Rating";
import { TransferBadge } from "./TransferBadge";

export function ListingCard({ listing }: { listing: Listing }) {
  const image = listing.plugin_image_path;
  return (
    <Link href={`/listings/${listing.id}`} className="listing-card">
      {image ? (
        <div className="listing-thumb listing-thumb-image">
          {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
          <img
            src={pluginImageUrl(image)}
            alt={`${listing.developer_name} ${listing.plugin_name}`}
            loading="lazy"
          />
        </div>
      ) : (
        <div className="listing-thumb">
          <span className="listing-dev">{listing.developer_name}</span>
          <span className="listing-name">{listing.plugin_name}</span>
        </div>
      )}
      <div className="listing-body">
        {image && (
          <span className="listing-title">
            <span className="listing-title-dev">{listing.developer_name}</span>
            {listing.plugin_name}
          </span>
        )}
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
        {listing.proof_image_path && (
          <span className="badge badge-muted proof-badge">License proof attached</span>
        )}
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
