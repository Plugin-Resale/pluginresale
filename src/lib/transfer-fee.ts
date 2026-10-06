import type { Developer } from "@/lib/catalog";

type FeeDeveloper = Pick<Developer, "name" | "transferable" | "fee" | "who_pays" | "no_fee">;

// Site rule (Terms §5): the listed price includes the developer's transfer fee, paid by the
// seller, unless the developer bills the buyer directly. Built only from the developer's row.

const buyerPays = (developer: FeeDeveloper) => /^buyer/i.test(developer.who_pays?.trim() ?? "");

const isFree = (developer: FeeDeveloper) =>
  developer.fee ? /^free\.?$/i.test(developer.fee.trim()) : developer.no_fee;

const feeText = (developer: FeeDeveloper) => developer.fee?.trim().replace(/\.$/, "") ?? null;

// Listing page, under the price.
export function buyerFeeNote(developer: FeeDeveloper): string | null {
  if (developer.transferable === false) return null;
  const fee = feeText(developer);
  if (buyerPays(developer)) {
    return fee
      ? `${developer.name} bills its transfer fee to the buyer, on top of this price: ${fee}.`
      : `${developer.name} bills its transfer fee to the buyer, on top of this price.`;
  }
  if (isFree(developer)) return "No developer transfer fee.";
  if (fee) return `Developer transfer fee paid by the seller, included in this price: ${fee}.`;
  return "Any developer transfer fee is paid by the seller and included in this price.";
}

// Sell form, under the price field.
export function sellerFeeNote(developer: FeeDeveloper): string | null {
  if (developer.transferable === false) return null;
  const fee = feeText(developer);
  if (buyerPays(developer)) {
    return `${developer.name} bills its transfer fee to the buyer, not to you: don't add it to your price.`;
  }
  if (isFree(developer)) return `${developer.name} charges no transfer fee.`;
  if (fee) return `Transfer fee: ${fee}. You pay it, so include it in your price.`;
  return "If the developer charges a transfer fee, you pay it: include it in your price.";
}
