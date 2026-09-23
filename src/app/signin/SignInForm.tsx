"use client";

import { useActionState } from "react";
import { sendMagicLink, type SignInState } from "./actions";

export function SignInForm() {
  const [state, action, pending] = useActionState<SignInState, FormData>(sendMagicLink, {
    status: "idle",
  });

  if (state.status === "sent") {
    return (
      <p className="notice notice-success">
        Check your inbox: we sent a sign-in link to <strong>{state.message}</strong>. You can
        close this tab.
      </p>
    );
  }

  return (
    <form action={action}>
      <label className="label" htmlFor="email">
        Email
      </label>
      <input
        className="input"
        id="email"
        name="email"
        type="email"
        autoComplete="email"
        placeholder="you@example.com"
        required
      />
      <button className="btn btn-primary btn-block" type="submit" disabled={pending}>
        {pending ? "Sending…" : "Email me a sign-in link"}
      </button>
      {state.status === "error" && <p className="notice notice-error">{state.message}</p>}
    </form>
  );
}
