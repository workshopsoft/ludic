#!/usr/bin/env python3
"""sheet.py DIR [DIR ...] - a contact sheet of a lab scene's shots: DIR/sheet.png, the PNGs in DIR
(sheet.png itself excepted) in name order, two to a row at 640 wide, each captioned with its name."""
import glob, os, sys
from PIL import Image, ImageDraw

def sheet(out):
    paths = [p for p in sorted(glob.glob(os.path.join(out, '*.png'))) if os.path.basename(p) != 'sheet.png']
    if not paths:
        print(f'lab: {out}: no shots')
        return 1
    ims = [Image.open(p).convert('RGB') for p in paths]
    w = 640
    h = w * ims[0].height // ims[0].width
    cols = 2 if len(ims) > 1 else 1
    rows = (len(ims) + cols - 1) // cols
    s = Image.new('RGB', (w * cols, h * rows), (0, 0, 0))
    d = ImageDraw.Draw(s)
    for i, (p, im) in enumerate(zip(paths, ims)):
        x, y = (i % cols) * w, (i // cols) * h
        s.paste(im.resize((w, h)), (x, y))
        d.rectangle((x, y, x + w, y + 18), fill=(0, 0, 0))
        d.text((x + 6, y + 3), os.path.splitext(os.path.basename(p))[0], fill=(255, 255, 255))
    s.save(os.path.join(out, 'sheet.png'))
    print(f'lab: {out}: {len(ims)} shots, sheet.png')
    return 0

if __name__ == '__main__':
    sys.exit(max([sheet(d) for d in sys.argv[1:]] or [2]))
