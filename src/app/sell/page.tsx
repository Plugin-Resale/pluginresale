import type { Metadata } from "next";
import { signInUrl } from "@/lib/next-path";
import Link from "next/link";
import { redirect } from "next/navigation";
import { DEVELOPER_COLUMNS, type Category, type Developer } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { SellForm } from "./SellForm";

export const metadata: Metadata = { title: "Sell a plugin" };

type PluginRow = { id: number; name: string; category: Category; developer_id: number };

export default async function SellPage() {
  const { user, profile } = await getCurrentUser();
  if (!user) redirect(signInUrl("/sell"));

  if (!profile?.username || !profile.terms_accepted_at) {
    return (
      <main className="narrow">
        <div className="card">
          <h1>One more step</h1>
          <p className="muted">
            Choose a username and accept the Terms of Service before you publish your first
            listing.
          </p>
          <Link href="/account?next=/sell" className="btn btn-primary btn-block">
            Finish setting up my account
          </Link>
        </div>
      </main>
    );
  }

  const supabase = await createClient();

  // Supabase caps a single select at 1,000 rows: with 3,700+ plugins now in the catalogue,
  // one query would silently cut off everything past the 1,000th row, so plugins went
  // missing from this list.
  // Only the columns the search needs are sent to the browser: each developer's transfer
  // rules travel once, in `developers`, not once per plugin (most visitors are on a phone).
  const PAGE_SIZE = 1000;
  const plugins: PluginRow[] = [];
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data: page, error } = await supabase
      .from("plugins")
      .select("id, name, category, developer_id")
      .order("id")
      .range(from, from + PAGE_SIZE - 1)
      .returns<PluginRow[]>();
    if (error) throw error;
    plugins.push(...page);
    if (page.length < PAGE_SIZE) break;
  }

  const [{ data: privateProfile }, { data: developers, error: developersError }] = await Promise.all([
    supabase
      .from("profile_private")
      .select("paypal_email")
      .eq("user_id", user.id)
      .maybeSingle<{ paypal_email: string | null }>(),
    supabase.from("developers").select(DEVELOPER_COLUMNS).order("name").returns<Developer[]>(),
  ]);
  if (developersError) throw developersError;

  return (
    <main className="container page">
      <h1 className="page-title">Sell a plugin</h1>
      <p className="lead">Free to list, no commission. Buyers pay you directly via PayPal.</p>
      <SellForm
        plugins={plugins}
        developers={developers ?? []}
        defaultPaypalEmail={privateProfile?.paypal_email ?? undefined}
      />
    </main>
  );
}
