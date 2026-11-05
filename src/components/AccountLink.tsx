"use client";

import { useEffect, useState } from "react";
import Link from "@/components/Link";
import { createClient } from "@/lib/supabase/client";

// The "Sign in" / "@username" link of the header. It reads the session in the browser so the
// server never has to: every public page can then be rendered once and served from the CDN
// instead of running as a function for each visit (the header used to read the session cookie,
// which made every page dynamic). Nothing is shown until the session is known, to avoid a flash
// of "Sign in" for signed-in users; the slot keeps its width so the header does not jump.
type State = { kind: "loading" } | { kind: "anonymous" } | { kind: "user"; username: string | null };

export function AccountLink() {
  const [state, setState] = useState<State>({ kind: "loading" });

  useEffect(() => {
    let cancelled = false;
    (async () => {
      // No Supabase cookie at all: signed out, no need to even create the client.
      if (!document.cookie.includes("sb-")) {
        setState({ kind: "anonymous" });
        return;
      }
      const supabase = createClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (cancelled) return;
      if (!session) {
        setState({ kind: "anonymous" });
        return;
      }
      const { data: profile } = await supabase
        .from("profiles")
        .select("username")
        .eq("id", session.user.id)
        .maybeSingle<{ username: string | null }>();
      if (!cancelled) setState({ kind: "user", username: profile?.username ?? null });
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (state.kind === "loading") {
    return <span className="nav-link account-link-placeholder" aria-hidden="true" />;
  }
  if (state.kind === "user") {
    return (
      <Link href="/account" className="nav-link">
        {state.username ? `@${state.username}` : "My account"}
      </Link>
    );
  }
  return (
    <Link href="/signin" className="nav-link">
      Sign in
    </Link>
  );
}
