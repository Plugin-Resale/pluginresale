import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { DEVELOPER_COLUMNS, type Category, type Developer } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { SellForm, type PluginOption } from "./SellForm";

export const metadata: Metadata = { title: "Sell a plugin" };

type PluginRow = { id: number; name: string; category: Category; developers: Developer };

export default async function SellPage() {
  const { user, profile } = await getCurrentUser();
  if (!user) redirect("/signin");

  if (!profile?.username || !profile.terms_accepted_at) {
    return (
      <main className="narrow">
        <div className="card">
          <h1>One more step</h1>
          <p className="muted">
            Choose a username and accept the Terms of Service before you publish your first
            listing.
          </p>
          <Link href="/account" className="btn btn-primary btn-block">
            Finish setting up my account
          </Link>
        </div>
      </main>
    );
  }

  const supabase = await createClient();
  const { data, error } = await supabase
    .from("plugins")
    .select(`id, name, category, developers!inner (${DEVELOPER_COLUMNS})`)
    .order("name")
    .returns<PluginRow[]>();
  if (error) throw error;

  const plugins: PluginOption[] = data
    .map((p) => ({ id: p.id, name: p.name, category: p.category, developer: p.developers }))
    .sort((a, b) => `${a.developer.name} ${a.name}`.localeCompare(`${b.developer.name} ${b.name}`));

  const { data: privateProfile } = await supabase
    .from("profile_private")
    .select("paypal_email")
    .eq("user_id", user.id)
    .maybeSingle<{ paypal_email: string | null }>();

  return (
    <main className="container page">
      <h1 className="page-title">Sell a plugin</h1>
      <p className="lead">Free to list, no commission. Buyers pay you directly via PayPal.</p>
      <SellForm plugins={plugins} defaultPaypalEmail={privateProfile?.paypal_email ?? undefined} />
    </main>
  );
}
