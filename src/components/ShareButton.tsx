"use client";

import { useState } from "react";

// Opens the phone's share sheet (WhatsApp, Instagram DMs, Messages, Facebook...), where the
// link preview image does the rest. Browsers without one (most desktops) copy the link instead.
export function ShareButton({
  url,
  title,
  text,
  label = "Share",
  className = "btn",
}: {
  url: string;
  title: string;
  text: string;
  label?: string;
  className?: string;
}) {
  const [copied, setCopied] = useState(false);

  async function share() {
    if (navigator.share) {
      try {
        await navigator.share({ title, text, url });
      } catch {
        // Share sheet closed without sharing: nothing to do.
      }
      return;
    }
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    } catch {
      window.prompt("Copy this link:", url);
    }
  }

  return (
    <button type="button" className={className} onClick={share}>
      {copied ? "Link copied ✓" : label}
    </button>
  );
}
