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
