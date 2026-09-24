import type { Metadata } from "next";
import { getCurrentUser } from "@/lib/supabase/user";
import { ReportForm } from "./ReportForm";

export const metadata: Metadata = {
  title: "Report a problem",
  description: "Report a listing, a user or content that breaks our Terms or the law.",
};

export default async function ReportPage({ searchParams }: PageProps<"/report">) {
  const { user } = await getCurrentUser();
  const { listing } = await searchParams;
  const listingId = typeof listing === "string" && /^\d+$/.test(listing) ? listing : null;

  return (
    <main className="narrow">
      <div className="card">
        <h1>Report a problem</h1>
        <p className="muted" style={{ margin: 0 }}>
          Report a listing, a user, a message or a review that breaks our Terms of Service or the
          law. We review every report and tell you what we decided.
        </p>
        <ReportForm
          where={listingId ? `Listing #${listingId}` : ""}
          email={user?.email ?? ""}
        />
      </div>
    </main>
  );
}
