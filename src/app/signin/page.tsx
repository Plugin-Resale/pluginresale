import type { Metadata } from "next";
import Link from "next/link";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { safeNext } from "@/lib/next-path";
import { getCurrentUser } from "@/lib/supabase/user";
import { signInWithGoogle } from "./actions";
import { SignInForm } from "./SignInForm";

// Google refuses to sign in inside the Instagram / Facebook / TikTok in-app browsers.
const IN_APP_BROWSER =
  /Instagram|FBAN|FBAV|FB_IAB|FBIOS|BytedanceWebview|musical_ly|LinkedInApp|Snapchat/i;

export const metadata: Metadata = {
  title: "Sign in",
  robots: { index: false },
};

export default async function SignInPage({
  searchParams,
}: PageProps<"/signin">) {
  const { error, deleted, next: rawNext } = await searchParams;
  const next = safeNext(rawNext) ?? undefined;

  const { user } = await getCurrentUser();
  if (user) redirect(next ?? "/account");

  const inAppBrowser = IN_APP_BROWSER.test(
    (await headers()).get("user-agent") ?? "",
  );

  return (
    <main className="narrow">
      <div className="card">
        <h1>Sign in</h1>
        <p className="muted" style={{ margin: 0 }}>
          No password needed. Continue with Google, or enter your email and
          we&apos;ll send you a link. New here? Either way creates your account.
        </p>
        {deleted && (
          <p className="notice notice-success">
            Your account has been deleted. Goodbye!
          </p>
        )}
        {error === "link" && (
          <p className="notice notice-error">
            That sign-in link is invalid or has expired, or Google sign-in was
            cancelled. Please try again.
          </p>
        )}
        {error === "google" && (
          <p className="notice notice-error">
            Google sign-in is unavailable right now. Please use your email
            instead.
          </p>
        )}
        {inAppBrowser ? (
          <p className="hint">
            To continue with Google, open this page in Safari or Chrome (•••
            menu, then &ldquo;Open in browser&rdquo;). Or just use your email
            below.
          </p>
        ) : (
          <form action={signInWithGoogle}>
            {next && <input type="hidden" name="next" value={next} />}
            <button className="btn btn-block btn-google" type="submit">
              <svg
                width="18"
                height="18"
                viewBox="0 0 48 48"
                aria-hidden="true"
              >
                <path
                  fill="#EA4335"
                  d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"
                />
                <path
                  fill="#4285F4"
                  d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"
                />
                <path
                  fill="#FBBC05"
                  d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"
                />
                <path
                  fill="#34A853"
                  d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"
                />
              </svg>
              Continue with Google
            </button>
          </form>
        )}
        <p className="auth-or">or</p>
        <SignInForm next={next} />
        <p className="hint">
          New accounts accept our <Link href="/terms">Terms of Service</Link>{" "}
          when choosing a username. See how we handle your data in our{" "}
          <Link href="/privacy">Privacy Policy</Link>.
        </p>
      </div>
    </main>
  );
}
