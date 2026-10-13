# Price reminder email + price change (2026-10-13)

Asked by Victor: email sellers whose listing has not sold 2 weeks after going live, suggesting a lower price (example: listing 1032, Pro-Q 4 at €159).

## Price change
- Sellers could not change their price until now (RLS and the column grant already allowed it, there was just no UI).
- Listing page, price card, seller only, listing `active` or `removed`: a small "Change price" form (`setListingPrice` server action, same validation as Sell: €1 to €10,000, max 2 decimals).
- Reserved / sold listings: no form (RLS refuses anyway, and the deal keeps its own price snapshot).

## Reminder email
- Once per listing, 14 days after `created_at`, only if the listing is still `active` (reserved, sold or removed are skipped).
- `listings.price_reminder_sent_at` + `claim_price_reminders()` (service role only) marks and returns the due listings in one statement, so two runs never email twice.
- One email per seller, listing every due listing (a seller can have 16 at once).
- Daily Vercel cron (`vercel.json`, 08:00 UTC) calls `/api/cron/price-reminders`. If `CRON_SECRET` is set on Vercel the route requires it. Without it the route still only sends what is due, once, so a stranger calling it cannot spam anyone.
- Links go through `/signin?next=/listings/<id>`: a signed-in seller lands straight on the listing, others sign in first.
- Existing listings older than 14 days get it on the first run (Victor's choice).
- No suggested figure: we have no new prices in the database.
