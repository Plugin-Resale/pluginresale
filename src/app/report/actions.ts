"use server";

import { escapeHtml, sendEmail } from "@/lib/email";

export type ReportState = { status: "idle" | "sent" | "error"; message?: string };

export const REPORT_REASONS = {
  not_owned: "The seller doesn't own this license, or it's NFR / educational / bundled",
  not_transferable: "This license can't be transferred",
  scam: "Scam or suspicious behaviour (e.g. asks for Friends & Family)",
  illegal: "Illegal, abusive or offensive content",
  other: "Something else",
} as const;

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const CONTACT = "contact@pluginresale.com";

// Notice-and-action (EU Digital Services Act, art. 16): anyone can report content, and gets a
// confirmation that we received the report.
export async function sendReport(_prev: ReportState, formData: FormData): Promise<ReportState> {
  const where = String(formData.get("where") ?? "").trim();
  const reason = String(formData.get("reason") ?? "");
  const details = String(formData.get("details") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim().toLowerCase();

  if (!where || where.length > 300) {
    return { status: "error", message: "Tell us which listing, user or page you're reporting." };
  }
  if (!(reason in REPORT_REASONS)) return { status: "error", message: "Pick a reason." };
  if (details.length < 10 || details.length > 3000) {
    return { status: "error", message: "Explain the problem in a few words (10 to 3,000 characters)." };
  }
  if (!EMAIL_RE.test(email)) return { status: "error", message: "Enter a valid email address." };
  if (formData.get("good_faith") !== "on") {
    return { status: "error", message: "Please confirm the statement at the bottom of the form." };
  }

  const label = REPORT_REASONS[reason as keyof typeof REPORT_REASONS];
  await sendEmail({
    to: CONTACT,
    replyTo: email,
    subject: `Report: ${where.slice(0, 80)}`,
    html: `<h2>New report</h2>
<p><strong>What:</strong> ${escapeHtml(where)}</p>
<p><strong>Reason:</strong> ${escapeHtml(label)}</p>
<p><strong>From:</strong> ${escapeHtml(email)}</p>
<p><strong>Details:</strong></p>
<p style="white-space:pre-wrap">${escapeHtml(details)}</p>`,
  });
  await sendEmail({
    to: email,
    subject: "We received your report",
    html: `<h2>Thanks, we received your report</h2>
<p>We'll look into it and let you know what we decided. Here is what you sent us:</p>
<p><strong>What:</strong> ${escapeHtml(where)}<br><strong>Reason:</strong> ${escapeHtml(label)}</p>
<p style="white-space:pre-wrap">${escapeHtml(details)}</p>
<p>— Plugin Resale</p>`,
  });

  return { status: "sent" };
}
