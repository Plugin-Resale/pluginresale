"use client";

import { useEffect, useRef, type ReactNode } from "react";

// Filters are always open on desktop and collapsed behind "Filters" on phones.
export function FiltersDisclosure({ children }: { children: ReactNode }) {
  const ref = useRef<HTMLDetailsElement>(null);

  useEffect(() => {
    const desktop = window.matchMedia("(min-width: 900px)");
    const sync = () => {
      if (ref.current) ref.current.open = desktop.matches;
    };
    sync();
    desktop.addEventListener("change", sync);
    return () => desktop.removeEventListener("change", sync);
  }, []);

  return (
    <details ref={ref} className="filters" open>
      <summary className="btn">Filters</summary>
      {children}
    </details>
  );
}
