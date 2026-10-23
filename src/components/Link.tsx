import NextLink from "next/link";
import type { ComponentProps } from "react";

// next/link with prefetching off by default. Every page is rendered per request (the header
// reads the session), so each prefetch is a full server render: with it on, one page view
// cost ~45 function calls (every header/footer link, twice) and ate the Vercel CPU quota.
// Pages are rendered on click anyway, so turning it off costs almost nothing in speed.
// Pass prefetch={null} to get Next's default back on a specific link.
export default function Link({ prefetch = false, ...props }: ComponentProps<typeof NextLink>) {
  return <NextLink prefetch={prefetch} {...props} />;
}
