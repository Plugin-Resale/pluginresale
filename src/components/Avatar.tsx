import { avatarUrl } from "@/lib/images";

// The user's profile photo, or the first letter of their username when they have none.
// Decorative: the username is always shown right next to it.
export function Avatar({ username, path }: { username: string | null; path: string | null }) {
  if (path) {
    // eslint-disable-next-line @next/next/no-img-element -- plain img, no Vercel image optimisation quota
    return <img className="avatar" src={avatarUrl(path)} alt="" />;
  }
  return (
    <span className="avatar" aria-hidden="true">
      {username?.[0]?.toUpperCase()}
    </span>
  );
}
