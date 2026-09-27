"use client";

import { useRouter } from "next/navigation";
import { useState, type ChangeEvent } from "react";
import { Avatar } from "@/components/Avatar";
import { AVATAR_BUCKET } from "@/lib/images";
import { resizeToJpeg } from "@/lib/resize-image";
import { createClient } from "@/lib/supabase/client";
import { setAvatar } from "./actions";

// Optional profile photo. Resized in the browser and uploaded straight to Supabase Storage,
// into the user's own folder, then saved on the profile right away (no separate Save button).
export function AvatarForm({
  userId,
  username,
  currentPath,
}: {
  userId: string;
  username: string | null;
  currentPath: string | null;
}) {
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const save = async (path: string) => {
    const result = await setAvatar(path);
    if (result.error) throw new Error(result.error);
    router.refresh();
  };

  const onChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;
    setBusy(true);
    setError(null);
    try {
      const blob = await resizeToJpeg(file, 512);
      const path = `${userId}/${crypto.randomUUID()}.jpg`;
      const { error: uploadError } = await createClient()
        .storage.from(AVATAR_BUCKET)
        .upload(path, blob, { contentType: "image/jpeg" });
      if (uploadError) throw uploadError;
      await save(path);
    } catch (err) {
      console.error("avatar upload failed:", err);
      setError("The upload didn't work. Try another photo.");
    } finally {
      setBusy(false);
    }
  };

  const remove = async () => {
    setBusy(true);
    setError(null);
    try {
      await save("");
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="avatar-form">
      <Avatar username={username} path={currentPath} />
      <div className="avatar-form-body">
        <div className="avatar-form-actions">
          <label className={busy ? "btn btn-disabled" : "btn"}>
            {busy ? "Saving…" : currentPath ? "Change photo" : "Add a photo"}
            <input
              type="file"
              accept="image/*"
              className="sr-only"
              onChange={onChange}
              disabled={busy}
            />
          </label>
          {currentPath && !busy && (
            <button type="button" className="link-button" onClick={remove}>
              Remove
            </button>
          )}
        </div>
        <p className="hint">
          Optional. Shown on your listings and your profile: buyers trust a face or a logo more
          than a letter.
        </p>
        {error && <p className="notice notice-error">{error}</p>}
      </div>
    </div>
  );
}
