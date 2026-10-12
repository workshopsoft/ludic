#!/usr/bin/env python3
"""make_lock.py - the `lock` fixture (terrain LOD lock), deterministic.

One tile of 128 m at 128 texels (1 m a texel), origin (0, 0), heights -20 .. 40 m (offset 0). Hilly ground (bumps a few
metres high and 20 to 40 m across, so every coarse level cuts corners) with, on top of it:

  a road   a curving strip 8 m wide (class 3) with a 2 m sidewalk each side (class 4, +0.15 m), graded along x
           (z = 40 + 12 sin(x / 25)); 6 m banks blend it into the hills, cut and fill
  a pad    flat at 9 m, x 80 .. 110, z 85 .. 110 (class 5); 4 m banks
  a shore  a round lake (centre (15, 112), radius 14 m, bed -2 m, class 6) ringed by a 4 m sand shore (class 1) that ramps
           from 0.3 m at the water to the hills
  the rest grass (class 2), free

Writes 0_0.png (16-bit grey heights) and 0_0.mask.png (8-bit classes), image row 0 at low z. Needs numpy and Pillow.
Run from anywhere: python3 make_lock.py
"""
import math
import os

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
RES = 128
TILE = 128.0
HMIN, HMAX = -20.0, 40.0
SHORE, GRASS, ROAD, WALK, PAD, BED = 1, 2, 3, 4, 5, 6


def hills(x, z):
    return 6.0 + 5.0 * math.sin(x / 9.0) * math.cos(z / 13.0) + 3.0 * math.sin((x + z) / 7.0)


def smooth(t):
    t = min(max(t, 0.0), 1.0)
    return t * t * (3.0 - 2.0 * t)


def road_at(x, z):
    """distance across the road from its centre line (vertical distance in z: the curve is gentle) and its grade"""
    cz = 40.0 + 12.0 * math.sin(x / 25.0)
    return abs(z - cz), 6.0 + 0.04 * (x - 64.0)


def cell(x, z):
    h = hills(x, z)
    cls = GRASS
    # the lake and its shore
    r = math.hypot(x - 15.0, z - 112.0)
    if r < 14.0:
        h, cls = -2.0, BED
    elif r < 18.0:
        h, cls = 0.3 + (h - 0.3) * smooth((r - 14.0) / 4.0), SHORE
    # the pad and its banks
    dx = max(80.0 - x, 0.0, x - 110.0)
    dz = max(85.0 - z, 0.0, z - 110.0)
    d = math.hypot(dx, dz)
    if d == 0.0:
        h, cls = 9.0, PAD
    elif d < 4.0 and cls == GRASS:
        h = 9.0 + (h - 9.0) * smooth(d / 4.0)
    # the road, its sidewalks and banks
    a, g = road_at(x, z)
    if a < 4.0:
        h, cls = g, ROAD
    elif a < 6.0:
        h, cls = g + 0.15, WALK
    elif a < 12.0 and cls == GRASS:
        h = g + 0.15 + (h - g - 0.15) * smooth((a - 6.0) / 6.0)
    return h, cls


def main():
    hq = np.zeros((RES, RES), dtype=np.uint16)
    m = np.zeros((RES, RES), dtype=np.uint8)
    for j in range(RES):
        z = (j + 0.5) * TILE / RES
        for i in range(RES):
            x = (i + 0.5) * TILE / RES
            h, c = cell(x, z)
            hq[j, i] = int(round((h - HMIN) / (HMAX - HMIN) * 65535.0))
            m[j, i] = c
    Image.fromarray(hq).save(os.path.join(HERE, "0_0.png"))
    Image.fromarray(m, mode="L").save(os.path.join(HERE, "0_0.mask.png"))
    print("lock: 1 tile, heights and land-use mask;", {int(k): int(v) for k, v in zip(*np.unique(m, return_counts=True))})


if __name__ == "__main__":
    main()
