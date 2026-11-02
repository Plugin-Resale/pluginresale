import type { Developer } from "@/lib/catalog";

// Developer page SEO text (meta description + FAQ), built only from the developer's row:
// never add a policy detail here that isn't in the database.

function sentence(text: string) {
  const trimmed = text.trim();
  return /[.!?]\)?$/.test(trimmed) ? trimmed : `${trimmed}.`;
}

function feeText(developer: Developer) {
  if (developer.fee) return developer.fee;
  if (developer.no_fee) return "Free";
  return null;
}

// Short form of the fee for the page title ("Free", "€10 fee", "5% fee", "iLok fee"), read
// from the row: when the wording does not start with an amount, just say a fee exists.
function feeShort(developer: Developer) {
  const fee = (developer.fee ?? "").trim();
  if (/^free\b/i.test(fee)) {
    // "Free (plus the iLok fee...)", "Free after 9 months", "Free for the first transfer":
    // the developer charges nothing, but not in every case.
    return /ilok|after|before|first|if\b|later|except/i.test(fee) ? "Free with conditions" : "Free";
  }
  if (!fee && developer.no_fee) return "Free";
  const amount = fee.match(/^(?:about |approx\.? |~)?([€$£]\s?\d+(?:[.,]\d+)?)/i);
  if (amount) return `${amount[1].replace(/\s/g, "")} fee`;
  const percent = fee.match(/^(\d+\s?%)/);
  if (percent) return `${percent[1].replace(/\s/g, "")} fee`;
  if (/ilok/i.test(fee)) return "iLok fee";
  if (fee) return "Paid fee";
  return null;
}

// Page title with the answer in it: a searcher typing "<brand> license transfer" sees at a
// glance whether it is allowed and what it costs, which is what earns the click.
export function developerTitle(developer: Developer) {
  const { name } = developer;
  if (developer.transferable === null) return `${name} License Transfer: Policy Not Verified – What We Know`;
  if (developer.transferable === false) return `${name} License Transfer: Not Allowed – Policy & Options`;
  const fee = feeShort(developer);
  return `${name} License Transfer: Allowed${fee ? ` (${fee})` : ""} – How to Resell`;
}

export function developerDescription(developer: Developer) {
  const { name } = developer;
  let text: string;
  if (developer.transferable === null) {
    text = `${name} license transfers: no official policy found yet. What we know so far, and what to ask ${name} before you buy or sell a used license.`;
  } else if (developer.transferable === false) {
    text = `${name} licenses can't be transferred to another user. The official policy, the exceptions, and what it means if you want to resell.`;
  } else {
    const fee = feeText(developer);
    const parts = [`${name} allows license transfers.`];
    if (fee) parts.push(`Fee: ${fee}.`);
    if (developer.typical_delay) parts.push(`Delay: ${developer.typical_delay}.`);
    parts.push("Step-by-step process and restrictions.");
    text = parts.join(" ");
  }
  return text.length > 160 ? `${text.slice(0, 157).replace(/[\s,.;:]+\S*$/, "")}...` : text;
}

export type FaqItem = { question: string; answer: string };

export function developerFaq(developer: Developer): FaqItem[] {
  const { name } = developer;
  const faq: FaqItem[] = [];

  if (developer.transferable === null) {
    faq.push({
      question: `Can I resell my ${name} plugins?`,
      answer: [
        `We haven't found an official transfer policy for ${name} yet, so we can't confirm it.`,
        developer.restrictions && `What we know: ${sentence(developer.restrictions)}`,
        `Ask ${name} whether the license can be transferred, and how, before you buy or sell.`,
      ]
        .filter(Boolean)
        .join(" "),
    });
    return faq;
  }

  if (developer.transferable === false) {
    faq.push({
      question: `Can I resell my ${name} plugins?`,
      answer: [
        `No. ${name} doesn't allow its licenses to be transferred to another user.`,
        developer.restrictions && sentence(developer.restrictions),
      ]
        .filter(Boolean)
        .join(" "),
    });
    if (developer.process) {
      faq.push({ question: `Is there any exception?`, answer: sentence(developer.process) });
    }
    return faq;
  }

  faq.push({
    question: `Can I resell my ${name} plugins?`,
    answer: [
      `Yes. ${name} allows licenses to be transferred to another user.`,
      developer.restrictions && `Conditions: ${sentence(developer.restrictions)}`,
    ]
      .filter(Boolean)
      .join(" "),
  });

  const fee = feeText(developer);
  faq.push({
    question: `How much does a ${name} license transfer cost?`,
    answer: fee
      ? [sentence(fee), developer.who_pays && `Paid by: ${sentence(developer.who_pays)}`]
          .filter(Boolean)
          .join(" ")
      : `${name}'s official policy doesn't state a transfer fee. Check with ${name} before you agree on a price.`,
  });

  faq.push({
    question: `How long does a ${name} license transfer take?`,
    answer: developer.typical_delay
      ? sentence(developer.typical_delay)
      : `${name}'s official policy doesn't give a typical delay. Agree on a timeline with the other side, and only confirm the deal once the license shows up in the buyer's account.`,
  });

  if (developer.process) {
    faq.push({
      question: `How do I transfer a ${name} license?`,
      answer: sentence(developer.process),
    });
  }

  return faq;
}
