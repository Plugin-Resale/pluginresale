import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/supabase/user";
import { UsernameForm } from "./UsernameForm";

export const metadata: Metadata = { title: "My account" };

export default async function AccountPage() {
  const { user, profile } = await getCurrentUser();
  if (!user) redirect("/signin");

  return (
    <main className="narrow">
      <div className="card">
        <h1>My account</h1>
        <p className="muted" style={{ margin: 0 }}>
          Signed in as <strong>{user.email}</strong>
        </p>
        {!profile?.username && (
          <p className="notice notice-success">
            Welcome! Choose a username to finish setting up your account.
          </p>
        )}
        <UsernameForm current={profile?.username ?? null} />
      </div>

      <form action="/auth/signout" method="post" style={{ marginTop: 16, textAlign: "center" }}>
        <button className="btn" type="submit">
          Sign out
        </button>
      </form>
    </main>
  );
}
