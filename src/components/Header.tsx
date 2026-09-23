import Link from "next/link";
import { getCurrentUser } from "@/lib/supabase/user";

export async function Header() {
  const { user, profile } = await getCurrentUser();

  return (
    <header className="site-header">
      <div className="container">
        <Link href="/" className="logo">
          Plugin<span>Resale</span>
        </Link>
        <nav>
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
