import Link from "next/link";
import { BuyNew } from "@/components/BuyNew";
import type { ShopLinks } from "@/lib/catalog";
import { createAlert } from "./actions";

// Looked up on `plugins` after the search: search_plugins doesn't return them.
export type PluginLinks = ShopLinks & { slug: string | null };

export type PluginMatch = PluginLinks & {
  id: number;
  name: string;
  developer_name: string;
  developer_slug: string;
  transferable: boolean | null;
};

// Empty search result: instead of a dead end, the catalogue plugins that match the search,
// each with an email alert for when someone lists it and a shortcut to sell it.
export function NoResults({
  q,
  back,
  matches,
  alerted,
  signedIn,
}: {
  q: string;
  back: string;
  matches: PluginMatch[];
  alerted: Set<number>;
  signedIn: boolean;
}) {
  return (
    <div className="empty card no-results">
      <p>
        <strong>No one is selling “{q}” right now.</strong>
      </p>
      {matches.length > 0 ? (
        <>
          <p className="muted">Get an email as soon as someone lists it:</p>
          <ul className="alert-list">
            {matches.map((p) => (
              <li key={p.id}>
                <div className="alert-name">
                  <span className="alert-dev">{p.developer_name}</span>
                  <strong>
                    {p.slug ? (
                      <Link href={`/developers/${p.developer_slug}/${p.slug}`}>{p.name}</Link>
                    ) : (
                      p.name
                    )}
                  </strong>
                  <BuyNew links={p} placement="browse" compact />
                </div>
                {p.transferable === false ? (
                  <p className="muted alert-blocked">
                    {p.developer_name} doesn&apos;t allow license transfers, so it can&apos;t be
                    resold.{" "}
                    <Link href={`/developers/${p.developer_slug}`}>Transfer rules</Link>
                  </p>
                ) : (
                  <div className="alert-actions">
                    {alerted.has(p.id) ? (
                      <span className="badge badge-ok">✓ Alert set</span>
                    ) : (
                      <form action={createAlert}>
                        <input type="hidden" name="plugin_id" value={p.id} />
                        <input type="hidden" name="back" value={back} />
                        <button className="btn btn-primary" type="submit">
                          Alert me
                        </button>
                      </form>
                    )}
                    <Link href={`/sell?plugin=${p.id}`} className="btn">
                      I own it, sell it
                    </Link>
                    <Link href={`/developers/${p.developer_slug}`} className="alert-rules">
                      Transfer rules
                    </Link>
                  </div>
                )}
              </li>
            ))}
          </ul>
          {!signedIn && (
            <p className="hint">You&apos;ll sign in with your email first, no password needed.</p>
          )}
        </>
      ) : (
        <>
          <p className="muted">
            It isn&apos;t in our catalogue yet either. If you own it, you can add it when you list
            it.
          </p>
          <Link href="/sell" className="btn btn-primary">
            Sell a plugin
          </Link>
        </>
      )}
    </div>
  );
}
