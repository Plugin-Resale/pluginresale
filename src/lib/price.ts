export const MIN_PRICE = 1;
export const MAX_PRICE = 10000;

// Reads a price typed by a seller, the way people actually type it: "95", "95.50",
// "95,50", "€95", "95 €", "95 EUR", "95,-" (German style), "1.200" or "1,200",
// "1.200,50". Returns the amount in euros, or null if it is not a valid price
// between MIN_PRICE and MAX_PRICE with at most 2 decimals.
export function parsePrice(input: string): number | null {
  let s = input
    .replace(/eur(os?)?/gi, "")
    .replace(/[€\s  ']/g, "")
    .replace(/[.,]-+$/, ""); // "95,-" / "95.-"
  if (!/^\d[\d.,]*$/.test(s)) return null;

  const lastSep = Math.max(s.lastIndexOf("."), s.lastIndexOf(","));
  if (lastSep !== -1) {
    const decimals = s.slice(lastSep + 1);
    const hasBoth = s.includes(".") && s.includes(",");
    // A separator followed by exactly 3 digits, alone, is a thousands separator ("1.200").
    if (hasBoth || decimals.length !== 3) {
      if (decimals.length < 1 || decimals.length > 2) return null;
      s = s.slice(0, lastSep).replace(/[.,]/g, "") + "." + decimals;
    } else {
      s = s.replace(/[.,]/g, "");
    }
  }
  if (!/^\d+(\.\d{1,2})?$/.test(s)) return null;

  const price = Number(s);
  return price >= MIN_PRICE && price <= MAX_PRICE ? price : null;
}
