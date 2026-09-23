# Plugin Resale — project brief

Marketplace for second-hand audio plugin licenses (competitor to Knobcloud).
Domain: pluginresale.com (Namecheap). Contact: contact@pluginresale.com.
Site language: **English**. Owner: Victor (non-developer, explain steps simply, in French).

Design reference (mockup v1, 4 pages): https://claude.ai/artifact/KiyRncyZgYt9eo3hP2ENFw

## Business rules
- Free to list, free to buy, no commission. Revenue = ads only (for now).
- **Payment happens directly between users via PayPal Goods & Services.** The site never holds money, never processes payments, never handles disputes or refunds (PayPal does).
- Each developer has its own license-transfer policy → a public "transfer rules" database is a core feature.

## Stack
- Next.js (App Router, TypeScript), deployed on Vercel.
- Supabase: Postgres, Auth (email magic link), Row Level Security on every table.
- No payment SDK.

## Pages (match the mockup)
1. **Home** — hero + search, category chips, "Just listed" grid, how it works, developers teaser, footer.
2. **Browse** — filters (category, developer, price, transferable only, no dev fee), sort, paginated grid.
3. **Listing** — plugin, formats, seller note, developer transfer rules box, price card, "Buy with PayPal", "Message seller", seller card + rating.
4. **Sell** — form: plugin (autocomplete from DB), version, category, price, description, PayPal email, 2 mandatory checkboxes (owns license / not NFR-edu-bundled; will uninstall and transfer). Side panel auto-fills the developer's transfer rules.
5. Also: Developers index + developer page (transfer rules), seller profile with reviews, account (my listings, my purchases), sign in, Terms, Privacy, Advertise.

## Purchase flow
1. Buyer clicks "Buy with PayPal" (must be signed in) → a `deal` is created, listing becomes "reserved".
2. Buyer sees the seller's PayPal email + instructions: pay with **Goods & Services** (never Friends & Family), add the listing ID in the note.
3. Seller marks "payment received" → seller starts the developer transfer.
4. Buyer marks "license received" → deal completed, listing "sold".
5. Both leave a review (1–5 + comment). Seller's PayPal email is never public, shown only to the buyer of an active deal.
6. Deal can be cancelled by either side before step 3 → listing back to "active".

## Data model (first draft)
- `profiles` (id = auth user, username, created_at)
- `developers` (id, name, slug, transferable bool, fee text, who_pays text, process text, typical_delay text, source_url, last_verified date)
- `plugins` (id, developer_id, name, slug, category)
- `listings` (id, seller_id, plugin_id, version, price_eur, description, paypal_email [private], status active|reserved|sold|removed, created_at)
- `deals` (id, listing_id, buyer_id, seller_id, status requested|paid|completed|cancelled, timestamps)
- `reviews` (id, deal_id, author_id, target_id, rating, comment)
- `messages` (id, listing_id, from_id, to_id, body, created_at)

## Ads
- One `<AdSlot>` component with a placeholder, positions from the mockup:
  A 970×90 leaderboard under header (all pages) · B native card in grids (every 6th) · C 970×250 billboard home · D 300×600 sticky rail on Browse · E 300×250 on Listing.
- No ads on the Sell page. Ad network (AdSense or direct) plugged in later.

## Design tokens
- Colors: ground #F2EFE8, surface #FFFFFF, ink #17171B, muted #55545C, line #D9D4C9, accent #C2410C (hover #9A3412), success #1F6B44 on #E1F0E6.
- Fonts (Google): Bricolage Grotesque (display), IBM Plex Sans (body), IBM Plex Mono (prices, labels).
- Radius 8–14px, buttons 44px min height.

## Legal (EU)
- Footer disclaimer: payments are between users, Plugin Resale is not a party to the transaction.
- Terms, Privacy (GDPR), cookie consent before loading ad scripts.
- Report-listing button on every listing.

## Build order
1. Project setup + Supabase + deploy empty site on pluginresale.com.
2. Auth + profiles.
3. Developers/plugins tables + seed data + developer pages.
4. Sell form + listings + Browse + Listing page.
5. Deals flow + reviews + messages.
6. Ad slots, legal pages, polish, launch. **Before launch: custom SMTP in Supabase Auth** (default Supabase mailer only sends to project team members, ~2 emails/hour).

## Supabase setup (done by hand in the dashboard)
- SQL migrations live in `supabase/migrations/` and are pasted into the SQL Editor in order.
- Auth emails: default Supabase templates for now (PKCE `?code=` link → `/auth/confirm`, same browser only). Templates are locked until custom SMTP; then paste `supabase/templates/magic-link.html` into Magic Link + Confirm signup (token_hash link, works cross-device).
- Auth URL config: Site URL `https://www.pluginresale.com`; redirect URLs include production, localhost:3000 and Vercel previews.

## Important
- Namecheap DNS already has email forwarding (MX + SPF). When pointing the domain to Vercel, **only add A / CNAME records, never touch MX or the SPF TXT.**

@AGENTS.md
