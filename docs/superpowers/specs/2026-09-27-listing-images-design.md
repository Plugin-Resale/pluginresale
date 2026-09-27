# Listing images: official plugin visual + optional license proof

Date: 2026-09-27. Approved by Victor in chat.

## Goal

1. Every listing shows the plugin's official visual (packshot or interface screenshot), or a generic visual when we have none.
2. A seller can attach an optional screenshot of their account / iLok page as proof they own the license.
3. When a proof is attached, a discreet "License proof attached" badge appears (never "verified"), and on the listing page the proof opens full size in a modal.

## Decisions

- **Official images are filled by us, not guessed at runtime.** A script takes the `og:image` of the plugin's official product page, copies it into our storage, and sets it on the `plugins` row. Start with plugins that have listings, then the best-known ones, then keep up as new listings arrive. From the seller's point of view it is automatic: they pick the plugin, the image shows. No image search API (wrong-version risk: Pro-Q 4 image on a Pro-Q 3 listing).
- **Images are copied, not hotlinked**, so they do not break when a developer site changes.
- **The proof is public** (anyone can open it on the listing page). The Sell form warns the seller to hide their email, name and serial numbers first. The seller can remove it at any time.
- **Store paths, not full URLs** (`image_path`, `proof_image_path`). The public URL is built in code from the Supabase URL + bucket + path.

## Data (migration `0048_listing_images.sql`)

- `plugins.image_path text` (nullable). Null = generic visual. No insert/update grant for `authenticated` on this column: only set by us (SQL Editor / service role script).
- `listings.proof_image_path text` (nullable).
- Storage bucket `plugin-images`: public read, no write policy for `anon`/`authenticated`.
- Storage bucket `listing-proofs`: public read, 5 MB limit, `image/jpeg`, `image/png`, `image/webp`. RLS on `storage.objects`: an authenticated user may insert and delete only objects whose first folder is their own `auth.uid()`.
- `create_listing()` gets `p_proof_image_path text default null`. If set, it must start with `auth.uid() || '/'`, otherwise `BAD_PROOF`.
- New RPC `set_listing_proof(p_listing_id bigint, p_path text)`: seller of that listing only, path rule as above, `null` removes it. Used to add / replace / remove the proof after publishing (there is no listing edit page).
- `listing_cards` view: append `p.image_path as plugin_image_path` and `l.proof_image_path` at the end (view columns cannot be reordered).
- `service_role` grants as needed (see the 0040 lesson).
- Migration comments free of apostrophes and semicolons (SQL Editor quirk).

## Upload flow

- Client component on `/sell`: optional file field "Account / iLok screenshot (optional)", with the privacy warning.
- The browser resizes the image (max 2000 px on the long side) and re-encodes it as JPEG through a canvas. This shrinks a 3–5 MB phone photo to a few hundred KB and drops EXIF metadata (including GPS).
- The file goes straight from the browser to Supabase Storage with the user's session, to `listing-proofs/<user id>/<random uuid>.jpg`. This avoids Vercel's 4.5 MB request body limit on server actions. The resulting path goes into a hidden form field, and the server action passes it to `create_listing()`.
- Preview thumbnail + "Remove" before submitting. Upload errors are shown inline and never block publishing without a proof.
- Seller-only block on their own listing page: add / replace / remove the proof (same upload component + `set_listing_proof`). Replacing or removing also deletes the old file.
- Accepted limit: a file uploaded on an abandoned Sell form stays in storage (orphan). Small, clean up later if it ever matters.

## Display

- `ListingCard` (Browse, home, account, deal page, seller profile, related listings): official image at the top of the card, `object-fit: contain` on a neutral background so packshots of any shape fit. **Generic visual = the current dark block with developer + plugin name**, kept as the fallback.
- Badge "License proof attached" (neutral grey, small) on the card and on the listing page when `proof_image_path` is set. The word "verified" never appears.
- Listing page: official image in the hero next to the title. Proof thumbnail near the seller card; clicking it opens a native `<dialog>` modal (closes on Esc, close button, click outside) with the full image and the caption "Uploaded by the seller, not checked by Plugin Resale."
- Sell page: the side panel shows the plugin image as soon as a plugin is picked (the per-plugin data sent to the page gains `image_path`).
- Plain `<img loading="lazy">` with explicit dimensions/aspect ratio, not `next/image` (avoids Vercel image optimisation quota and a remote pattern config).

## Filling the official images (ops, not app code)

- A local script (`scripts/`, service role key from `.env.local`) takes a list of `plugin id -> official product page URL`, fetches the page's `og:image`, uploads it to `plugin-images/<plugin id>.<ext>`, and sets `plugins.image_path`.
- Each URL is an official developer page, checked by hand for the right product and version.
- First batch: every plugin that currently has a listing.

## Legal / content

- Privacy policy (EN + FR `#fr`, keep both in sync): proof screenshots are public, stored in Supabase, deleted with the listing's owner account, and the seller can remove them any time.
- Account deletion (`delete_my_account` flow) also deletes the user's `listing-proofs/<uid>/` files.
- Official images are used to identify the product being resold. A developer objection goes through the existing Report form, and we remove the image.

## Testing

- End to end locally with the two test accounts: list with and without proof, add / replace / remove on an existing listing, modal on desktop and phone width, generic visual when `image_path` is null, a user cannot write into another user's proof folder.
- Check that a large iPhone photo (HEIC is converted by Safari on file pick, and JPEG > 5 MB) gets resized and uploaded.
