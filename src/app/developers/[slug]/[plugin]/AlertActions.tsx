"use client";

import { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "@/components/Link";
import { createClient } from "@/lib/supabase/client";
import { createAlert } from "../../../browse/actions";

// The only parts of a plugin page that depend on who is looking: the "Alert set" notice that
// comes back from createAlert (?alert=set|error) and whether this user already has an alert.
// Both are resolved in the browser so the page itself can be rendered once and served from the
// CDN (it is the most crawled page type: ~3,700 URLs).

export function AlertNotice() {
  const notice = useSearchParams().get("alert");
  if (notice === "set") {
    return (
      <p className="notice notice-success">
        Alert set. We&apos;ll email you as soon as someone lists it. Manage your alerts in{" "}
        <Link href="/account#alerts">My account</Link>.
      </p>
    );
  }
  if (notice === "error") {
    return <p className="notice notice-error">Something went wrong. Please try again.</p>;
  }
  return null;
}

export function AlertButton({ pluginId, back }: { pluginId: number; back: string }) {
  const [alertSet, setAlertSet] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      if (!document.cookie.includes("sb-")) return;
      const supabase = createClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session || cancelled) return;
      // RLS: a user only sees their own alerts.
      const { data } = await supabase
        .from("listing_alerts")
        .select("plugin_id")
        .eq("plugin_id", pluginId)
        .maybeSingle();
      if (!cancelled && data) setAlertSet(true);
    })();
    return () => {
      cancelled = true;
    };
  }, [pluginId]);

  if (alertSet) return <span className="badge badge-ok">✓ Alert set</span>;
  return (
    // Signed out: createAlert sends them to sign in first, then back here.
    <form action={createAlert}>
      <input type="hidden" name="plugin_id" value={pluginId} />
      <input type="hidden" name="back" value={back} />
      <button className="btn btn-primary" type="submit">
        Alert me
      </button>
    </form>
  );
}
