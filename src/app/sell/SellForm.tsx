"use client";

import { useActionState, useId, useMemo, useState, type KeyboardEvent } from "react";
import { TransferBadge } from "@/components/TransferBadge";
import { CATEGORIES, FORMATS, type Category, type Developer } from "@/lib/catalog";
import { createListing, type SellState } from "./actions";

export type PluginOption = { id: number; name: string; category: Category; developer_id: number };

type SearchEntry = { plugin: PluginOption; label: string; words: string; squashed: string };

const MAX_RESULTS = 8;

// Lowercase, accents and punctuation dropped: "Pro-Q 3" and "pro q3" find the same plugin.
const normalize = (text: string) =>
  text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();

export function SellForm({
  plugins,
  developers,
  defaultPaypalEmail,
  defaultPluginId,
}: {
  plugins: PluginOption[];
  developers: Developer[];
  defaultPaypalEmail?: string;
  defaultPluginId?: number;
}) {
  const [state, action, pending] = useActionState<SellState, FormData>(createListing, {});
  const values = state.values;
  const listId = useId();

  const developerById = useMemo(() => new Map(developers.map((d) => [d.id, d])), [developers]);

  // Search index, built once: "<developer> <plugin>" as typed words and without any spaces.
  const entries = useMemo<SearchEntry[]>(
    () =>
      plugins
        .map((plugin) => {
          const label = `${developerById.get(plugin.developer_id)?.name ?? ""} ${plugin.name}`.trim();
          const words = normalize(label);
          return { plugin, label, words, squashed: words.replace(/ /g, "") };
        })
        .sort((a, b) => a.label.localeCompare(b.label)),
    [plugins, developerById],
  );

  const initialId = values ? values.pluginId : String(defaultPluginId ?? "");
  const initial = entries.find((e) => String(e.plugin.id) === initialId) ?? null;
  const [query, setQuery] = useState(initial?.label ?? values?.newPluginName ?? "");
  const [selected, setSelected] = useState<SearchEntry | null>(initial);
  const [open, setOpen] = useState(false);
  const [highlight, setHighlight] = useState(0);
  const [adding, setAdding] = useState(Boolean(values?.developerId));

  // Every typed word must appear, in the name or the developer. Plugin names starting with
  // what was typed come first, then shorter names (the base product before its add-ons).
  const results = useMemo(() => {
    const tokens = normalize(query).split(" ").filter(Boolean);
    if (tokens.length === 0 || selected) return [];
    return entries
      .filter((e) => tokens.every((t) => e.words.includes(t) || e.squashed.includes(t)))
      .sort((a, b) => {
        const aStarts = normalize(a.plugin.name).startsWith(tokens[0]) ? 0 : 1;
        const bStarts = normalize(b.plugin.name).startsWith(tokens[0]) ? 0 : 1;
        return aStarts - bStarts || a.label.length - b.label.length;
      })
      .slice(0, MAX_RESULTS);
  }, [entries, query, selected]);

  const typed = query.trim().length > 0;
  const showAdd = typed && !selected && (adding || results.length === 0);
  const showList = open && typed && !selected && !adding && results.length > 0;

  const choose = (entry: SearchEntry) => {
    setSelected(entry);
    setQuery(entry.label);
    setAdding(false);
    setOpen(false);
  };
  const startAdding = () => {
    setAdding(true);
    setOpen(false);
  };

  // Typed a plugin that isn't in the catalogue yet: pick its developer (still from our
  // list, since that's where the transfer-rules policy lives) and add it on the fly.
  const [newDeveloperId, setNewDeveloperId] = useState(values?.developerId ?? "");
  const [newPluginName, setNewPluginName] = useState(values?.newPluginName ?? "");
  const [newCategory, setNewCategory] = useState<Category | "">(
    (values?.newPluginCategory as Category) ?? "",
  );
  const newDeveloper = developers.find((d) => String(d.id) === newDeveloperId) ?? null;

  const activeDeveloper = selected
    ? developerById.get(selected.plugin.developer_id) ?? null
    : showAdd
    ? newDeveloper
    : null;
  const blocked = activeDeveloper?.transferable === false;
  const unverified = activeDeveloper != null && activeDeveloper.transferable === null;

  // Options: the matching plugins, then "Not in the list? Add it" as the last one.
  const optionCount = showList ? results.length + 1 : 0;
  const onKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (!showList) {
      if (e.key === "ArrowDown" && typed && !selected) setOpen(true);
      return;
    }
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlight((h) => (h + 1) % optionCount);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlight((h) => (h - 1 + optionCount) % optionCount);
    } else if (e.key === "Enter") {
      e.preventDefault();
      if (highlight < results.length) choose(results[highlight]);
      else startAdding();
    } else if (e.key === "Escape") {
      setOpen(false);
    }
  };

  return (
    <div className="sell-layout">
      <form action={action} className="sell-form">
        <div className="field">
          <label className="field-label" htmlFor="plugin">
            Plugin
          </label>
          <p className="hint">Start typing, then pick your plugin from the list.</p>
          <div className="combo">
            <input
              id="plugin"
              className="input input-lg"
              role="combobox"
              aria-expanded={showList}
              aria-controls={listId}
              aria-autocomplete="list"
              aria-activedescendant={showList ? `${listId}-${highlight}` : undefined}
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setSelected(null);
                setAdding(false);
                setOpen(true);
                setHighlight(0);
              }}
              onFocus={() => setOpen(true)}
              // Closed a moment later, so a tap on an option still lands before the list goes.
              onBlur={() => setTimeout(() => setOpen(false), 150)}
              onKeyDown={onKeyDown}
              placeholder="e.g. FabFilter Pro-Q 3"
              autoComplete="off"
              autoCorrect="off"
              autoCapitalize="off"
              spellCheck={false}
              enterKeyHint="search"
              required
            />
            {selected && (
              <button
                type="button"
                className="combo-clear"
                aria-label="Clear the plugin"
                onClick={() => {
                  setSelected(null);
                  setQuery("");
                  document.getElementById("plugin")?.focus();
                }}
              >
                ×
              </button>
            )}
            {showList && (
              // onMouseDown + preventDefault keeps the focus in the input, so the tap
              // registers before the list closes on blur.
              <ul id={listId} role="listbox" className="combo-list" onMouseDown={(e) => e.preventDefault()}>
                {results.map((entry, i) => (
                  <li
                    key={entry.plugin.id}
                    id={`${listId}-${i}`}
                    role="option"
                    aria-selected={i === highlight}
                    className="combo-option"
                    onClick={() => choose(entry)}
                    onMouseEnter={() => setHighlight(i)}
                  >
                    <span className="combo-dev">
                      {developerById.get(entry.plugin.developer_id)?.name}
                    </span>{" "}
                    {entry.plugin.name}
                  </li>
                ))}
                <li
                  id={`${listId}-${results.length}`}
                  role="option"
                  aria-selected={highlight === results.length}
                  className="combo-option combo-add"
                  onClick={startAdding}
                  onMouseEnter={() => setHighlight(results.length)}
                >
                  Not in the list? Add <strong>{query.trim()}</strong>
                </li>
              </ul>
            )}
          </div>
          <input type="hidden" name="plugin_id" value={selected?.plugin.id ?? ""} />
          {selected && <p className="hint">Category: {CATEGORIES[selected.plugin.category]}</p>}
        </div>

        {showAdd && (
          <div className="card new-plugin">
            <p className="hint">
              Not in the list? Add it: pick the developer and a category, and we&apos;ll add{" "}
              <strong>{newPluginName || query.trim()}</strong> to the catalogue for everyone.
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
                  value={newPluginName || query.trim()}
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
            placeholder="Example: Bought in March 2024 from the developer's store, registered to my account (not iLok). Selling because I switched to another EQ. I'll start the transfer as soon as payment arrives."
            defaultValue={values?.description}
          />
          <p className="hint">
            Buyers trust a listing more when they know where the license was bought, where it is
            registered (developer account, iLok…), why you&apos;re selling, and how fast you&apos;ll
            start the transfer.
          </p>
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
