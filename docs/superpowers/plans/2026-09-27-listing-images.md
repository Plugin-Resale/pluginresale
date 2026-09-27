# Listing Images Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show each plugin's official visual (or a generic one) on listing cards and listing pages, and let sellers attach an optional license-proof screenshot that shows as a "License proof attached" badge and opens in a modal.

**Architecture:** Two nullable path columns (`plugins.image_path`, `listings.proof_image_path`) pointing into two public Supabase Storage buckets. Proof screenshots are resized in the browser and uploaded straight to Storage into the seller's own folder (RLS on `storage.objects` + a check constraint tying the path to `seller_id`); forms only carry the path. Official images are filled by a local service-role script from the official product page's `og:image`.

**Tech Stack:** Next.js 16 App Router (server components + server actions), Supabase (Postgres, Storage, RLS), `@supabase/ssr`, plain CSS in `src/app/globals.css`.

Spec: `docs/superpowers/specs/2026-09-27-listing-images-design.md`.

## Global Constraints

- Site copy in English. The word "verified" never appears next to the proof. Badge text is exactly `License proof attached`. Modal caption is exactly `Uploaded by the seller, not checked by Plugin Resale.`
- SQL comments contain no apostrophe and no semicolon (Supabase SQL Editor quirk).
- Any table the service role touches needs an explicit `grant ... to service_role`.
- Proof path shape: `<seller uuid>/<random uuid>.jpg`, regex `^[0-9a-f-]{36}/[0-9a-f-]{36}\.jpg$`.
- Buckets: `plugin-images` (public, 5 MB, jpeg/png/webp, no user writes), `listing-proofs` (public, 5 MB, jpeg only, owner-folder writes).
- Plain `<img>` (not `next/image`), with `// eslint-disable-next-line @next/next/no-img-element` and a reason.
- No test framework in this repo: verification = `npx tsc --noEmit`, `npm run lint`, and checks in the browser preview (`preview_start` name `pluginresale-dev`).
- The migration must be applied in Supabase **before** the code is deployed (the Sell page selects `image_path`, and `create_listing` gets a new parameter).

---

### Task 1: Migration 0048

**Files:**
- Create: `supabase/migrations/0048_listing_images.sql`

**Interfaces:**
- Produces: `plugins.image_path text`, `listings.proof_image_path text`, view `listing_cards` gains `plugin_image_path` and `proof_image_path` (appended last), `create_listing(..., p_proof_image_path text default null)` (raises `BAD_PROOF`), `clear_my_proofs()` RPC, buckets `plugin-images` and `listing-proofs`.

- [ ] **Step 1: Write the migration**

```sql
-- Step 48: official plugin visuals and optional license proof screenshots on listings
-- (Victor, 2026-09-27). Design in docs/superpowers/specs/2026-09-27-listing-images-design.md
-- Run once in Supabase > SQL Editor, before deploying the matching code.

-- 1. Official visual of a catalogue plugin, as a path in the plugin-images bucket.
--    Null means the generic visual. Only set by us (SQL Editor or supabase/scripts/set-plugin-image.mjs).
alter table public.plugins add column image_path text;
grant select on public.plugins to service_role;
grant update (image_path) on public.plugins to service_role;

-- 2. Optional screenshot of the seller account or iLok page, as a path in listing-proofs.
--    The path has to sit in the seller own folder, so nobody can show someone else file.
alter table public.listings add column proof_image_path text;
alter table public.listings add constraint listings_proof_in_seller_folder check (
  proof_image_path is null
  or proof_image_path ~ ('^' || seller_id::text || '/[0-9a-f-]{36}\.jpg$')
);
grant insert (proof_image_path), update (proof_image_path) on public.listings to authenticated;

-- 3. Storage buckets, both publicly readable.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('plugin-images', 'plugin-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('listing-proofs', 'listing-proofs', true, 5242880, array['image/jpeg']);

create policy "Sellers upload proofs into their own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'listing-proofs'
              and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Sellers list their own proof files" on storage.objects
  for select to authenticated
  using (bucket_id = 'listing-proofs'
         and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Sellers delete their own proof files" on storage.objects
  for delete to authenticated
  using (bucket_id = 'listing-proofs'
         and (storage.foldername(name))[1] = (select auth.uid()::text));

-- 4. create_listing takes the optional proof path. Both older versions are dropped first
--    (0035 added parameters without dropping the 0027 one, which left two overloads).
drop function if exists public.create_listing(bigint, text, numeric, text, text[], text);
drop function if exists public.create_listing(bigint, text, numeric, text, text[], text, text, text, bigint);

create function public.create_listing(
  p_plugin_id bigint,
  p_version text,
  p_price_eur numeric,
  p_description text,
  p_formats text[],
  p_paypal_email text,
  p_new_plugin_name text default null,
  p_new_plugin_category text default null,
  p_developer_id bigint default null,
  p_proof_image_path text default null
)
returns bigint
language plpgsql
set search_path = ''
as $$
declare
  v_id bigint;
  v_plugin_id bigint;
  v_transferable boolean;
  v_paypal_email text;
  v_slug text;
begin
  if auth.uid() is null then
    raise exception 'NOT_SIGNED_IN';
  end if;

  if not exists (select 1 from public.profiles where id = auth.uid() and username is not null) then
    raise exception 'USERNAME_REQUIRED';
  end if;

  if p_proof_image_path is not null
     and p_proof_image_path !~ ('^' || auth.uid()::text || '/[0-9a-f-]{36}\.jpg$') then
    raise exception 'BAD_PROOF';
  end if;

  if p_plugin_id is not null then
    select d.transferable into v_transferable
    from public.plugins p
    join public.developers d on d.id = p.developer_id
    where p.id = p_plugin_id;

    if not found then
      raise exception 'UNKNOWN_PLUGIN';
    end if;

    v_plugin_id := p_plugin_id;
  else
    if p_developer_id is null or nullif(trim(p_new_plugin_name), '') is null
       or p_new_plugin_category is null then
      raise exception 'UNKNOWN_PLUGIN';
    end if;

    select d.transferable into v_transferable
    from public.developers d
    where d.id = p_developer_id;

    if not found then
      raise exception 'UNKNOWN_PLUGIN';
    end if;

    v_slug := trim(both '-' from lower(regexp_replace(p_new_plugin_name, '[^a-zA-Z0-9]+', '-', 'g')));

    select id into v_plugin_id from public.plugins
    where developer_id = p_developer_id and slug = v_slug;

    if not found then
      insert into public.plugins (developer_id, name, slug, category, created_by)
      values (p_developer_id, trim(p_new_plugin_name), v_slug, p_new_plugin_category, auth.uid())
      returning id into v_plugin_id;
    end if;
  end if;

  if not v_transferable then
    raise exception 'NOT_TRANSFERABLE';
  end if;

  v_paypal_email := lower(trim(p_paypal_email));

  insert into public.listings (seller_id, plugin_id, version, price_eur, description, formats,
                               proof_image_path)
  values (auth.uid(), v_plugin_id, nullif(trim(p_version), ''), p_price_eur,
          coalesce(trim(p_description), ''), coalesce(p_formats, '{}'), p_proof_image_path)
  returning id into v_id;

  insert into public.listing_private (listing_id, paypal_email)
  values (v_id, v_paypal_email);

  insert into public.profile_private (user_id, paypal_email)
  values (auth.uid(), v_paypal_email)
  on conflict (user_id) do update set paypal_email = excluded.paypal_email;

  return v_id;
end;
$$;

revoke execute on function public.create_listing from public, anon;
grant execute on function public.create_listing to authenticated;

-- 5. Account deletion clears the proof paths on all the user listings, sold ones included
--    (the app deletes the files themselves right after).
create function public.clear_my_proofs()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.listings set proof_image_path = null where seller_id = auth.uid();
$$;

revoke execute on function public.clear_my_proofs from public, anon;
grant execute on function public.clear_my_proofs to authenticated;

-- 6. Listing cards carry both images. New columns go last, a view cannot reorder its columns.
create or replace view public.listing_cards with (security_invoker = true) as
select
  l.id, l.status, l.price_eur, l.version, l.formats, l.description, l.created_at,
  l.seller_id, pr.username as seller_username, pr.created_at as seller_since,
  p.id as plugin_id, p.name as plugin_name, p.category,
  d.id as developer_id, d.name as developer_name, d.slug as developer_slug,
  d.transferable, d.no_fee,
  ss.avg_rating as seller_avg_rating, ss.review_count as seller_review_count,
  p.image_path as plugin_image_path, l.proof_image_path
from public.listings l
join public.plugins p on p.id = l.plugin_id
join public.developers d on d.id = p.developer_id
join public.profiles pr on pr.id = l.seller_id
left join public.seller_stats ss on ss.seller_id = l.seller_id;

grant select on public.listing_cards to anon, authenticated;
```

- [ ] **Step 2: Check the comment rule**

Run: `grep -n "^\s*--.*['\;]" supabase/migrations/0048_listing_images.sql`
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/0048_listing_images.sql
git commit -m "Migration 0048: plugin visuals and license proof screenshots"
```

- [ ] **Step 4: Apply it (Victor pastes it in Supabase SQL Editor), then verify**

Run in SQL Editor:
```sql
select id, public, file_size_limit from storage.buckets where id in ('plugin-images', 'listing-proofs');
select plugin_image_path, proof_image_path from public.listing_cards limit 1;
select count(*) from pg_proc where proname = 'create_listing';
```
Expected: 2 buckets, both `public = true`; the select works; `create_listing` count = 1.

---

### Task 2: Official visual on listing cards

**Files:**
- Create: `src/lib/images.ts`
- Modify: `src/lib/catalog.ts` (type `ListingCard`)
- Modify: `src/components/ListingCard.tsx`
- Modify: `src/app/globals.css` (Listing cards section)

**Interfaces:**
- Produces (`src/lib/images.ts`): `PROOF_BUCKET = "listing-proofs"`, `PROOF_PATH_RE: RegExp`, `pluginImageUrl(path: string): string`, `proofImageUrl(path: string): string`.
- Produces: `ListingCard.plugin_image_path: string | null`, `ListingCard.proof_image_path: string | null`.

- [ ] **Step 1: `src/lib/images.ts`**

```ts
// Public URLs of the files kept in Supabase Storage (migration 0048). The database only
// stores the path inside the bucket, so a change of storage URL never breaks old rows.
const STORAGE_URL = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public`;

export const PROOF_BUCKET = "listing-proofs";

// <seller id>/<random uuid>.jpg: the only shape the listings table accepts.
export const PROOF_PATH_RE = /^[0-9a-f-]{36}\/[0-9a-f-]{36}\.jpg$/;

export function pluginImageUrl(path: string) {
  return `${STORAGE_URL}/plugin-images/${path}`;
}

export function proofImageUrl(path: string) {
  return `${STORAGE_URL}/${PROOF_BUCKET}/${path}`;
}
```

- [ ] **Step 2: Extend the `ListingCard` type** in `src/lib/catalog.ts`, after `no_fee: boolean;`:

```ts
  plugin_image_path: string | null; // official visual, null = generic visual
  proof_image_path: string | null; // seller's optional license screenshot
```

- [ ] **Step 3: `ListingCard` renders the image, the title and the badge**

Replace the `ListingCard` function body in `src/components/ListingCard.tsx`:

```tsx
import { pluginImageUrl } from "@/lib/images";
// ...existing imports

export function ListingCard({ listing }: { listing: Listing }) {
  const image = listing.plugin_image_path;
  return (
    <Link href={`/listings/${listing.id}`} className="listing-card">
      {image ? (
        <div className="listing-thumb listing-thumb-image">
          {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
          <img
            src={pluginImageUrl(image)}
            alt={`${listing.developer_name} ${listing.plugin_name}`}
            loading="lazy"
          />
        </div>
      ) : (
        <div className="listing-thumb">
          <span className="listing-dev">{listing.developer_name}</span>
          <span className="listing-name">{listing.plugin_name}</span>
        </div>
      )}
      <div className="listing-body">
        {image && (
          <span className="listing-title">
            <span className="listing-title-dev">{listing.developer_name}</span>
            {listing.plugin_name}
          </span>
        )}
        <div className="listing-row">
          {/* unchanged price + badge */}
        </div>
        {listing.proof_image_path && (
          <span className="badge badge-muted proof-badge">License proof attached</span>
        )}
        <span className="listing-seller">{/* unchanged */}</span>
      </div>
    </Link>
  );
}
```

- [ ] **Step 4: CSS**, in `src/app/globals.css` right after `.listing-name { ... }`:

```css
.listing-thumb-image {
  height: 150px;
  padding: 12px;
  background: var(--surface);
  border-bottom: 1px solid var(--line);
  justify-content: center;
}

.listing-thumb-image img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.listing-title {
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-family: var(--font-display), sans-serif;
  font-size: 18px;
  font-weight: 700;
  line-height: 1.15;
  color: var(--ink);
}

.listing-title-dev {
  font-family: var(--font-mono), monospace;
  font-size: 11px;
  font-weight: 400;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--muted);
}

.proof-badge {
  align-self: flex-start;
}
```

- [ ] **Step 5: Verify** — `npx tsc --noEmit && npm run lint` pass. Browser `/browse`: cards without image look exactly as before. Temporarily set one plugin's `image_path` (Task 7 script, or SQL) and check the card shows image + title.

- [ ] **Step 6: Commit** — `git commit -m "Listing cards show the plugin's official visual and the proof badge"`

---

### Task 3: Listing page — hero visual, proof viewer modal, JSON-LD

**Files:**
- Create: `src/components/ProofViewer.tsx`
- Modify: `src/app/listings/[id]/page.tsx`
- Modify: `src/app/globals.css` (Listing page section + mobile ordering)

**Interfaces:**
- Consumes: `pluginImageUrl`, `proofImageUrl` (Task 2), `ListingCard.plugin_image_path/proof_image_path`.
- Produces: `<ProofViewer path={string} />` (client component).

- [ ] **Step 1: `src/components/ProofViewer.tsx`**

```tsx
"use client";

import { useRef } from "react";
import { proofImageUrl } from "@/lib/images";

const CAPTION = "Uploaded by the seller, not checked by Plugin Resale.";

// The seller's license screenshot: a thumbnail that opens full size in a modal.
// Never call it "verified": we don't check it.
export function ProofViewer({ path }: { path: string }) {
  const dialog = useRef<HTMLDialogElement>(null);
  const src = proofImageUrl(path);
  return (
    <div className="card proof-card">
      <span className="badge badge-muted">License proof attached</span>
      <button
        type="button"
        className="proof-thumb"
        onClick={() => dialog.current?.showModal()}
        aria-label="Open the license screenshot full size"
      >
        {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
        <img src={src} alt="" loading="lazy" />
      </button>
      <p className="hint">{CAPTION}</p>
      <dialog
        ref={dialog}
        className="proof-dialog"
        aria-label="License screenshot"
        // A click on the dialog itself (not its content) is a click on the backdrop.
        onClick={(e) => {
          if (e.target === e.currentTarget) e.currentTarget.close();
        }}
      >
        <div className="proof-dialog-inner">
          {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
          <img src={src} alt="Screenshot of the seller's license" />
          <p className="hint">{CAPTION}</p>
          <form method="dialog">
            <button className="btn">Close</button>
          </form>
        </div>
      </dialog>
    </div>
  );
}
```

- [ ] **Step 2: Hero visual** — in `src/app/listings/[id]/page.tsx`, wrap the hero text and add the image:

```tsx
<div className="listing-hero">
  <div className="listing-hero-text">
    <span className="listing-dev">
      {listing.developer_name} · {CATEGORIES[listing.category]}
    </span>
    <div>{/* unchanged h1 + tags */}</div>
  </div>
  {listing.plugin_image_path && (
    <div className="listing-hero-visual">
      {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
      <img src={pluginImageUrl(listing.plugin_image_path)} alt={title} />
    </div>
  )}
</div>
```

- [ ] **Step 3: Proof viewer** — in the aside, right after the seller card `</Link>`:

```tsx
{listing.proof_image_path && !isSeller && <ProofViewer path={listing.proof_image_path} />}
```
(The seller sees the editor from Task 5 instead.)

- [ ] **Step 4: JSON-LD image** — `image: listing.plugin_image_path ? pluginImageUrl(listing.plugin_image_path) : \`${url}/opengraph-image\``.

- [ ] **Step 5: CSS** — replace `.listing-hero { ... }` and add:

```css
.listing-hero {
  background: var(--ink);
  color: var(--ground);
  border-radius: var(--radius-lg);
  min-height: 260px;
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.listing-hero-text {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: 32px;
}

.listing-hero-visual {
  height: 220px;
  padding: 16px;
  background: var(--surface);
  border-radius: var(--radius);
  display: flex;
}

.listing-hero-visual img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

@media (min-width: 700px) {
  .listing-hero {
    flex-direction: row;
  }

  .listing-hero-visual {
    width: 280px;
    flex-shrink: 0;
    height: auto;
    min-height: 196px;
  }
}

.proof-card {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
}

.proof-card .hint {
  margin: 0;
}

.proof-thumb {
  width: 100%;
  height: 160px;
  padding: 0;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: var(--radius-sm);
  background: var(--ground);
  cursor: zoom-in;
}

.proof-thumb img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: top;
}

.proof-dialog {
  padding: 0;
  border: none;
  border-radius: var(--radius-lg);
  max-width: min(1000px, calc(100vw - 32px));
  max-height: calc(100dvh - 32px);
  background: var(--surface);
}

.proof-dialog::backdrop {
  background: rgb(23 23 27 / 0.7);
}

.proof-dialog-inner {
  padding: 16px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
}

.proof-dialog img {
  display: block;
  max-width: 100%;
  max-height: calc(100dvh - 180px);
  margin: 0 auto;
  object-fit: contain;
}
```
and in the `@media (max-width: 999px)` ordering block add `.proof-card { order: 3; }` (same order as the seller card: it keeps its place right after it).

- [ ] **Step 6: Verify** — tsc + lint. Browser: listing without image unchanged; with image (Task 7 or SQL) image sits right of the title on desktop, under it on phone width (375px). With a proof (SQL `update listings set proof_image_path = ...` after an upload in Task 4): thumbnail, click opens modal, Esc / Close / backdrop click close it.

- [ ] **Step 7: Commit** — `git commit -m "Listing page shows the plugin visual and the seller's license proof in a modal"`

---

### Task 4: Proof upload on /sell + plugin visual in the side panel

**Files:**
- Create: `src/lib/resize-image.ts`
- Create: `src/components/ProofUpload.tsx`
- Modify: `src/app/sell/page.tsx`, `src/app/sell/SellForm.tsx`, `src/app/sell/actions.ts`
- Modify: `src/app/globals.css` (Sell section)

**Interfaces:**
- Consumes: `PROOF_BUCKET`, `PROOF_PATH_RE`, `proofImageUrl`, `pluginImageUrl` (Task 2); `create_listing(p_proof_image_path)` (Task 1).
- Produces: `resizeToJpeg(file: File, maxSide?: number, quality?: number): Promise<Blob>`; `<ProofUpload userId={string} defaultPath?={string} />` which submits a hidden `proof_image_path` field; `SellForm` new props `userId: string`, `pluginImages: Record<number, string>`.

- [ ] **Step 1: `src/lib/resize-image.ts`**

```ts
// Shrinks a photo in the browser before upload: a 3-5 MB phone photo becomes a few hundred KB,
// and re-encoding through a canvas drops its EXIF metadata (GPS position, camera...).
export async function resizeToJpeg(file: File, maxSide = 2000, quality = 0.85): Promise<Blob> {
  const url = URL.createObjectURL(file);
  try {
    const img = new Image();
    img.src = url;
    await img.decode();
    const scale = Math.min(1, maxSide / Math.max(img.naturalWidth, img.naturalHeight));
    const canvas = document.createElement("canvas");
    canvas.width = Math.round(img.naturalWidth * scale);
    canvas.height = Math.round(img.naturalHeight * scale);
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("NO_CANVAS");
    ctx.fillStyle = "#fff"; // transparent PNG areas become white, not black
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, "image/jpeg", quality),
    );
    if (!blob) throw new Error("ENCODE_FAILED");
    return blob;
  } finally {
    URL.revokeObjectURL(url);
  }
}
```

- [ ] **Step 2: `src/components/ProofUpload.tsx`**

```tsx
"use client";

import { useId, useState, type ChangeEvent } from "react";
import { PROOF_BUCKET, proofImageUrl } from "@/lib/images";
import { resizeToJpeg } from "@/lib/resize-image";
import { createClient } from "@/lib/supabase/client";

// Optional screenshot of the seller's account or iLok page. Uploaded straight from the browser
// to Supabase Storage, into the seller's own folder (a server action would hit Vercel's 4.5 MB
// request limit). The form only carries the resulting path, in a hidden field.
export function ProofUpload({ userId, defaultPath }: { userId: string; defaultPath?: string }) {
  const [path, setPath] = useState(defaultPath ?? "");
  const [status, setStatus] = useState<"idle" | "uploading" | "error">("idle");
  const inputId = useId();

  const onChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;
    setStatus("uploading");
    try {
      const blob = await resizeToJpeg(file);
      const newPath = `${userId}/${crypto.randomUUID()}.jpg`;
      const { error } = await createClient()
        .storage.from(PROOF_BUCKET)
        .upload(newPath, blob, { contentType: "image/jpeg" });
      if (error) throw error;
      setPath(newPath);
      setStatus("idle");
    } catch (err) {
      console.error("proof upload failed:", err);
      setStatus("error");
    }
  };

  // A file uploaded here but not saved yet is nobody else's: delete it. The saved one
  // (defaultPath) is only deleted by the server once the listing no longer uses it.
  const remove = () => {
    if (path && path !== defaultPath) {
      createClient().storage.from(PROOF_BUCKET).remove([path]);
    }
    setPath("");
  };

  return (
    <div className="field">
      <label className="field-label" htmlFor={inputId}>
        Account / iLok screenshot <span className="optional">(optional)</span>
      </label>
      <p className="hint">
        A screenshot of this license in your developer account or iLok. Buyers can open it on your
        listing. <strong>Hide your email, name and serial numbers first</strong> (crop them out or
        scribble over them).
      </p>
      <input type="hidden" name="proof_image_path" value={path} />
      {path ? (
        <div className="proof-preview">
          {/* eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota */}
          <img src={proofImageUrl(path)} alt="Your license screenshot" />
          <button type="button" className="btn" onClick={remove}>
            Remove
          </button>
        </div>
      ) : (
        <input
          id={inputId}
          type="file"
          accept="image/*"
          className="input input-file"
          onChange={onChange}
          disabled={status === "uploading"}
        />
      )}
      {status === "uploading" && <p className="hint">Uploading…</p>}
      {status === "error" && (
        <p className="notice notice-error">
          The upload didn&apos;t work. Try another image, or publish without it.
        </p>
      )}
    </div>
  );
}
```

- [ ] **Step 3: Sell action** (`src/app/sell/actions.ts`): add `proofImagePath: string;` to `SellValues`; read `proofImagePath: String(formData.get("proof_image_path") ?? "")`; add `BAD_PROOF: "The screenshot upload didn't work. Remove it and add it again, or publish without it."` to `DB_ERRORS`; after the PayPal email check add

```ts
  if (values.proofImagePath && !PROOF_PATH_RE.test(values.proofImagePath)) {
    return fail(DB_ERRORS.BAD_PROOF);
  }
```
and pass `p_proof_image_path: values.proofImagePath || null` to the RPC. Import `PROOF_PATH_RE` from `@/lib/images`.

- [ ] **Step 4: Sell page** (`src/app/sell/page.tsx`): select `"id, name, category, developer_id, image_path"`, then split so only plugins that have an image send one (most don't: a `null` on all 3,700 rows would weigh ~65 KB for phones):

```ts
type PluginRow = PluginOption & { image_path: string | null };
// ...in the paging loop, instead of plugins.push(...page):
    for (const { image_path, ...plugin } of page) {
      plugins.push(plugin);
      if (image_path) pluginImages[plugin.id] = image_path;
    }
```
with `const plugins: PluginOption[] = []; const pluginImages: Record<number, string> = {};`, `PluginOption` imported from `./SellForm`, and pass `userId={user.id}` and `pluginImages={pluginImages}` to `<SellForm>`.

- [ ] **Step 5: SellForm** — new props `userId: string; pluginImages: Record<number, string>;`. Insert `<ProofUpload userId={userId} defaultPath={values?.proofImagePath || undefined} />` between the Description field and the PayPal email field. At the top of the `<aside className="rules-panel">`, before the eyebrow:

```tsx
{selected && pluginImages[selected.plugin.id] && (
  // eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota
  <img
    className="rules-panel-visual"
    src={pluginImageUrl(pluginImages[selected.plugin.id])}
    alt={selected.label}
  />
)}
```

- [ ] **Step 6: CSS**

```css
.proof-preview {
  display: flex;
  align-items: center;
  gap: 16px;
}

.proof-preview img {
  width: 120px;
  height: 90px;
  object-fit: cover;
  object-position: top;
  border: 1px solid var(--line);
  border-radius: var(--radius-sm);
}

.input-file {
  padding-top: 9px;
}

.rules-panel-visual {
  display: block;
  width: 100%;
  height: 160px;
  object-fit: contain;
  padding: 12px;
  background: var(--surface);
  border-radius: var(--radius);
}
```
(check `.rules-panel` background first: if it is already white, drop the background line.)

- [ ] **Step 7: Verify** — tsc + lint. Browser, signed in: pick a big photo → "Uploading…" → preview; Network shows a POST to `/storage/v1/object/listing-proofs/<uid>/<uuid>.jpg` well under 1 MB; Remove → field back; publish with proof → listing page shows `ProofViewer` for a visitor; publish without proof still works; a server-side error (e.g. bad price) keeps the preview.

- [ ] **Step 8: Commit** — `git commit -m "Sell form: optional license screenshot upload, plugin visual in the rules panel"`

---

### Task 5: Seller adds / replaces / removes the proof on their listing

**Files:**
- Create: `src/app/listings/[id]/actions.ts`
- Modify: `src/app/listings/[id]/page.tsx`

**Interfaces:**
- Consumes: `ProofUpload` (Task 4), `PROOF_BUCKET`, `PROOF_PATH_RE` (Task 2).
- Produces: server action `setListingProof(formData: FormData): Promise<void>` reading `listing_id` and `proof_image_path`.

- [ ] **Step 1: `src/app/listings/[id]/actions.ts`**

```ts
"use server";

import { revalidatePath } from "next/cache";
import { PROOF_BUCKET, PROOF_PATH_RE } from "@/lib/images";
import { createClient } from "@/lib/supabase/server";

// The seller adds, replaces or removes the license screenshot of their own listing.
// RLS only lets the seller update it, while the listing is active or removed.
// The file it replaces is deleted.
export async function setListingProof(formData: FormData) {
  const id = Number(formData.get("listing_id"));
  const path = String(formData.get("proof_image_path") ?? "");
  if (!Number.isInteger(id) || id <= 0 || (path && !PROOF_PATH_RE.test(path))) return;

  const supabase = await createClient();
  const { data: before } = await supabase
    .from("listings")
    .select("proof_image_path")
    .eq("id", id)
    .maybeSingle<{ proof_image_path: string | null }>();

  const { data: updated, error } = await supabase
    .from("listings")
    .update({ proof_image_path: path || null })
    .eq("id", id)
    .select("id");
  if (error || !updated?.length) {
    if (error) console.error("set proof failed:", error.message);
    return;
  }

  const old = before?.proof_image_path;
  if (old && old !== path) {
    const { error: removeError } = await supabase.storage.from(PROOF_BUCKET).remove([old]);
    if (removeError) console.error("old proof removal failed:", removeError.message);
  }
  revalidatePath(`/listings/${id}`);
}
```

- [ ] **Step 2: Editor block on the listing page**, in the aside after the seller card (next to the `ProofViewer` line of Task 3):

```tsx
{isSeller && user && (listing.status === "active" || listing.status === "removed") && (
  <form action={setListingProof} className="card proof-card">
    <input type="hidden" name="listing_id" value={listing.id} />
    <ProofUpload userId={user.id} defaultPath={listing.proof_image_path ?? undefined} />
    <button className="btn btn-block" type="submit">
      Save screenshot
    </button>
  </form>
)}
```

- [ ] **Step 3: Verify** — as the seller of an existing listing: add a screenshot + Save → reload shows it (open the listing in a private window: visitor sees `ProofViewer`); replace → old file gone from Storage (Supabase > Storage > listing-proofs); Remove + Save → badge gone from the listing and its Browse card.

- [ ] **Step 4: Commit** — `git commit -m "Sellers can add, replace or remove the license screenshot of their listing"`

---

### Task 6: Account deletion + Privacy policy

**Files:**
- Modify: `src/app/account/actions.ts` (delete account action)
- Modify: `src/app/privacy/page.tsx` (EN + FR)

- [ ] **Step 1: Delete the screenshots with the account** — in the delete-account action, right after the `listing_alerts` cleanup:

```ts
  // License screenshots are public files: they go with the account (migration 0048).
  const { error: proofsDbError } = await supabase.rpc("clear_my_proofs");
  if (proofsDbError) console.error("proof paths cleanup failed:", proofsDbError.message);
  const { data: proofFiles } = await supabase.storage.from(PROOF_BUCKET).list(user.id, { limit: 1000 });
  if (proofFiles?.length) {
    const { error: proofsError } = await supabase.storage
      .from(PROOF_BUCKET)
      .remove(proofFiles.map((f) => `${user.id}/${f.name}`));
    if (proofsError) console.error("proof files cleanup failed:", proofsError.message);
  }
```

- [ ] **Step 2: Privacy policy**, both languages, dates → "27 September 2026" / "27 septembre 2026":
  - §1 Listings: "the plugin, version, price, description, the optional screenshot of your license, and the PayPal email you enter when selling." / FR: "le plugin, la version, le prix, la description, la capture facultative de votre licence et l'email PayPal que vous indiquez pour vendre."
  - §3 Everyone: "your listings (without your PayPal email), including the license screenshot if you add one, ..." / FR: "vos annonces (sans votre email PayPal), y compris la capture de licence si vous en ajoutez une, ..."
  - §6 new item: "**License screenshots:** until you remove them from your listing, or delete your account." / FR: "**Captures de licence :** jusqu'à ce que vous les retiriez de votre annonce ou supprimiez votre compte."

- [ ] **Step 3: Verify** — tsc + lint; read both language blocks side by side.

- [ ] **Step 4: Commit** — `git commit -m "Delete license screenshots with the account, privacy policy updated"`

---

### Task 7: Fill the official images

**Files:**
- Create: `supabase/scripts/set-plugin-image.mjs`

**Interfaces:**
- Consumes: `plugins.image_path`, bucket `plugin-images`, service role grants (Task 1).

- [ ] **Step 1: The script**

```js
// Sets the official visual of a catalogue plugin (migration 0048): finds the og:image of the
// plugin's official product page (or takes a direct image URL), saves a local copy to look at,
// and with --save copies it into the plugin-images bucket and records it on the plugin.
//
// Usage (from the repo root):
//   node --env-file=.env.local supabase/scripts/set-plugin-image.mjs <plugin id> <url>          (preview only)
//   node --env-file=.env.local supabase/scripts/set-plugin-image.mjs <plugin id> <url> --save
import { writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createClient } from "@supabase/supabase-js";

const [pluginId, pageUrl, flag] = process.argv.slice(2);
if (!/^\d+$/.test(pluginId ?? "") || !pageUrl) {
  console.error("Usage: set-plugin-image.mjs <plugin id> <official page or image URL> [--save]");
  process.exit(1);
}

const TYPES = { "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp" };
const HEADERS = {
  "user-agent":
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
};

async function findImageUrl(url) {
  const res = await fetch(url, { headers: HEADERS, redirect: "follow" });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  if ((res.headers.get("content-type") ?? "").startsWith("image/")) return url;
  const html = await res.text();
  for (const tag of html.match(/<meta\b[^>]*>/gi) ?? []) {
    const key = /(?:property|name)\s*=\s*["']([^"']+)["']/i.exec(tag)?.[1]?.toLowerCase();
    const content = /content\s*=\s*["']([^"']+)["']/i.exec(tag)?.[1];
    if (content && ["og:image", "og:image:secure_url", "twitter:image"].includes(key)) {
      return new URL(content.replaceAll("&amp;", "&"), res.url).href;
    }
  }
  throw new Error(`No og:image on ${url}`);
}

const admin = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const { data: plugin, error: pluginError } = await admin
  .from("plugins")
  .select("id, name, image_path")
  .eq("id", Number(pluginId))
  .single();
if (pluginError) throw pluginError;

const imageUrl = await findImageUrl(pageUrl);
const res = await fetch(imageUrl, { headers: HEADERS });
const type = (res.headers.get("content-type") ?? "").split(";")[0].trim();
const ext = TYPES[type];
if (!res.ok || !ext) throw new Error(`${imageUrl}: HTTP ${res.status}, type ${type}`);
const bytes = Buffer.from(await res.arrayBuffer());
if (bytes.length > 5 * 1024 * 1024) throw new Error(`${imageUrl}: larger than 5 MB`);

const preview = join(tmpdir(), `plugin-${plugin.id}.${ext}`);
await writeFile(preview, bytes);
console.log(`${plugin.name}: ${imageUrl}\npreview: ${preview}`);
if (flag !== "--save") process.exit(0);

// A new name each time, so browsers and the CDN never show a cached older image.
const path = `${plugin.id}-${Date.now()}.${ext}`;
const { error: uploadError } = await admin.storage
  .from("plugin-images")
  .upload(path, bytes, { contentType: type });
if (uploadError) throw uploadError;

const { error: updateError } = await admin.from("plugins").update({ image_path: path }).eq("id", plugin.id);
if (updateError) throw updateError;
if (plugin.image_path) await admin.storage.from("plugin-images").remove([plugin.image_path]);
console.log(`saved: plugin-images/${path}`);
```

- [ ] **Step 2: List the plugins that have a listing**

```bash
node --env-file=.env.local -e 'const {createClient}=require("@supabase/supabase-js");createClient(process.env.NEXT_PUBLIC_SUPABASE_URL,process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY).from("listing_cards").select("plugin_id, developer_name, plugin_name, plugin_image_path").then(({data,error})=>console.log(error ?? data))'
```

- [ ] **Step 3: For each one** — find the official product page on the developer's own site (right product, right major version), run the preview, look at the image (Read tool on the preview file); if it is a logo/banner rather than a packshot or interface, find a better image URL on the same official site and pass it directly. Then run again with `--save`.

- [ ] **Step 4: Verify** — `/browse` and each listing page show the images.

- [ ] **Step 5: Commit** — `git commit -m "Script to set a plugin's official visual"`

---

### Task 8: End-to-end check, docs, deploy

- [ ] **Step 1:** Full pass in the browser preview at desktop and 375px width: Browse, home, account, a listing with image + proof, one with neither, Sell with and without proof.
- [ ] **Step 2:** `npm run build` passes.
- [ ] **Step 3:** Update `CLAUDE.md` (build-order log: what shipped, migration 0048, the script, "proof is public, never say verified", the images are filled by hand with the script as listings arrive).
- [ ] **Step 4:** Commit, then push to `main` (Vercel deploys) only after migration 0048 is confirmed applied.
