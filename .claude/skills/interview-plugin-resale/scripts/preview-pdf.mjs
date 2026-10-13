// One preview PDF for the guest to approve: the article (draft or published) followed by the
// carousel slides on the last page. Rendered with marked + headless Chrome, site fonts/colours.
//
// Usage (from the repo root):
//   node .claude/skills/interview-plugin-resale/scripts/preview-pdf.mjs <slug>
// Reads content/blog/_<slug>.md (or <slug>.md), public/blog/<slug>/instagram/slide-N.jpg and the
// Instagram caption in public/blog/<slug>/instagram/caption.txt (shown under the slides), writes ~/Downloads/<Slug-In-Title-Case>-Plugin-Resale-preview.pdf and prints its page count.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { marked } from "marked";

const slug = process.argv[2];
if (!slug) throw new Error("usage: preview-pdf.mjs <slug>");
const repo = process.cwd();
const mdPath = [`content/blog/_${slug}.md`, `content/blog/${slug}.md`].map((p) => path.join(repo, p)).find(fs.existsSync);
if (!mdPath) throw new Error(`no content/blog/_${slug}.md or ${slug}.md`);

const raw = fs.readFileSync(mdPath, "utf8");
const fm = raw.match(/^---\n([\s\S]*?)\n---\n/);
const title = fm[1].match(/^title: "?(.*?)"?$/m)[1];
const pub = path.join(repo, "public");
const body = marked
  .parse(raw.slice(fm[0].length))
  .replaceAll('src="/', `src="file://${pub}/`)
  .replaceAll('href="/', 'href="https://www.pluginresale.com/');

const carDir = path.join(pub, "blog", slug, "instagram");
const slides = fs.existsSync(carDir)
  ? fs.readdirSync(carDir).filter((f) => /^slide-\d+\.jpg$/.test(f)).sort((a, b) => parseInt(a.slice(6)) - parseInt(b.slice(6)))
  : [];
const captionFile = path.join(carDir, "caption.txt");
const caption = fs.existsSync(captionFile) ? fs.readFileSync(captionFile, "utf8").trim() : "";
if (slides.length && !caption) console.warn(`warning: no ${path.relative(repo, captionFile)}, the preview has no caption`);
const esc = (t) => t.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
const carousel = slides.length
  ? `<section class="car"><h2>Instagram / Facebook carousel</h2><div class="meta">${slides.length} slides, 1080 × 1350</div><div class="grid">${slides
      .map((f, i) => `<div><img src="file://${carDir}/${f}"><span>${i + 1}/${slides.length}</span></div>`)
      .join("")}</div>${caption ? `<h3>Instagram caption</h3><div class="caption">${esc(caption)}</div>` : ""}</section>`
  : "";

const htmlPage = `<!doctype html><html><head><meta charset="utf-8"><style>
@import url('https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,700&family=IBM+Plex+Sans:ital,wght@0,400;0,600;1,400&family=IBM+Plex+Mono:wght@500&display=block');
@page{size:A4;margin:18mm}
body{font-family:'IBM Plex Sans';color:#17171B;font-size:11pt;line-height:1.6}
.brand{font-family:'Bricolage Grotesque';font-weight:700;font-size:15pt}.brand span{color:#C2410C}
.meta{font-family:'IBM Plex Mono';font-size:8.5pt;color:#55545C;letter-spacing:1px;text-transform:uppercase;margin:4px 0 18px}
h1{font-family:'Bricolage Grotesque';font-size:24pt;line-height:1.15;margin:0 0 18px}
h2{font-family:'Bricolage Grotesque';font-size:17pt;margin:28px 0 6px;color:#C2410C}
h3{font-family:'Bricolage Grotesque';font-size:13pt;margin:20px 0 6px;break-after:avoid}
a{color:#C2410C}figure{margin:16px 0;break-inside:avoid}figure img{width:100%;height:auto;border-radius:8px}
figure img[height]{max-height:150mm;width:auto;max-width:100%}
figcaption{font-size:9pt;color:#55545C;margin-top:4px}hr{border:0;border-top:1px solid #D9D4C9;margin:28px 0}
.car{break-before:page}.car h2{margin-top:0}.grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px}
.caption{white-space:pre-wrap;font-size:10pt;border:1px solid #D9D4C9;border-radius:8px;padding:12px 14px;background:#F2EFE8;break-inside:avoid}
.grid div{break-inside:avoid}.grid img{width:100%;border-radius:4px;border:1px solid #D9D4C9}.grid span{font-family:'IBM Plex Mono';font-size:8pt;color:#55545C}
</style></head><body><div class="brand">plugin<span>resale</span></div><div class="meta">Preview · Interview · pluginresale.com/blog</div><h1>${title}</h1>${body}${carousel}</body></html>`;

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "preview-"));
const htmlFile = path.join(tmp, "preview.html");
fs.writeFileSync(htmlFile, htmlPage);
const name = slug.split("-").map((w) => (w === "interview" ? w : w[0].toUpperCase() + w.slice(1))).join("-");
const out = path.join(os.homedir(), "Downloads", `${name}-Plugin-Resale-preview.pdf`);
execFileSync("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", [
  "--headless=new", "--disable-gpu", "--allow-file-access-from-files", "--no-pdf-header-footer",
  "--virtual-time-budget=8000", `--print-to-pdf=${out}`, `file://${htmlFile}`,
], { stdio: "ignore" });
const pages = (fs.readFileSync(out, "latin1").match(/\/Type\s*\/Page[^s]/g) || []).length;
console.log(`${out} (${pages} pages, ${slides.length} slides)`);
