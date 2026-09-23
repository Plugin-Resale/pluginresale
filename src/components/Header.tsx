import Link from "next/link";
import { getCurrentUser } from "@/lib/supabase/user";

export async function Header() {
  const { user, profile } = await getCurrentUser();

  return (
    <header className="site-header">
      <div className="container">
        <Link href="/" className="logo">
          plugin<span>resale</span>
        </Link>
        <nav className="site-nav">
          <Link href="/developers" className="nav-link">
            Developers
          </Link>
          {user ? (
            <Link href="/account" className="btn">
              {profile?.username ?? "My account"}
            </Link>
          ) : (
            <Link href="/signin" className="btn">
              Sign in
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}
