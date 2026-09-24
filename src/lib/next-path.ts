// Only redirect back to a path within this site, never to an attacker-supplied URL.
export function safeNext(next: unknown): string | null {
  const value = typeof next === "string" ? next : String(next ?? "");
  return value.startsWith("/") && !value.startsWith("//") && !value.startsWith("/\\")
    ? value
    : null;
}

// Sign-in page URL that brings the user back to `path` once they are signed in.
export const signInUrl = (path: string) => `/signin?next=${encodeURIComponent(path)}`;
