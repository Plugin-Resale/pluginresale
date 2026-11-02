import type { Metadata } from "next";
import { signInUrl } from "@/lib/next-path";
import Link from "@/components/Link";
import { DEVELOPER_COLUMNS, type Developer } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/supabase/user";
import { SellForm, type PluginOption } from "./SellForm";

// Indexable: Google (never signed in) gets the public landing below, which is what should rank
// for "sell plugins" / "sell audio plugins". Signed-in sellers get the form at the same URL.
export const metadata: Metadata = {
  title: "Sell Your Audio Plugins: Free Listing, No Commission",
  description:
    "List a plugin license you no longer use in two minutes. Free, no commission, buyers pay you directly via PayPal. The developer's transfer rules and fee shown before you publish.",
  alternates: { canonical: "/sell" },
};

const SELL_STEPS = [
  {
    title: "Pick the plugin",
    text: "Search the catalogue. The developer's transfer rules and fee appear next to the form, so you know what the transfer involves before you publish.",
  },
  {
    title: "Set your price",
    text: "The listed price includes the developer's transfer fee when the seller pays it. Your PayPal email stays private: only the buyer of a confirmed deal sees it.",
  },
  {
    title: "Get paid via PayPal",
    text: "A buyer reserves your listing and pays you directly with PayPal Goods & Services. Plugin Resale never holds the money and takes no commission.",
  },
  {
    title: "Transfer the license",
    text: "Follow the developer's own process. Once the buyer confirms the license arrived, the deal is complete and you rate each other.",
  },
];

async function SellLanding({ here }: { here: string }) {
  const supabase = await createClient();
  const [{ count: transferable }, { count: plugins }] = await Promise.all([
    supabase.from("developers").select("id", { count: "exact", head: true }).eq("transferable", true),
    supabase.from("plugins").select("id", { count: "exact", head: true }),
  ]);
  return (
    <main className="container page sell-landing">
      <h1 className="page-title">Sell your audio plugins</h1>
      <p className="lead">
        Free to list, no commission. Buyers pay you directly via PayPal, and you keep 100% of the
        price.
      </p>
      <p className="sell-cta">
        <Link href={signInUrl(here)} className="btn btn-primary">
          Sign in to list a plugin
        </Link>
        <span className="muted">Email magic link or Google. Takes a minute.</span>
      </p>

      <section className="sell-section">
        <h2 className="section-title">How selling works</h2>
        <ol className="steps sell-steps">
          {SELL_STEPS.map((step, i) => (
            <li key={step.title}>
              <span className="step-num">0{i + 1}</span>
              <h3>{step.title}</h3>
              <p>{step.text}</p>
            </li>
          ))}
        </ol>
      </section>

      <section className="sell-section">
        <h2 className="section-title">What you can sell</h2>
        <p>
          Any perpetual plugin, instrument, sample library or DAW license whose developer allows
          transfers: {transferable ?? "over 100"} of the developers in our{" "}
          <Link href="/developers">transfer rules database</Link> do, and the catalogue covers{" "}
          {plugins ? `${Math.floor(plugins / 100) * 100}+` : "thousands of"} products. If yours is
          missing, you can add it from the form.
        </p>
        <p>
          Not for sale: NFR, educational and most bundled or promotional licenses, which developers
          generally exclude from transfers. See{" "}
          <Link href="/blog/nfr-educational-bundled-licenses-resale">which licenses can&apos;t be resold</Link>.
          Plugin Resale is for private sellers only, not shops or resellers.
        </p>
      </section>

      <section className="sell-section">
        <h2 className="section-title">What it costs</h2>
        <p>
          Nothing from us. The only cost is the developer&apos;s own transfer fee, when there is
          one (FabFilter charges about €10, Waves 5% of the list price, Ableton nothing):
          it is shown before you publish, and you set your price with it in mind. Not sure what to
          ask? Read{" "}
          <Link href="/blog/how-much-is-my-used-plugin-worth">how much a used plugin is worth</Link>.
        </p>
        <p className="how-more">
          Payment, safety, disputes: <Link href="/faq">read the FAQ →</Link>
        </p>
      </section>
    </main>
  );
}

type PluginRow = PluginOption & { image_path: string | null };

export default async function SellPage({ searchParams }: PageProps<"/sell">) {
  // ?plugin=<id>: arrived from "I own it, sell it" (Browse, empty result), plugin preselected.
  const pluginParam = Number((await searchParams).plugin);
  const defaultPluginId = Number.isInteger(pluginParam) && pluginParam > 0 ? pluginParam : undefined;
  const here = defaultPluginId ? `/sell?plugin=${defaultPluginId}` : "/sell";

  const { user, profile } = await getCurrentUser();
  if (!user) return <SellLanding here={here} />;

  if (!profile?.username || !profile.terms_accepted_at) {
    return (
      <main className="narrow">
        <div className="card">
          <h1>One more step</h1>
          <p className="muted">
            Choose a username and accept the Terms of Service before you publish your first
            listing.
          </p>
          <Link href={`/account?next=${encodeURIComponent(here)}`} className="btn btn-primary btn-block">
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
  // Official visuals go in a separate map: most plugins have none, and a null on every row
  // would add tens of KB for phones.
  const PAGE_SIZE = 1000;
  const plugins: PluginOption[] = [];
  const pluginImages: Record<number, string> = {};
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data: page, error } = await supabase
      .from("plugins")
      .select("id, name, category, developer_id, image_path")
      .order("id")
      .range(from, from + PAGE_SIZE - 1)
      .returns<PluginRow[]>();
    if (error) throw error;
    for (const { image_path, ...plugin } of page) {
      plugins.push(plugin);
      if (image_path) pluginImages[plugin.id] = image_path;
    }
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
        pluginImages={pluginImages}
        userId={user.id}
        developers={developers ?? []}
        defaultPaypalEmail={privateProfile?.paypal_email ?? undefined}
        defaultPluginId={defaultPluginId}
      />
    </main>
  );
}
