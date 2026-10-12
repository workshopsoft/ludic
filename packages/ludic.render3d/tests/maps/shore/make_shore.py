#!/usr/bin/env python3
"""make_shore.py - the `shore` fixture (water bodies, the wet mask and the land-use mask), deterministic.

Three tiles of 64 m at 64 texels (1 m a texel), origin (-96, -32), heights -10 .. 10 m (offset 0):

  tile 0 (x -96 .. -32)  the sea (floor -3 m, x < -70), a shore ramp to +2 m by x = -60, land at +2 m with a DRY CUT
                         below sea level (x -52 .. -40, z -10 .. 10, floor -2 m) ringed by a 2 m pad. Wet mask: wet only
                         where the open sea is; the cut is dry. Land-use mask: seabed, sand, grass, pad, road.
  tile 1 (x -32 .. 32)   land at +2 m with a pentagonal lake basin (floor -1 m) and a small hollow (floor 0 m) in the
                         corner of the basin's bounding box, outside the pentagon. Wet mask: all dry (the lake is a mesh).
                         Land-use mask: grass, road, park, and the lake bed as sand.
  tile 2 (x 32 .. 96)    flat land at +2 m, no wet mask and no land-use mask (it draws the ground's tint).

Water meshes (glb, node "water"): lake.glb, the pentagon at y = 1.2 m; pads.glb, fourteen 2 m squares at y = 2.05 m
on tile 2 (bodies 3 .. 16), one primitive each in its own node pad0 .. pad13.

Run from anywhere: python3 make_shore.py  (writes beside itself). Needs numpy and Pillow.
"""
import json
import math
import os
import struct

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
RES = 64
TILE = 64.0
OX, OZ = -96.0, -32.0
HMIN, HMAX = -10.0, 10.0

# land-use classes
SEABED, SAND, GRASS, ROAD, PARK, PAD = 6, 1, 2, 3, 4, 5

LAKE_C = (0.0, 0.0)
LAKE_R = 14.0
LAKE_LEVEL = 1.2
PENTA = [(LAKE_C[0] + LAKE_R * math.sin(2 * math.pi * k / 5), LAKE_C[1] - LAKE_R * math.cos(2 * math.pi * k / 5)) for k in range(5)]


def inside_poly(x, z, poly):
    n = len(poly)
    c = False
    for i in range(n):
        x1, z1 = poly[i]
        x2, z2 = poly[(i + 1) % n]
        if (z1 > z) != (z2 > z) and x < (x2 - x1) * (z - z1) / (z2 - z1) + x1:
            c = not c
    return c


def poly_dist(x, z, poly):
    """distance from (x, z) to the polygon's outline"""
    best = 1e9
    n = len(poly)
    for i in range(n):
        x1, z1 = poly[i]
        x2, z2 = poly[(i + 1) % n]
        dx, dz = x2 - x1, z2 - z1
        t = max(0.0, min(1.0, ((x - x1) * dx + (z - z1) * dz) / (dx * dx + dz * dz)))
        px, pz = x1 + t * dx, z1 + t * dz
        best = min(best, math.hypot(x - px, z - pz))
    return best


def height(x, z):
    if x < -32.0:
        if x < -70.0:
            return -3.0
        if x < -60.0:
            return -3.0 + 5.0 * (x + 70.0) / 10.0
        if -52.0 <= x <= -40.0 and -10.0 <= z <= 10.0:
            return -2.0
        return 2.0
    if x < 32.0:
        if inside_poly(x, z, PENTA):
            d = poly_dist(x, z, PENTA)
            return -1.0 if d > 2.0 else 2.0 - 3.0 * d / 2.0      # a 2 m bank down to the bed
        # the hollow in the bounding box's corner, outside the pentagon
        if 9.0 <= x <= 12.0 and -14.0 <= z <= -11.0:
            return 0.0
        return 2.0
    return 2.0


def wet(x, z):
    # only the open sea: west of the shore, where the ground is below sea level
    return x < -61.0


def landuse(x, z):
    if x < -32.0:
        if 14.0 <= z <= 20.0 and x >= -60.0:
            return ROAD
        if x < -66.0:
            return SEABED
        if x < -58.0:
            return SAND
        if -54.0 <= x <= -38.0 and -12.0 <= z <= 12.0:
            return PAD
        return GRASS
    if 14.0 <= z <= 20.0:
        return ROAD
    if inside_poly(x, z, PENTA):
        return SAND
    if 12.0 <= x <= 28.0 and -28.0 <= z <= -16.0:
        return PARK
    return GRASS


def texel_centre(tx, i):
    return OX + tx * TILE + (i + 0.5) * TILE / RES


def write_tiles():
    for tx in range(3):
        h = np.zeros((RES, RES), dtype=np.uint16)
        w = np.zeros((RES, RES), dtype=np.uint8)
        m = np.zeros((RES, RES), dtype=np.uint8)
        for j in range(RES):
            z = OZ + (j + 0.5) * TILE / RES
            for i in range(RES):
                x = texel_centre(tx, i)
                raw = int(round((height(x, z) - HMIN) / (HMAX - HMIN) * 65535.0))
                h[j, i] = max(0, min(65535, raw))
                w[j, i] = 255 if wet(x, z) else 0
                m[j, i] = landuse(x, z)
        Image.fromarray(h).save(os.path.join(HERE, f"{tx}_0.png"))
        if tx < 2:
            Image.fromarray(w, mode="L").save(os.path.join(HERE, f"{tx}_0.wet.png"))
            Image.fromarray(m, mode="L").save(os.path.join(HERE, f"{tx}_0.mask.png"))


def glb(path, meshes):
    """meshes: [(node name, positions [(x, y, z)], indices [i])] -> a glb with one primitive a node"""
    blob = b""
    views, accs, gl_meshes, nodes = [], [], [], []
    for name, pos, idx in meshes:
        p = b"".join(struct.pack("<3f", *v) for v in pos)
        views.append({"buffer": 0, "byteOffset": len(blob), "byteLength": len(p), "target": 34962})
        blob += p
        lo = [min(v[k] for v in pos) for k in range(3)]
        hi = [max(v[k] for v in pos) for k in range(3)]
        accs.append({"bufferView": len(views) - 1, "componentType": 5126, "count": len(pos), "type": "VEC3", "min": lo, "max": hi})
        q = b"".join(struct.pack("<I", i) for i in idx)
        views.append({"buffer": 0, "byteOffset": len(blob), "byteLength": len(q), "target": 34963})
        blob += q
        accs.append({"bufferView": len(views) - 1, "componentType": 5125, "count": len(idx), "type": "SCALAR"})
        gl_meshes.append({"primitives": [{"attributes": {"POSITION": len(accs) - 2}, "indices": len(accs) - 1}]})
        nodes.append({"name": name, "mesh": len(gl_meshes) - 1})
    doc = {"asset": {"version": "2.0", "generator": "make_shore.py"}, "scene": 0, "scenes": [{"nodes": list(range(len(nodes)))}],
           "nodes": nodes, "meshes": gl_meshes, "accessors": accs, "bufferViews": views, "buffers": [{"byteLength": len(blob)}]}
    js = json.dumps(doc, separators=(",", ":"), sort_keys=True).encode()
    js += b" " * ((4 - len(js) % 4) % 4)
    blob += b"\0" * ((4 - len(blob) % 4) % 4)
    out = struct.pack("<III", 0x46546C67, 2, 12 + 8 + len(js) + 8 + len(blob))
    out += struct.pack("<II", len(js), 0x4E4F534A) + js + struct.pack("<II", len(blob), 0x004E4942) + blob
    with open(path, "wb") as f:
        f.write(out)


def write_meshes():
    # the lake: a fan over the pentagon, wound to face up (y up, counter-clockwise seen from above is -z... both sides draw)
    pos = [(LAKE_C[0], LAKE_LEVEL, LAKE_C[1])] + [(x, LAKE_LEVEL, z) for x, z in PENTA]
    idx = []
    for k in range(5):
        idx += [0, 1 + (k + 1) % 5, 1 + k]
    glb(os.path.join(HERE, "lake.glb"), [("water", pos, idx)])
    pads = []
    for k in range(14):
        cx = 40.0 + (k % 7) * 7.0
        cz = -6.0 if k < 7 else 6.0
        y = 2.05
        p = [(cx - 1, y, cz - 1), (cx + 1, y, cz - 1), (cx + 1, y, cz + 1), (cx - 1, y, cz + 1)]
        pads.append((f"pad{k}", p, [0, 2, 1, 0, 3, 2]))
    glb(os.path.join(HERE, "pads.glb"), pads)


if __name__ == "__main__":
    write_tiles()
    write_meshes()
    print("shore: 3 tiles, 2 wet masks, 2 land-use masks, lake.glb, pads.glb")
