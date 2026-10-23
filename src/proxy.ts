import type { NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/proxy";

export async function proxy(request: NextRequest) {
  return updateSession(request);
}

// The proxy only refreshes the Supabase session, so it only runs for requests that carry one:
// anonymous visitors and bots (the vast majority) skip it and cost one function call, not two.
// The cookie is named after the Supabase project ref and split into .0, .1... when large;
// a matcher must be a literal, so the ref is written out (change it if the project changes).
export const config = {
  matcher: [
    {
      // Skip static files, images and the files only crawlers read.
      source:
        "/((?!_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico)$).*)",
      // Runs unless every one of these is missing.
      missing: [
        { type: "cookie", key: "sb-pwseqxvdvrkejeayroan-auth-token" },
        { type: "cookie", key: "sb-pwseqxvdvrkejeayroan-auth-token.0" },
      ],
    },
  ],
};
