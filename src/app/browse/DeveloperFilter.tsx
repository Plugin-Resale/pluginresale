"use client";

import { useState } from "react";

const normalize = (s: string) =>
  s
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase();

// Developer checkboxes with a search box. Hidden checkboxes are still submitted,
// and ticked developers always stay visible so a selection never disappears.
export function DeveloperFilter({
  developers,
  selected,
}: {
  developers: { name: string; slug: string }[];
  selected: string[];
}) {
  const [query, setQuery] = useState("");
  const [checked, setChecked] = useState(() => new Set(selected));
  const q = normalize(query.trim());
  const visible = (d: { name: string; slug: string }) =>
    !q || checked.has(d.slug) || normalize(d.name).includes(q);
  const shown = developers.filter(visible).length;

  return (
    <fieldset>
      <legend>Developer</legend>
      <label htmlFor="dev-search" className="sr-only">
        Search developers
      </label>
      <input
        id="dev-search"
        className="input dev-search"
        type="search"
        placeholder={`Search ${developers.length} developers`}
        autoComplete="off"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onKeyDown={(e) => {
          // Enter filters the list instead of submitting the whole form.
          if (e.key === "Enter") e.preventDefault();
        }}
      />
      <div className="dev-list">
        {developers.map((d) => (
          <label key={d.slug} className="check" hidden={!visible(d)}>
            <input
              type="checkbox"
              name="dev"
              value={d.slug}
              checked={checked.has(d.slug)}
              onChange={(e) => {
                const next = new Set(checked);
                if (e.target.checked) next.add(d.slug);
                else next.delete(d.slug);
                setChecked(next);
              }}
            />
            {d.name}
          </label>
        ))}
        {shown === 0 && <p className="hint">No developer matches “{query}”.</p>}
      </div>
    </fieldset>
  );
}
