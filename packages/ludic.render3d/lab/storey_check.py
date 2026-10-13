#!/usr/bin/env python3
"""storey_check.py - the shot test for storey lines (boxkit_lab.ludic, scenes storeys, storeys_cpu, storeys_off). Reads
build/lab/{storeys,storeys_cpu,storeys_off}/*.png, shots taken straight on to a front wall (the camera on the horizontal at the
wall's picture centre, the wall square to it, so a picture row is a height and a metre is the same number of rows all the way up):

  lines      on the walls of the 3 floor flat (also on a plinth: counted from the pad, the eave being the last), the 12 floor flat, the 3 floor gable and the 72 floor shaft (low, and at 230 m) the
             rows that are darker than the wall around them sit at every multiple of 3.4 m above the base, none missing, none extra
  spacing    a line is 0.12 m thick (0.06 .. 0.30 m measured: the line's 0.12 m and a row's blur) at every height, whatever the instance's own height
  control    the same shots with no storey set (storeys_off) hold no line at all: what the others measure is the lines
  cpu        the CPU path (storeys_cpu) draws the same rows as the GPU path
  roofs      looking straight down, the roofs are the same picture with lines or without (a face that looks up has none)

Usage: python3 storey_check.py [build/lab]   exit 0 when every check holds. Needs numpy and Pillow.
"""
import math
import sys

import numpy as np
from PIL import Image

LAB = sys.argv[1] if len(sys.argv) > 1 else "build/lab"
FOV = math.radians(42.0)
STOREY = 3.4
failed = 0


def check(name, ok, detail):
    global failed
    print(f"{'ok  ' if ok else 'FAIL'} {name}: {detail}")
    if not ok:
        failed += 1


def load(scene, shot):
    return np.asarray(Image.open(f"{LAB}/{scene}/{shot}.png").convert("RGB")).astype(np.float64)


# shot: (camera distance to the wall plane, picture centre height, columns as metres either side of the centre, the heights
# the wall shows [bottom, top] clear of the foot's shading and the parapet's top edge, how many floors the wall has)
SHOTS = {
    "wall3": (40.0, 5.6, (1.5, 6.0), (1.0, 10.9), 3),
    "wall3p": (40.0, 5.6, (1.5, 6.0), (1.0, 10.9), 3),   # the same on a plinth 0.5 m: the lines are every storey up from its PAD, not its base
    "wall12": (90.0, 20.9, (2.0, 7.0), (1.0, 41.5), 12),
    "gable3": (40.0, 5.6, (1.0, 4.0), (1.0, 10.1), 3),
    "wall72": (40.0, 15.0, (3.0, 12.0), (1.0, 29.5), 72),
    "wall72top": (40.0, 230.0, (3.0, 12.0), (214.9, 245.2), 72),
}


def lines_of(img, dist, yc, cols, rng):
    """the heights (metres) and thicknesses (metres) of the dark rows in a wall's picture"""
    h, w = img.shape[:2]
    scale = (h / 2) / (dist * math.tan(FOV / 2))
    c0, c1 = int(w / 2 + cols[0] * scale), int(w / 2 + cols[1] * scale)
    lum = img[:, c0:c1].mean(axis=(1, 2))
    r0 = max(int(h / 2 - (rng[1] - yc) * scale), 0)
    r1 = min(int(h / 2 - (rng[0] - yc) * scale), h)
    # the wall around a row: the median of the rows a storey's third away each way (a line is a few rows thick, a third of a storey is not)
    reach = max(int(STOREY / 3 * scale), 4)
    base = np.array([np.median(lum[max(i - reach, 0):i + reach + 1]) for i in range(h)])
    dark = (base - lum) > 3.0
    out, i = [], r0
    while i < r1:
        if not dark[i]:
            i += 1
            continue
        j = i
        while j < r1 and dark[j]:
            j += 1
        rows = np.arange(i, j)
        wgt = (base - lum)[i:j]
        centre = float((rows * wgt).sum() / wgt.sum()) + 0.5
        out.append((yc + (h / 2 - centre) / scale, (j - i) / scale))
        i = j
    return sorted(out)


def expected(rng, floors):
    ks = [k for k in range(1, floors + 1) if rng[0] <= k * STOREY <= rng[1]]
    return [k * STOREY for k in ks]


found = {}
for scene in ("storeys", "storeys_cpu", "storeys_off"):
    for name, (dist, yc, cols, rng, floors) in SHOTS.items():
        found[(scene, name)] = lines_of(load(scene, name), dist, yc, cols, rng)

for name, (dist, yc, cols, rng, floors) in SHOTS.items():
    got = found[("storeys", name)]
    want = expected(rng, floors)
    scale = (load("storeys", name).shape[0] / 2) / (dist * math.tan(FOV / 2))
    tol = max(1.5 / scale, 0.04)   # a row and a half
    off = [min(abs(y - w) for w in want) for y, _ in got] if want else []
    check(f"lines {name}: a line at each of the {len(want)} multiples of {STOREY} m in {rng[0]} .. {rng[1]} m, and no other",
          len(got) == len(want) and all(abs(y - w) <= tol for (y, _), w in zip(got, want)),
          f"{len(got)} found at {[round(y, 2) for y, _ in got][:6]}{'...' if len(got) > 6 else ''}, wanted {[round(w, 2) for w in want][:6]}{'...' if len(want) > 6 else ''}, worst {max(off, default=0):.3f} m off (tolerance {tol:.3f})")
    thick = [t for _, t in got]
    check(f"spacing {name}: every line 0.06 .. 0.30 m thick", bool(thick) and all(0.06 <= t <= 0.30 for t in thick),
          f"thickness {min(thick, default=0):.3f} .. {max(thick, default=0):.3f} m")
    ctl = found[("storeys_off", name)]
    check(f"control {name}: with no storey set the same picture holds no line", len(ctl) == 0, f"{len(ctl)} dark rows ({[round(y, 2) for y, _ in ctl][:4]})")
    cpu = found[("storeys_cpu", name)]
    check(f"cpu {name}: the CPU path draws the same rows as the GPU path", len(cpu) == len(got) and all(abs(a[0] - b[0]) <= 1.0 / scale for a, b in zip(got, cpu)),
          f"{len(cpu)} lines against {len(got)}")

on, off = load("storeys", "roofs"), load("storeys_off", "roofs")
diff = np.abs(on - off).max(axis=2)
# the gable's two slopes fill the middle of the picture (rows 435 .. 650, columns 790 .. 1130 of a 1920 x 1080 shot, scaled with the picture)
h, w = diff.shape
roof = diff[int(h * 0.403):int(h * 0.602), int(w * 0.411):int(w * 0.589)]
walls = diff[:, :int(w * 0.25)]
check("roofs: seen from straight above, the gable's roof is the same picture with lines or without (nothing that looks up has a line)", float(roof.max()) <= 2.0 and roof.size > 10000,
      f"largest difference over the roof {float(roof.max()):.1f} of 255 ({roof.size} pixels); the walls beside it do differ by {float(walls.max()):.0f}, so a line would show")
check("roofs: the picture can tell: the neighbouring wall's lines differ from the control", float(walls.max()) > 15.0, f"{float(walls.max()):.0f} of 255")

sys.exit(1 if failed else 0)
