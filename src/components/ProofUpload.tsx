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
