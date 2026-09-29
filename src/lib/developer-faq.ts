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
