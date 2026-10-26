# Builds the Instagram/Facebook carousel of a blog interview (1080x1350 JPEG slides) from a JSON
# config, with headless Chrome, in the site colours and fonts. Same look as the carousels made
# since the Ohad Nissim interview (Oct 2026). Example config: ../references/carousel-example.json
#
# Usage (from the repo root):
#   python3 -I .claude/skills/interview-plugin-resale/scripts/carousel.py <config.json>
# Writes public/blog/<slug>/instagram/slide-N.jpg and a contact sheet in the scratch dir
# (printed at the end) to look at all slides at once.
#
# Slide types (each slide is an object with "type"):
#   cover : photo, name ("First<br>Last"), subtitle, [position], [full] (true = photo full bleed, text over it at the bottom)
#   quote : theme ("light"|"dark"), kicker, quote, sub, [size]
#   photo : photo, kicker, quote, sub, [position], [size]  (photo full bleed, text at the bottom)
#   list  : theme, kicker, items: [{title, tag, text}]  (2 to 4 items)
#   answer: theme, kicker, question, paragraphs: [...], [size]  (a whole Q&A on one slide: the
#           question as the title, the guest's full answer below, no quote marks; size = answer
#           font size, default 34, lower it for long answers; question may be "" on a second slide
#           that continues a long answer)
#   shot  : theme, image, kicker, title, text  (a plugin screenshot on top, its name and the guest's
#           words about it below; image is a file in public/blog/<slug>/, transparent PNG is fine;
#           [imgh] = max image height, default 520, lower it when the text is long)
#   end   : like photo, footer shows pluginresale.com/blog and sub should say
#           "Full interview on our blog, link in bio · Follow @handle"
# "photo" is a file name inside public/blog/<slug>/. "position" is a CSS background-position.
# Quotes get the orange quote marks automatically: write them without quote marks. "marks": false
# on a quote/photo/end slide drops them (a question, or our own text rather than the guest's).
# Cover options: "kicker" (default "Interview") and "size" (name font size, default 118).
# Top-level "out" (default "instagram") = the folder under public/blog/<slug>/ the slides go to:
# use another one (e.g. "instagram-extract-netflix") for a later post made from the same interview,
# so the original carousel is not overwritten.
import json, os, subprocess, sys, tempfile, html as h
from PIL import Image

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cfg = json.load(open(sys.argv[1]))
slug, handle = cfg["slug"], cfg["handle"]
slides = cfg["slides"]
N = len(slides)
photo_dir = os.path.abspath(os.path.join("public", "blog", slug))
out_dir = os.path.join(photo_dir, cfg.get("out", "instagram"))
os.makedirs(out_dir, exist_ok=True)
tmp = tempfile.mkdtemp(prefix="carousel-")

CSS = """
@import url('https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,600;12..96,700&family=IBM+Plex+Sans:wght@400;500&family=IBM+Plex+Mono:wght@500&display=block');
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:1080px;height:1350px;overflow:hidden}
body{font-family:'IBM Plex Sans';position:relative}
.light{background:#F2EFE8;color:#17171B}.dark{background:#17171B;color:#F2EFE8}
.logo{position:absolute;top:66px;left:72px;font-family:'Bricolage Grotesque';font-weight:700;font-size:36px;letter-spacing:-.5px;z-index:3}
.logo span,.o,.kick{color:#E0592A}.light .logo span,.light .o,.light .kick{color:#C2410C}
.foot{position:absolute;left:72px;right:72px;bottom:66px;border-top:1.5px solid rgba(128,128,128,.35);padding-top:26px;display:flex;justify-content:space-between;font-family:'IBM Plex Mono';font-size:22px;z-index:3;opacity:.85}
.foot b{font-weight:500}
.mid{position:absolute;left:72px;right:72px;top:150px;bottom:170px;display:flex;flex-direction:column;justify-content:center;padding-bottom:60px;z-index:3}
.bottom{position:absolute;left:72px;right:72px;bottom:190px;z-index:3}
.kick{font-family:'IBM Plex Mono';font-weight:500;font-size:24px;letter-spacing:5px;text-transform:uppercase;margin-bottom:30px}
h1{font-family:'Bricolage Grotesque';font-weight:700;letter-spacing:-1.5px;line-height:1.06}
p.sub{font-size:31px;line-height:1.5;margin-top:40px;opacity:.85}
.bottom p.sub{font-size:27px;margin-top:28px}
.photo{position:absolute;inset:0;background-size:cover;z-index:1}
.shade{position:absolute;inset:0;z-index:2;background:linear-gradient(to bottom,rgba(23,23,27,.55) 0%,rgba(23,23,27,0) 22%,rgba(23,23,27,0) 38%,rgba(23,23,27,.88) 66%,#17171B 100%)}
.item{border-top:1.5px solid rgba(128,128,128,.3);padding:30px 0}
.item:last-child{border-bottom:1.5px solid rgba(128,128,128,.3)}
.item h2{font-family:'Bricolage Grotesque';font-weight:700;font-size:44px;letter-spacing:-.5px}
.item .tag{font-family:'IBM Plex Mono';font-size:19px;letter-spacing:3px;color:#C2410C;margin:6px 0 12px;text-transform:uppercase}
.dark .item .tag{color:#E0592A}
.item p{font-size:27px;line-height:1.45;opacity:.85}
"""

def esc(s):  # keep <br> and <b> written in the config, escape the rest
    return h.escape(s, quote=False).replace("&lt;br&gt;", "<br>").replace("&lt;b&gt;", "<b>").replace("&lt;/b&gt;", "</b>")

def size(s, photo=False):
    if s.get("size"):
        return s["size"]
    n = len(s["quote"])
    if photo:
        return 72 if n <= 50 else 64 if n <= 80 else 56
    return 150 if n <= 20 else 88 if n <= 50 else 80 if n <= 75 else 68

def q(t, marks=True):
    return f'<span class="o">“</span>{esc(t)}<span class="o">”</span>' if marks else esc(t)

LOGO = '<div class="logo">plugin<span>resale</span></div>'

def foot(i, left=None):
    left = left or f"{h.escape(handle)} × <b>pluginresale.com</b>"
    return f'<div class="foot"><span>{left}</span><span>{i}/{N}</span></div>'

def bg(s):
    pos = s.get("position", "center")
    return f'<div class="photo" style="background-image:url(\'file://{photo_dir}/{s["photo"]}\');background-position:{pos}"></div><div class="shade"></div>'

def render(i, s):
    t = s["type"]
    if t == "cover" and s.get("full"):
        pos = s.get("position", "center 20%")
        return "dark", f'''<div class="photo" style="background-image:url('file://{photo_dir}/{s["photo"]}');background-position:{pos}"></div>
<div style="position:absolute;inset:0;z-index:2;background:linear-gradient(to bottom,rgba(23,23,27,.45) 0%,rgba(23,23,27,0) 16%,rgba(23,23,27,0) 50%,rgba(23,23,27,.75) 72%,rgba(23,23,27,.92) 100%)"></div>
{LOGO}<div style="position:absolute;left:72px;right:72px;bottom:170px;z-index:3"><div class="kick">{esc(s.get("kicker", "Interview"))}</div>
<h1 style="font-size:{s.get("size", 118)}px;line-height:.98">{esc(s["name"])}</h1>
<p class="sub" style="margin-top:26px;font-size:30px">{esc(s["subtitle"])}</p></div>
<div class="foot" style="opacity:1"><span>{h.escape(handle)} × <b>pluginresale.com</b></span><span style="color:#E0592A">Swipe →</span></div>'''
    if t == "cover":
        pos = s.get("position", "center 38%")
        return "light", f'''<div style="position:absolute;top:0;left:0;right:0;height:735px;background:url('file://{photo_dir}/{s["photo"]}') {pos}/cover"></div>
<div style="position:absolute;left:72px;right:72px;top:800px"><div class="kick">{esc(s.get("kicker", "Interview"))}</div>
<h1 style="font-size:{s.get("size", 118)}px;line-height:.98">{esc(s["name"])}</h1>
<p class="sub" style="margin-top:30px;font-size:30px">{esc(s["subtitle"])}</p></div>
<div class="foot" style="opacity:1"><span style="font-family:'Bricolage Grotesque';font-weight:700;font-size:32px">plugin<span style="color:#C2410C">resale</span></span><span style="color:#C2410C">Swipe →</span></div>'''
    if t == "quote":
        return s.get("theme", "light"), LOGO + f'''<div class="mid"><div class="kick">{esc(s["kicker"])}</div>
<h1 style="font-size:{size(s)}px">{q(s["quote"], s.get("marks", True))}</h1><p class="sub">{esc(s.get("sub", ""))}</p></div>''' + foot(i)
    if t in ("photo", "end"):
        left = "pluginresale.com/blog" if t == "end" else None
        return "dark", bg(s) + LOGO + f'''<div class="bottom"><div class="kick">{esc(s["kicker"])}</div>
<h1 style="font-size:{size(s, True)}px">{q(s["quote"], s.get("marks", True))}</h1><p class="sub">{esc(s.get("sub", ""))}</p></div>''' + foot(i, left)
    if t == "list":
        items = "".join(f'<div class="item"><h2>{esc(it["title"])}</h2><div class="tag">{esc(it["tag"])}</div><p>{esc(it["text"])}</p></div>' for it in s["items"])
        return s.get("theme", "light"), LOGO + f'<div class="mid"><div class="kick">{esc(s["kicker"])}</div>{items}</div>' + foot(i)
    if t == "answer":
        body = "".join(f'<p style="font-size:{s.get("size", 34)}px;line-height:1.45;margin-top:26px">{esc(x)}</p>' for x in s["paragraphs"])
        return s.get("theme", "light"), LOGO + f'''<div class="mid"><div class="kick">{esc(s["kicker"])}</div>
{f'<h1 style="font-size:60px;margin-bottom:22px">{esc(s["question"])}</h1>' if s["question"] else ""}{body}</div>''' + foot(i)
    if t == "shot":
        return s.get("theme", "dark"), LOGO + f'''<div class="mid" style="padding-bottom:20px">
<img src="file://{photo_dir}/{s["image"]}" style="max-width:100%;max-height:{s.get("imgh", 520)}px;object-fit:contain;align-self:center;border-radius:12px;margin-bottom:56px">
<div class="kick">{esc(s["kicker"])}</div><h1 style="font-size:64px">{esc(s["title"])}</h1>
<p class="sub" style="margin-top:28px">{esc(s["text"])}</p></div>''' + foot(i)
    raise SystemExit(f"unknown slide type {t}")

for i, s in enumerate(slides, 1):
    theme, body = render(i, s)
    page = os.path.join(tmp, f"s{i}.html")
    open(page, "w").write(f'<!doctype html><html><head><meta charset="utf-8"><style>{CSS}</style></head><body class="{theme}">{body}</body></html>')
    png = os.path.join(tmp, f"s{i}.png")
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files",
                    f"--screenshot={png}", "--window-size=1080,1350", "--virtual-time-budget=6000", "file://" + page],
                   capture_output=True)
    Image.open(png).convert("RGB").save(os.path.join(out_dir, f"slide-{i}.jpg"), "JPEG", quality=88, optimize=True)

thumbs = [Image.open(os.path.join(out_dir, f"slide-{i}.jpg")).resize((432, 540)) for i in range(1, N + 1)]
cols = 4
sheet = Image.new("RGB", (432 * cols, 540 * ((N + cols - 1) // cols)), "white")
for k, im in enumerate(thumbs):
    sheet.paste(im, ((k % cols) * 432, (k // cols) * 540))
sheet_path = os.path.join(tmp, "sheet.jpg")
sheet.save(sheet_path)
print(f"{N} slides in {out_dir}\ncontact sheet: {sheet_path}")
