export function Rating({ avg, count }: { avg: number | null; count: number }) {
  if (!avg || count === 0) {
    return <span className="rating rating-empty">No reviews yet</span>;
  }
  return (
    <span className="rating">
      ★ {avg.toFixed(1)} <span className="muted">({count})</span>
    </span>
  );
}
