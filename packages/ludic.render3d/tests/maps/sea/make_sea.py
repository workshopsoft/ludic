#!/usr/bin/env python3
"""make_sea.py - the `sea` fixture (the open sea against every kind of shore), deterministic.

Six by four tiles of 64 m at 64 texels (1 m a texel), origin (-192, -128), heights -10 .. 10 m (offset 0). The sea lies
west of a meandering coast x = coast(z); the land is +1.5 m. Along the coast, north to south:

  beach   z -128 .. -16   a 4 % beach (1 m of depth every 25 m, to 1.5 m, then 12 %, down to the 10 m floor), a river channel (z -48 .. -42) cut 0.6 m below the
                          sea whose mouth runs 12 m out to sea; a dry dock (x -20 .. 10, z -100 .. -80, floor -3 m,
                          below sea level and not sea); a rock (cone, 3 m radius, +2 m) 40 m out at (-120, -90); a dry
                          platform in the sea (x -108 .. -88, z -64 .. -52, top 0.5 m under the sea, masked dry: no
                          water and no foam on it), its north edge on the tile border z = -64
  cliff   z -16 .. 40     a rock face, 6 : 1 (12 m in 2 m)
  quay    z 40 .. 96      a wall: a sea floor at -10 m and a deck at +1 m, one texel between
  shoal   z 96 .. 128     a 4 % beach, and a sand bar 0.45 m under the sea 24 m across, 100 m out, in deep water

The map's margin (16 m) is deep sea, 10 m down, wherever it is more than 30 m off the shore.

Wet mask (the sea's own region): wet seaward of the coast line (x < coast + 2 m) wherever the ground is under 0.05 m,
except the dry dock. The river channel inland of the mouth is dry (its water is a mesh). Land-use classes: seabed,
sand, grass, pad (the quay's deck and the dock's floor).

Meshes (glb, node "water"): river.glb, the river's ribbon at y = 0, 6 m wide, from 60 m inland of the coast to 12 m
into the sea: where it overlaps the sea plane the two share a height.

Run from anywhere: python3 make_sea.py (writes beside itself). Needs numpy and Pillow.
"""
import math
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "shore"))
from make_shore import glb  # noqa: E402

RES = 64
TILE = 64.0
COLS, ROWS = 6, 4
OX, OZ = -192.0, -128.0
HMIN, HMAX = -10.0, 10.0
SEABED, SAND, GRASS, PAD = 6, 1, 2, 5
RIVER_Z0, RIVER_Z1 = -48.0, -42.0
RIVER_W = 6.0
DOCK = (-20.0, 10.0, -100.0, -80.0)
ROCK = (-120.0, -90.0)
SHOAL = (-135.0, 108.0)
CAISSON = (-108.0, -88.0, -64.0, -52.0)     # a dry platform in the sea, 0.5 m under its level; its north edge on a tile border


def coast(z):
    return -48.0 + 8.0 * math.sin(z * 0.045) + 3.0 * math.sin(z * 0.13 + 1.0)


def smooth(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3.0 - 2.0 * t)


def beach(u, x, z):
    if u < 0.0:
        return max(-10.0, 0.04 * u if u > -37.5 else -1.5 + 0.12 * (u + 37.5))
    if u < 28.0:
        return 0.04 * u
    land = 1.5 + 0.3 * math.sin(x * 0.05) * math.sin(z * 0.04)
    return 1.12 + (land - 1.12) * smooth(28.0, 44.0, u)


def cliff(u):
    if u < -2.0:
        return -10.0
    if u < 0.0:
        return -10.0 + 12.0 * (u + 2.0) / 2.0
    return 2.0


def quay(u):
    return -10.0 if u < 0.0 else 1.0


def height(x, z):
    u = x - coast(z)
    w_cliff = smooth(-26.0, -6.0, z) * (1.0 - smooth(30.0, 50.0, z))
    w_quay = smooth(30.0, 50.0, z) * (1.0 - smooth(86.0, 106.0, z))
    w_beach = max(0.0, 1.0 - w_cliff - w_quay)
    h = w_beach * beach(u, x, z) + w_cliff * cliff(u) + w_quay * quay(u)
    # the map's margins are deep sea: 10 m down at the north, south and west edges, out of sight of the shore
    edge = min(x - OX, OX + COLS * TILE - x, z - OZ, OZ + ROWS * TILE - z)
    h = min(h, h + (-10.0 - h) * (1.0 - smooth(0.0, 16.0, edge)) * smooth(-10.0, -30.0, u))
    # the river channel: 0.6 m under the sea from far inland to the mouth
    if RIVER_Z0 <= z <= RIVER_Z1 and u > -12.0 and u < 60.0:
        h = min(h, -0.6)
    # the platform in the sea
    if CAISSON[0] <= x <= CAISSON[1] and CAISSON[2] <= z <= CAISSON[3]:
        h = max(h, -0.5)
    # the dry dock
    if DOCK[0] <= x <= DOCK[1] and DOCK[2] <= z <= DOCK[3]:
        h = -3.0
    # the rock: a cone
    r = math.hypot(x - ROCK[0], z - ROCK[1])
    h = max(h, min(2.0, 2.0 - (r - 3.0) * 1.0)) if r < 12.0 else h
    # the shoal: a flat bar and its skirt
    r = math.hypot(x - SHOAL[0], z - SHOAL[1])
    if r < 22.0:
        h = max(h, -0.45 if r < 12.0 else -0.45 - 9.55 * (r - 12.0) / 10.0)
    return h


def in_dock(x, z):
    return DOCK[0] - 1.0 <= x <= DOCK[1] + 1.0 and DOCK[2] - 1.0 <= z <= DOCK[3] + 1.0


def in_caisson(x, z):
    return CAISSON[0] <= x <= CAISSON[1] and CAISSON[2] <= z <= CAISSON[3]


def dry_cut(x, z):
    return in_dock(x, z) or in_caisson(x, z)


def wet(x, z, h):
    return x < coast(z) + 2.0 and h < 0.05 and not dry_cut(x, z)


def landuse(x, z, h):
    u = x - coast(z)
    if in_dock(x, z):
        return PAD
    if 40.0 <= z <= 96.0 and 0.0 <= u <= 12.0:
        return PAD
    if h < -0.5:
        return SEABED
    if u < 40.0 and h < 1.4:
        return SAND
    return GRASS


def write_tiles():
    for tz in range(ROWS):
        for tx in range(COLS):
            hm = np.zeros((RES, RES), dtype=np.uint16)
            hs = np.zeros((RES + 2, RES + 2))
            for j in range(-1, RES + 1):
                z = OZ + tz * TILE + (j + 0.5) * TILE / RES
                for i in range(-1, RES + 1):
                    x = OX + tx * TILE + (i + 0.5) * TILE / RES
                    hs[j + 1, i + 1] = height(x, z)
            w = np.zeros((RES, RES), dtype=np.uint8)
            m = np.zeros((RES, RES), dtype=np.uint8)
            for j in range(RES):
                z = OZ + tz * TILE + (j + 0.5) * TILE / RES
                for i in range(RES):
                    x = OX + tx * TILE + (i + 0.5) * TILE / RES
                    h = hs[j + 1, i + 1]
                    raw = int(round((h - HMIN) / (HMAX - HMIN) * 65535.0))
                    hm[j, i] = max(0, min(65535, raw))
                    # one texel of the sea's own region counts as wet beyond the shore: the plane is under the ground
                    # there and the ground hides it; a gap is what the depth cannot hide
                    near = hs[j:j + 3, i:i + 3]
                    w[j, i] = 255 if (wet(x, z, h) or (not dry_cut(x, z) and x < coast(z) + 2.0 and float(near.min()) < 0.05)) else 0
                    m[j, i] = landuse(x, z, h)
            Image.fromarray(hm).save(os.path.join(HERE, f"{tx}_{tz}.png"))
            Image.fromarray(w, mode="L").save(os.path.join(HERE, f"{tx}_{tz}.wet.png"))
            Image.fromarray(m, mode="L").save(os.path.join(HERE, f"{tx}_{tz}.mask.png"))


def write_meshes():
    zc = 0.5 * (RIVER_Z0 + RIVER_Z1)
    x1 = coast(zc) + 60.0
    x0 = coast(zc) - 12.0
    hw = RIVER_W * 0.5
    pos = [(x0, 0.0, zc - hw), (x1, 0.0, zc - hw), (x1, 0.0, zc + hw), (x0, 0.0, zc + hw)]
    glb(os.path.join(HERE, "river.glb"), [("water", pos, [0, 2, 1, 0, 3, 2])])


if __name__ == "__main__":
    write_tiles()
    write_meshes()
    print(f"sea: {COLS * ROWS} tiles, wet and land-use masks, river.glb")
