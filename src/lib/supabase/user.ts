import { createClient } from "@/lib/supabase/server";

export type Profile = {
  id: string;
  username: string | null;
  created_at: string;
};

// Returns the signed-in user (verified with the Auth server) and their profile, or nulls.
export async function getCurrentUser() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return { user: null, profile: null };

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, username, created_at")
    .eq("id", user.id)
    .maybeSingle<Profile>();

  return { user, profile };
}
