#!/usr/bin/env python3
"""lightzone_check.py - OC-140.I6, the shot test for light zones (lightzone_lab.ludic). Reads build/lab/{zone,zone_nosun,
zone_off}/{above,side}.png (fixed exposure, no bloom, no GI, no shafts, no grain) and checks:

  above   the zone covers world x 0 .. 8 (the frame's columns from its left edge, found where the zone and no-zone frames
          differ, to its right edge); inside it, clear of the 0.25 m feather, the zone frame IS the no-sun frame (the sun
          contributes 0) while the no-zone frame is far brighter there (the sun was there to take away); outside it the
          zone frame IS the no-zone frame (a zone does nothing outside its box)
  both    every pixel the sun lights (no-zone minus no-sun > 12 of 255) is, in the zone frame, either the no-zone pixel
          or the no-sun pixel, or (the feather, a dusk between them) within 40 pixels of both kinds

Usage: python3 lightzone_check.py [build/lab]   exit 0 when every check holds. Needs numpy and Pillow.
"""
import sys

import numpy as np
from PIL import Image

LAB = sys.argv[1] if len(sys.argv) > 1 else "build/lab"
failed = 0


def load(scene, shot):
    return np.asarray(Image.open(f"{LAB}/{scene}/{shot}.png").convert("RGB")).astype(np.int32)


def near(mask, r):
    """mask grown by r pixels each way (a square), with summed-area tables"""
    m = np.pad(mask.astype(np.int32), ((r + 1, r), (r + 1, r)))
    c = m.cumsum(0).cumsum(1)
    h, w = mask.shape
    k = 2 * r + 1
    return (c[k:k + h, k:k + w] - c[0:h, k:k + w] - c[k:k + h, 0:w] + c[0:h, 0:w]) > 0


def check(name, ok, detail):
    global failed
    print(f"{'ok  ' if ok else 'FAIL'} {name}: {detail}")
    if not ok:
        failed += 1


for shot in ("above", "side"):
    z, n, o = load("zone", shot), load("zone_nosun", shot), load("zone_off", shot)
    lit = (o - n).max(axis=2) > 12
    as_off = np.abs(z - o).max(axis=2) <= 3
    as_nosun = np.abs(z - n).max(axis=2) <= 3
    other = lit & ~as_off & ~as_nosun
    taken = lit & as_nosun & ~as_off
    kept = lit & as_off & ~as_nosun
    dusk = other & near(taken, 40) & near(kept, 40)
    stray = other & ~dusk
    check(f"{shot}: a sunlit pixel is the no-zone or the no-sun pixel, or the feather's dusk between them", stray.sum() == 0 and taken.sum() > 0 and kept.sum() > 0,
          f"{lit.sum()} sunlit pixels: {kept.sum()} kept, {taken.sum()} with the sun taken away, {dusk.sum()} in the feather, {stray.sum()} stray")

    if shot != "above":
        continue
    h, w = lit.shape
    diff = np.abs(z - o).max(axis=2) > 8
    cols = np.where(diff[h // 2])[0]
    check("above: the zone's columns are found", len(cols) > 0, f"{cols.min() if len(cols) else '-'} .. {cols.max() if len(cols) else '-'}")
    if not len(cols):
        continue
    c0, c1 = int(cols.min()), int(cols.max())
    ppm = (c1 - c0) / 8.0                                   # pixels a metre (the zone is 8 m wide)
    check("above: the zone's left edge is world x = 0 (the frame's middle)", abs(c0 - w / 2) < 0.4 * ppm, f"column {c0}, middle {w / 2:.0f}, {ppm:.1f} px a metre")
    m = int(0.5 * ppm)                                      # clear of the 0.25 m feather and a little more
    inside = (slice(0, h), slice(c0 + m, c1 - m))
    outside = (slice(0, h), slice(0, c0 - m))
    zi, ni, oi = z[inside], n[inside], o[inside]
    zo, oo = z[outside], o[outside]
    d_in = np.abs(zi - ni)
    check("above: inside, the zone frame is the no-sun frame", d_in.mean() < 0.5 and np.percentile(d_in, 99.9) <= 2,
          f"mean |zone - nosun| {d_in.mean():.3f}, 99.9th percentile {np.percentile(d_in, 99.9):.0f}, max {d_in.max()}")
    sun = (oi - ni).mean()
    check("above: inside, the sun was there to take away", sun > 25, f"mean (nozone - nosun) {sun:.1f} of 255")
    d_out = np.abs(zo - oo)
    check("above: outside, the zone frame is the no-zone frame", d_out.mean() < 0.5 and np.percentile(d_out, 99.9) <= 2,
          f"mean |zone - nozone| {d_out.mean():.3f}, 99.9th percentile {np.percentile(d_out, 99.9):.0f}, max {d_out.max()}")

print(f"lightzone_check: {failed} failed")
sys.exit(1 if failed else 0)
