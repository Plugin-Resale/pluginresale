"use client";

import Link from "next/link";
import { useActionState } from "react";
import { saveUsername, type UsernameState } from "./actions";

export function UsernameForm({
  current,
  termsAccepted,
}: {
  current: string | null;
  termsAccepted: boolean;
}) {
  const [state, action, pending] = useActionState<UsernameState, FormData>(saveUsername, {
    status: "idle",
  });

  return (
    <form action={action}>
      <label className="label" htmlFor="username">
        Username
      </label>
      <input
        className="input"
        id="username"
        name="username"
        defaultValue={current ?? ""}
        placeholder="e.g. synth_lover"
        autoComplete="username"
        minLength={3}
        maxLength={20}
        pattern="[a-zA-Z0-9_]{3,20}"
        required
      />
      <p className="hint">Shown publicly on your listings and reviews.</p>
      {!termsAccepted && (
        <label className="check form-check">
          <input type="checkbox" name="accept_terms" required />
          <span>
            I&apos;m 18 or older and I agree to the{" "}
            <Link href="/terms" target="_blank">
              Terms of Service
            </Link>
            . I&apos;ve read the{" "}
            <Link href="/privacy" target="_blank">
              Privacy Policy
            </Link>
            .
          </span>
        </label>
      )}
      <button className="btn btn-primary btn-block" type="submit" disabled={pending}>
        {pending ? "Saving…" : "Save username"}
      </button>
      {state.status === "saved" && (
        <p className="notice notice-success">Saved. You are now @{state.message}.</p>
      )}
      {state.status === "error" && <p className="notice notice-error">{state.message}</p>}
    </form>
  );
}
