import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Rating } from "@/components/Rating";
import { formatDate } from "@/lib/catalog";
import type { Review, SellerStats } from "@/lib/reviews";
import { createClient } from "@/lib/supabase/server";

export async function generateMetadata({
  params,
}: PageProps<"/u/[username]">): Promise<Metadata> {
  const { username } = await params;
  return { title: `@${username}` };
}

export default async function SellerProfilePage({ params }: PageProps<"/u/[username]">) {
  const { username } = await params;

  const supabase = await createClient();
  const { data: profile } = await supabase
    .from("profiles")
    .select("id, username, created_at")
    .eq("username", username)
    .maybeSingle();
  if (!profile) notFound();

  const [{ data: stats }, { data: reviews }] = await Promise.all([
    supabase.from("seller_stats").select("*").eq("seller_id", profile.id).maybeSingle<SellerStats>(),
    supabase
      .from("reviews")
      .select("*")
      .eq("target_id", profile.id)
      .order("created_at", { ascending: false })
      .returns<Review[]>(),
  ]);

  const authorIds = [...new Set((reviews ?? []).map((r) => r.author_id))];
  const { data: authors } = authorIds.length
    ? await supabase.from("profiles").select("id, username").in("id", authorIds)
    : { data: [] };
  const usernameOf = (id: string) => authors?.find((a) => a.id === id)?.username ?? "user";

  return (
    <main className="narrow narrow-wide">
      <div className="card">
        <div className="profile-head">
          <span className="avatar" aria-hidden="true">
            {profile.username?.[0]?.toUpperCase()}
          </span>
          <div>
            <h1>@{profile.username}</h1>
            <p className="muted">Member since {formatDate(profile.created_at.slice(0, 10))}</p>
          </div>
        </div>
        <div className="profile-stats">
          <div>
            <span className="price">{stats?.completed_sales ?? 0}</span>
            <span className="muted">completed sales</span>
          </div>
          <div>
            <span className="price">
              <Rating avg={stats?.avg_rating ?? null} count={stats?.review_count ?? 0} />
            </span>
            <span className="muted">rating</span>
          </div>
        </div>
      </div>

      <section className="card account-section">
        <h2 className="account-title">Reviews</h2>
        {reviews && reviews.length > 0 ? (
          <ul className="review-list">
            {reviews.map((r) => (
              <li key={r.id}>
                <div className="review-head">
                  <strong>@{usernameOf(r.author_id)}</strong>
                  <span className="rating">{r.rating}★</span>
                </div>
                {r.comment && <p>{r.comment}</p>}
              </li>
            ))}
          </ul>
        ) : (
          <p className="muted">No reviews yet.</p>
        )}
      </section>
    </main>
  );
}
