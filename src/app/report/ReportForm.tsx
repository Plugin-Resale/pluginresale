"use client";

import { useActionState } from "react";
import { REPORT_REASONS, sendReport, type ReportState } from "./actions";

export function ReportForm({ where, email }: { where: string; email: string }) {
  const [state, action, pending] = useActionState<ReportState, FormData>(sendReport, {
    status: "idle",
  });

  if (state.status === "sent") {
    return (
      <p className="notice notice-success">
        Thanks, your report was sent. We&apos;ve emailed you a confirmation and will get back to
        you once we&apos;ve looked into it.
      </p>
    );
  }

  return (
    <form action={action}>
      <label className="label" htmlFor="where">
        What are you reporting?
      </label>
      <input
        className="input"
        id="where"
        name="where"
        defaultValue={where}
        placeholder="Listing number, username or page address"
        maxLength={300}
        required
      />

      <label className="label" htmlFor="reason">
        Reason
      </label>
      <select className="input" id="reason" name="reason" required defaultValue="">
        <option value="" disabled>
          Choose a reason
        </option>
        {Object.entries(REPORT_REASONS).map(([value, label]) => (
          <option key={value} value={value}>
            {label}
          </option>
        ))}
      </select>

      <label className="label" htmlFor="details">
        Details
      </label>
      <textarea
        className="input textarea"
        id="details"
        name="details"
        minLength={10}
        maxLength={3000}
        placeholder="What's wrong, and how do you know?"
        required
      />

      <label className="label" htmlFor="email">
        Your email
      </label>
      <input
        className="input"
        id="email"
        name="email"
        type="email"
        autoComplete="email"
        defaultValue={email}
        required
      />
      <p className="hint">We use it only to follow up on this report.</p>

      <label className="check form-check">
        <input type="checkbox" name="good_faith" required />
        <span>I believe in good faith that the information in this report is accurate.</span>
      </label>

      <button className="btn btn-primary btn-block" type="submit" disabled={pending}>
        {pending ? "Sending…" : "Send report"}
      </button>
      {state.status === "error" && <p className="notice notice-error">{state.message}</p>}
    </form>
  );
}
