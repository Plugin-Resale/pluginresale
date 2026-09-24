"use client";

import { useActionState, useMemo, useState } from "react";
import { TransferBadge } from "@/components/TransferBadge";
import { CATEGORIES, FORMATS, type Category, type Developer } from "@/lib/catalog";
import { createListing, type SellState } from "./actions";

export type PluginOption = { id: number; name: string; category: Category; developer: Developer };

const optionLabel = (p: PluginOption) => `${p.developer.name} ${p.name}`;

export function SellForm({
  plugins,
  developers,
  defaultPaypalEmail,
}: {
  plugins: PluginOption[];
  developers: Developer[];
  defaultPaypalEmail?: string;
}) {
  const [state, action, pending] = useActionState<SellState, FormData>(createListing, {});
  const values = state.values;

  const byLabel = useMemo(
    () => new Map(plugins.map((p) => [optionLabel(p).toLowerCase(), p])),
    [plugins],
  );
  const initial = plugins.find((p) => String(p.id) === values?.pluginId);
  const [query, setQuery] = useState(initial ? optionLabel(initial) : "");
  const selected = byLabel.get(query.trim().toLowerCase()) ?? null;

  // Typed a plugin that isn't in the catalogue yet: pick its developer (still from our
  // list, since that's where the transfer-rules policy lives) and add it on the fly.
  const [newDeveloperId, setNewDeveloperId] = useState(values?.developerId ?? "");
  const [newPluginName, setNewPluginName] = useState(values?.newPluginName ?? "");
  const [newCategory, setNewCategory] = useState<Category | "">(
    (values?.newPluginCategory as Category) ?? "",
  );
  const newDeveloper = developers.find((d) => String(d.id) === newDeveloperId) ?? null;

  const activeDeveloper = selected?.developer ?? newDeveloper;
  const blocked = activeDeveloper?.transferable === false;
  const unverified = activeDeveloper != null && activeDeveloper.transferable === null;

  return (
    <div className="sell-layout">
      <form action={action} className="sell-form">
        <div className="field">
          <label className="field-label" htmlFor="plugin">
            Plugin
          </label>
          <p className="hint">Start typing and pick your plugin from the list.</p>
          <input
            id="plugin"
            className="input input-lg"
            list="plugin-options"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="e.g. FabFilter Pro-Q 3"
            autoComplete="off"
            required
          />
          <datalist id="plugin-options">
            {plugins.map((p) => (
              <option key={p.id} value={optionLabel(p)} />
            ))}
          </datalist>
          <input type="hidden" name="plugin_id" value={selected?.id ?? ""} />
          {selected && <p className="hint">Category: {CATEGORIES[selected.category]}</p>}
        </div>

        {query && !selected && (
          <div className="card new-plugin">
            <p className="hint">
              Not in the list? Add it: pick the developer and a category, and we&apos;ll add{" "}
              <strong>{query}</strong> to the catalogue for everyone.
            </p>
            <div className="field">
              <label className="field-label" htmlFor="developer_id">
                Developer
              </label>
              <select
                id="developer_id"
                name="developer_id"
                className="input"
                value={newDeveloperId}
                onChange={(e) => setNewDeveloperId(e.target.value)}
                required
              >
                <option value="">Choose a developer…</option>
                {developers.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="field-row">
              <div className="field">
                <label className="field-label" htmlFor="new_plugin_name">
                  Plugin name
                </label>
                <input
                  id="new_plugin_name"
                  name="new_plugin_name"
                  className="input"
                  value={newPluginName || query}
                  onChange={(e) => setNewPluginName(e.target.value)}
                  maxLength={80}
                  required
                />
              </div>
              <div className="field">
                <label className="field-label" htmlFor="new_plugin_category">
                  Category
                </label>
                <select
                  id="new_plugin_category"
                  name="new_plugin_category"
                  className="input"
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value as Category)}
                  required
                >
                  <option value="">Choose a category…</option>
                  {Object.entries(CATEGORIES).map(([value, label]) => (
                    <option key={value} value={value}>
                      {label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        )}

        <div className="field-row">
          <div className="field">
            <label className="field-label" htmlFor="version">
              Version <span className="optional">(optional)</span>
            </label>
            <input
              id="version"
              name="version"
              className="input"
              placeholder="e.g. 3.2"
              maxLength={30}
              defaultValue={values?.version}
            />
          </div>
          <div className="field">
            <label className="field-label" htmlFor="price">
              Price (€)
            </label>
            <input
              id="price"
              name="price"
              className="input"
              inputMode="decimal"
              placeholder="e.g. 95"
              required
              defaultValue={values?.price}
            />
          </div>
        </div>

        <fieldset className="field">
          <legend className="field-label">
            Formats <span className="optional">(optional)</span>
          </legend>
          <div className="checks-inline">
            {FORMATS.map((f) => (
              <label key={f} className="check">
                <input
                  type="checkbox"
                  name="formats"
                  value={f}
                  defaultChecked={values?.formats.includes(f)}
                />
                {f}
              </label>
            ))}
          </div>
        </fieldset>

        <div className="field">
          <label className="field-label" htmlFor="description">
            Description <span className="optional">(optional)</span>
          </label>
          <textarea
            id="description"
            name="description"
            className="input textarea"
            maxLength={2000}
            placeholder="Why you're selling, purchase date, anything the buyer should know."
            defaultValue={values?.description}
          />
        </div>

        <div className="field">
          <label className="field-label" htmlFor="paypal_email">
            PayPal email
          </label>
          <p className="hint">
            Where buyers send the payment. Only shown to the buyer after they click Buy. We&apos;ll
            remember it for your next listing.
          </p>
          <input
            id="paypal_email"
            name="paypal_email"
            type="email"
            className="input"
            autoComplete="email"
            placeholder="you@example.com"
            required
            defaultValue={values?.paypalEmail ?? defaultPaypalEmail}
          />
        </div>

        <div className="card checks">
          <label className="check">
            <input type="checkbox" name="owns_license" required />I own this license and it is
            not NFR, educational or bundled with hardware.
          </label>
          <label className="check">
            <input type="checkbox" name="will_transfer" required />I will uninstall the plugin and
            complete the developer&apos;s transfer after payment.
          </label>
          <label className="check">
            <input type="checkbox" name="private_seller" required />I&apos;m selling as a private
            individual, not as part of a business.
          </label>
        </div>

        {state.error && <p className="notice notice-error">{state.error}</p>}

        <button className="btn btn-primary btn-lg" type="submit" disabled={pending || blocked}>
          {pending ? "Publishing…" : "Publish listing"}
        </button>
      </form>

      <aside className="rules-panel" aria-live="polite">
        <span className="rules-panel-eyebrow">Auto-filled from our database</span>
        {activeDeveloper ? (
          <>
            <h2>{activeDeveloper.name} transfer rules</h2>
            <TransferBadge transferable={activeDeveloper.transferable} />
            {blocked ? (
              <p>{activeDeveloper.restrictions ?? "This developer doesn't allow transfers."}</p>
            ) : unverified ? (
              <p>
                We haven&apos;t found an official transfer policy for {activeDeveloper.name}.
                Before listing, check with {activeDeveloper.name} that your license can be
                transferred, and how.{" "}
                {activeDeveloper.restrictions}
              </p>
            ) : (
              <dl>
                <dt>Developer fee</dt>
                <dd>{activeDeveloper.fee ?? "Not stated"}</dd>
                {activeDeveloper.who_pays && (
                  <>
                    <dt>Who pays</dt>
                    <dd>{activeDeveloper.who_pays}</dd>
                  </>
                )}
                <dt>Process</dt>
                <dd>{activeDeveloper.process ?? "Not stated"}</dd>
                {activeDeveloper.restrictions && (
                  <>
                    <dt>Restrictions</dt>
                    <dd>{activeDeveloper.restrictions}</dd>
                  </>
                )}
              </dl>
            )}
            {activeDeveloper.source_url && (
              <a href={activeDeveloper.source_url} target="_blank" rel="noopener noreferrer">
                Official source
              </a>
            )}
          </>
        ) : (
          <>
            <h2>Transfer rules</h2>
            <p>Pick your plugin: we&apos;ll show the developer&apos;s transfer fee and process here.</p>
          </>
        )}
        <p className="rules-panel-foot">
          Rules can change. Check the developer&apos;s site before you sell.
        </p>
      </aside>
    </div>
  );
}
