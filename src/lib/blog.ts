import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { connection } from "next/server";
import { marked } from "marked";

// Blog posts live in content/blog/<slug>.md. Each file starts with a front matter block:
//
// ---
// title: Is it legal to resell a plugin license?
// description: One or two sentences, used for search engines and the blog index.
// date: 2026-09-24
// updated: 2026-10-02   (optional)
// image: /blog/<slug>/photo.jpg   (optional, a photo in public/: used for the link preview)
// ---
//
// Photos inside a post are plain Markdown images, or a <figure> with a <figcaption>,
// pointing at files in public/blog/<slug>/.
//
// Files whose name starts with "_" are drafts and are not published.
// A post with a date in the future is scheduled: it stays hidden (404, not in the index)
// until that day, Paris time, then appears on its own without a redeploy.

const BLOG_DIR = path.join(process.cwd(), "content", "blog");

export type PostMeta = {
  slug: string;
  title: string;
  description: string;
  date: string;
  updated: string | null;
  image: string | null;
  readingMinutes: number;
};

export type Post = PostMeta & { html: string };

function parseFrontMatter(file: string, source: string) {
  const match = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?/.exec(source);
  if (!match) throw new Error(`${file}: missing front matter`);

  const fields: Record<string, string> = {};
  for (const line of match[1].split(/\r?\n/)) {
    const sep = line.indexOf(":");
    if (sep === -1) continue;
    fields[line.slice(0, sep).trim()] = line
      .slice(sep + 1)
      .trim()
      .replace(/^(["'])(.*)\1$/, "$2");
  }

  for (const key of ["title", "description", "date"]) {
    if (!fields[key]) throw new Error(`${file}: missing "${key}" in front matter`);
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fields.date)) {
    throw new Error(`${file}: date must be YYYY-MM-DD`);
  }
  if (fields.image && !/^\/blog\/[a-z0-9-]+\/[a-z0-9-]+\.(jpg|jpeg|png)$/.test(fields.image)) {
    throw new Error(`${file}: image must be a path like /blog/<slug>/photo.jpg`);
  }

  return { fields, body: source.slice(match[0].length) };
}

async function readPost(slug: string): Promise<{ meta: PostMeta; body: string } | null> {
  let source: string;
  try {
    source = await readFile(path.join(BLOG_DIR, `${slug}.md`), "utf8");
  } catch {
    return null;
  }

  const { fields, body } = parseFrontMatter(`${slug}.md`, source);
  const words = body.split(/\s+/).filter(Boolean).length;

  return {
    meta: {
      slug,
      title: fields.title,
      description: fields.description,
      date: fields.date,
      updated: fields.updated || null,
      image: fields.image || null,
      readingMinutes: Math.max(1, Math.round(words / 230)),
    },
    body,
  };
}

// Today's date in Paris, as YYYY-MM-DD.
function today() {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Europe/Paris" }).format(new Date());
}

async function readAllPosts() {
  const files = await readdir(BLOG_DIR);
  const slugs = files
    .filter((file) => file.endsWith(".md") && !file.startsWith("_"))
    .map((file) => file.slice(0, -3));
  const posts = await Promise.all(slugs.map(readPost));
  return posts.filter((post) => post !== null).map((post) => post.meta);
}

export async function getAllPosts(): Promise<PostMeta[]> {
  // Publication depends on today's date: always render at request time.
  await connection();
  const now = today();
  return (await readAllPosts())
    .filter((post) => post.date <= now)
    .sort((a, b) => b.date.localeCompare(a.date) || a.title.localeCompare(b.title));
}

export async function getPost(slug: string): Promise<Post | null> {
  if (!/^[a-z0-9-]+$/.test(slug)) return null;
  await connection();
  const now = today();
  const post = await readPost(slug);
  if (!post || post.meta.date > now) return null;

  // Links to posts that aren't published yet become plain text until they are.
  const scheduled = new Set(
    (await readAllPosts()).filter((p) => p.date > now).map((p) => p.slug),
  );
  const html = (await marked.parse(post.body)).replace(
    /<a href="\/blog\/([a-z0-9-]+)">([\s\S]*?)<\/a>/g,
    (link, target: string, text: string) => (scheduled.has(target) ? text : link),
  );
  return { ...post.meta, html };
}

export function formatPostDate(date: string) {
  return new Date(`${date}T00:00:00Z`).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  });
}
