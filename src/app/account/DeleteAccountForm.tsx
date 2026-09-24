"use client";

import { useActionState } from "react";
import { deleteAccount, type DeleteAccountState } from "./actions";

export function DeleteAccountForm() {
  const [state, action, pending] = useActionState<DeleteAccountState, FormData>(
    deleteAccount,
    {},
  );

  return (
    <details className="delete-account">
      <summary>Delete my account</summary>
      <form action={action}>
        <p className="muted">
          Your listings go offline and your email and PayPal emails are erased. Past deals and
          reviews stay visible to the other side, under an anonymous &quot;deleted&quot; name.
          This can&apos;t be undone.
        </p>
        <label className="label" htmlFor="confirm">
          Type DELETE to confirm
        </label>
        <input className="input" id="confirm" name="confirm" autoComplete="off" required />
        <button className="btn btn-danger btn-block" type="submit" disabled={pending}>
          {pending ? "Deleting…" : "Delete my account for good"}
        </button>
        {state.error && <p className="notice notice-error">{state.error}</p>}
      </form>
    </details>
  );
}
