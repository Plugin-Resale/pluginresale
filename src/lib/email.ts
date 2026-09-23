const BUTTON_STYLE =
  "display:inline-block;padding:12px 20px;background:#C2410C;color:#ffffff;text-decoration:none;border-radius:8px;font-weight:600";

export function emailButton(url: string, label: string) {
  return `<p><a href="${url}" style="${BUTTON_STYLE}">${label}</a></p>`;
}

// Notification emails are a side effect: they never block or fail the action that triggers them.
export async function sendEmail({
  to,
  subject,
  html,
}: {
  to: string;
  subject: string;
  html: string;
}) {
  if (!process.env.RESEND_API_KEY) return;
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ from: "Plugin Resale <contact@pluginresale.com>", to, subject, html }),
    });
    if (!res.ok) console.error("Resend send failed:", await res.text());
  } catch (err) {
    console.error("Resend send failed:", err);
  }
}
