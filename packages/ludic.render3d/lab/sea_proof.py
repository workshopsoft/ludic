#!/usr/bin/env python3
"""sea_proof.py <build/lab> <out dir> - the review pictures of the sea from the lab's shots (sea_lab.ludic, scenes sea, sea_dusk,
sea_old): the six coast bookmarks at noon and at dusk side by side (two sheets), the old plane against the sea (one sheet), and the
single views at half size. Run after the four scenes (lab/sea_check.py's input)."""
import os
import sys

from PIL import Image, ImageDraw

LAB = sys.argv[1] if len(sys.argv) > 1 else "build/lab"
OUT = sys.argv[2] if len(sys.argv) > 2 else "."
os.makedirs(OUT, exist_ok=True)


def shot(scene, name):
    return Image.open(os.path.join(LAB, scene, name + ".png")).convert("RGB")


def sheet(rows, left, right, label, path):
    """rows: bookmark names; left/right: the scenes; a 640 x 360 half each, a black label on the left one"""
    im = Image.new("RGB", (1280, 360 * len(rows)))
    for i, name in enumerate(rows):
        for j, scene in enumerate((left, right)):
            im.paste(shot(scene, name).resize((640, 360), Image.LANCZOS), (640 * j, 360 * i))
        d = ImageDraw.Draw(im)
        text = f"{name} {label}"
        d.rectangle((0, 360 * i, 8 * len(text) + 8, 360 * i + 16), fill=(0, 0, 0))
        d.text((4, 360 * i + 2), text, fill=(255, 255, 255))
    im.save(os.path.join(OUT, path))


sheet(["beach_low", "beach_high", "cliff"], "sea", "sea_dusk", "noon|dusk", "coast_pairs_1_beach_cliff.png")
sheet(["quay", "shoal", "rock"], "sea", "sea_dusk", "noon|dusk", "coast_pairs_2_quay_shoal_rock.png")
sheet(["beach_low", "beach_high", "shoal"], "sea_old", "sea", "old plane|sea", "before_after.png")
for name in ("drydock", "horizon", "horizon_corner", "mouth", "top_beach", "top_mouth", "top_platform"):
    shot("sea", name).resize((960, 540), Image.LANCZOS).save(os.path.join(OUT, f"noon_{name}.png"))
shot("sea_dusk", "horizon").resize((960, 540), Image.LANCZOS).save(os.path.join(OUT, "dusk_horizon.png"))
print("sea_proof: written to", OUT)
