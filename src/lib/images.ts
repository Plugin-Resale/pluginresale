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
