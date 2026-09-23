import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/supabase/user";
import { SignInForm } from "./SignInForm";

export const metadata: Metadata = { title: "Sign in" };

export default async function SignInPage({ searchParams }: PageProps<"/signin">) {
  const { user } = await getCurrentUser();
  if (user) redirect("/account");

  const { error } = await searchParams;

  return (
    <main className="narrow">
      <div className="card">
        <h1>Sign in</h1>
        <p className="muted" style={{ margin: 0 }}>
          No password needed. Enter your email and we&apos;ll send you a link. New here? The same
          link creates your account.
        </p>
        {error === "link" && (
          <p className="notice notice-error">
            That sign-in link is invalid or has expired. Please request a new one.
          </p>
        )}
        <SignInForm />
      </div>
    </main>
  );
}
