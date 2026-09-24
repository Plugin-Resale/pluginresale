import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { marked } from "marked";

// Blog posts live in content/blog/<slug>.md. Each file starts with a front matter block:
//
// ---
// title: Is it legal to resell a plugin license?
// description: One or two sentences, used for search engines and the blog index.
// date: 2026-09-24
// updated: 2026-10-02   (optional)
// ---
//
// Files whose name starts with "_" are drafts and are not published.

const BLOG_DIR = path.join(process.cwd(), "content", "blog");

export type PostMeta = {
  slug: string;
  title: string;
  description: string;
  date: string;
  updated: string | null;
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
      readingMinutes: Math.max(1, Math.round(words / 230)),
    },
    body,
  };
}

export async function getAllPosts(): Promise<PostMeta[]> {
  const files = await readdir(BLOG_DIR);
  const slugs = files
    .filter((file) => file.endsWith(".md") && !file.startsWith("_"))
    .map((file) => file.slice(0, -3));
  const posts = await Promise.all(slugs.map(readPost));
  return posts
    .filter((post) => post !== null)
    .map((post) => post.meta)
    .sort((a, b) => b.date.localeCompare(a.date) || a.title.localeCompare(b.title));
}

export async function getPost(slug: string): Promise<Post | null> {
  if (!/^[a-z0-9-]+$/.test(slug)) return null;
  const post = await readPost(slug);
  if (!post) return null;
  return { ...post.meta, html: await marked.parse(post.body) };
}

export function formatPostDate(date: string) {
  return new Date(`${date}T00:00:00Z`).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  });
}
