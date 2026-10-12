# Resizes a guest's photos for a blog interview: JPEG, EXIF dropped (rotation applied first),
# 1600 px wide for landscape photos, 1100 px for portrait ones. Prints the <img> width/height.
#
# Usage (from the repo root):
#   python3 -I .claude/skills/interview-plugin-resale/scripts/prep-photos.py <slug> "<source file>=<name.jpg>" ...
# Example:
#   python3 -I .../prep-photos.py anotyne-nouel-interview "$HOME/Downloads/x/ano face studio.jpg=portrait.jpg"
import os, sys
from PIL import Image, ImageOps

if len(sys.argv) < 3:
    sys.exit(__doc__ or "usage: prep-photos.py <slug> '<src>=<name.jpg>' ...")

slug = sys.argv[1]
out_dir = os.path.join("public", "blog", slug)
os.makedirs(out_dir, exist_ok=True)

for pair in sys.argv[2:]:
    src, name = pair.rsplit("=", 1)
    im = ImageOps.exif_transpose(Image.open(src)).convert("RGB")
    width = 1600 if im.width >= im.height else 1100
    if im.width > width:
        im = im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)
    path = os.path.join(out_dir, name)
    im.save(path, "JPEG", quality=82, optimize=True, progressive=True)
    print(f'{path}  width="{im.width}" height="{im.height}"  {os.path.getsize(path) // 1024} kB')
