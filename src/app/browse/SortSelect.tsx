"use client";

// Sort dropdown that applies as soon as a choice is made. The form's submit button stays
// inside <noscript> for browsers without JavaScript.
export function SortSelect({
  options,
  value,
}: {
  options: { value: string; label: string }[];
  value: string;
}) {
  return (
    <select
      id="sort"
      name="sort"
      className="input"
      defaultValue={value}
      onChange={(e) => e.currentTarget.form?.requestSubmit()}
    >
      {options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
        </option>
      ))}
    </select>
  );
}
