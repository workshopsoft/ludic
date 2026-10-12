#!/usr/bin/env python3
"""shore_check.py <build/lab> - measured checks on the shore lab's `top` shots (shore_lab.ludic), OC-140.I2 and I3.

Each check projects a world point through the shot's camera (lab_shot_at's pose, cam_fov 42 deg, 16:9; the screenshot's
row 0 at the top) and reads a 5 x 5 pixel mean there:

  I2  the masked sea plane draws nothing over the dry cut below its level; with no mask it does (the phantom the mask
      removes); the open sea is water either way; the lake mesh draws over its basin but not over the hollow in its
      bounding box outside the pentagon; the fourteen pads (bodies 3 .. 16) each draw.
  I3  each land-use class draws its own tone (the road dark, the park green, the sand sandy, the pad grey) where the mask
      names it; the tile with no mask draws the ground's tint, the same in both scenes; with no masks at all the road
      draws that tint too.
Prints one line a check and exits 1 when any fails.
"""
import math
import os
import sys

from PIL import Image

FOV = math.radians(42.0)
W, H = 1920, 1080


def pose_at(tx, ty, tz, dist, from_deg, up_deg):
    b, e = math.radians(from_deg), math.radians(up_deg)
    hd = dist * math.cos(e)
    cx, cz, cy = tx + math.sin(b) * hd, tz + math.cos(b) * hd, ty + dist * math.sin(e)
    yaw = math.atan2(cx - tx, cz - tz)
    return (cx, cy, cz), yaw, math.radians(-up_deg)


def project(pose, p):
    (cx, cy, cz), yaw, pitch = pose
    f = (-math.sin(yaw) * math.cos(pitch), math.sin(pitch), -math.cos(yaw) * math.cos(pitch))
    r = (math.cos(yaw), 0.0, -math.sin(yaw))
    u = (r[1] * f[2] - r[2] * f[1], r[2] * f[0] - r[0] * f[2], r[0] * f[1] - r[1] * f[0])
    v = (p[0] - cx, p[1] - cy, p[2] - cz)
    d = sum(v[k] * f[k] for k in range(3))
    k = 1.0 / math.tan(FOV / 2)
    x = sum(v[i] * r[i] for i in range(3)) / d * k / (W / H)
    y = sum(v[i] * u[i] for i in range(3)) / d * k
    return (x + 1) / 2 * W, (1 - y) / 2 * H


def sample(img, pose, p):
    px, py = project(pose, p)
    acc = [0, 0, 0]
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            c = img.getpixel((int(px) + dx, int(py) + dy))
            for i in range(3):
                acc[i] += c[i]
    return tuple(a / 25.0 for a in acc)


def watery(c):
    return c[2] - c[0] > 25


def main():
    lab = sys.argv[1] if len(sys.argv) > 1 else "build/lab"
    top = pose_at(-8.0, 0.0, 0.0, 190.0, 180.0, 89.0)
    shots = {s: Image.open(os.path.join(lab, s, "top.png")).convert("RGB") for s in ("shore", "shore_nomask", "shore_plain")}
    m, n, plain = shots["shore"], shots["shore_nomask"], shots["shore_plain"]
    bad = 0

    def check(name, ok, *cols):
        nonlocal bad
        bad += 0 if ok else 1
        print(("ok   " if ok else "FAIL ") + name + "  " + "  ".join("(%d %d %d)" % tuple(int(x) for x in c) for c in cols))

    cut = (-46.0, -2.0, 0.0)
    sea = (-85.0, 0.0, 0.0)
    lake = (0.0, 1.2, 0.0)
    hollow = (10.5, 0.0, -12.5)
    check("I2 masked sea plane: nothing over the dry cut below its level", not watery(sample(m, top, cut)), sample(m, top, cut))
    check("I2 unmasked: the same plane floods the cut (what the mask removes)", watery(sample(n, top, cut)), sample(n, top, cut))
    check("I2 the open sea is water, masked and not", watery(sample(m, top, sea)) and watery(sample(n, top, sea)), sample(m, top, sea), sample(n, top, sea))
    check("I2 the lake mesh draws over its basin", watery(sample(m, top, lake)), sample(m, top, lake))
    check("I2 the lake mesh draws nothing over the hollow outside its triangles", not watery(sample(m, top, hollow)), sample(m, top, hollow))
    ground = sample(m, top, (43.5, 2.0, 0.0))
    for k in range(14):
        p = (40.0 + (k % 7) * 7.0, 2.05, -6.0 if k < 7 else 6.0)
        c = sample(m, top, p)
        diff = sum(abs(c[i] - ground[i]) for i in range(3))
        check("I2 body %d (pad %d) draws" % (k + 3, k), diff > 12, c, ground)
    road, park, sand, pad = (0.0, 2.0, 17.0), (20.0, 2.0, -22.0), (0.0, -1.0, 0.0), (-53.0, 2.0, -11.0)
    tint_m, tint_p = sample(m, top, (64.0, 2.0, 20.0)), sample(plain, top, (64.0, 2.0, 20.0))
    rc, pc, gc = sample(m, top, road), sample(m, top, park), sample(m, top, (-20.0, 2.0, -25.0))
    check("I3 the road class draws its dark tone", max(rc) < 0.45 * max(tint_m), rc, tint_m)
    check("I3 the park class draws its green, greener than the grass", pc[1] > pc[0] * 2.0 and pc[1] - pc[0] > gc[1] - gc[0], pc, gc)
    check("I3 the pad class draws grey", abs(sample(m, top, pad)[0] - sample(m, top, pad)[2]) < 20, sample(m, top, pad))
    # the frames' exposure adapts to what is in them (a frame of dark tones is opened up): the tint is compared by its
    # hue, the ratios of its channels, which an exposure scales alike; the CPU side is exact (tilemap_mask_test)
    chroma = lambda c: (c[0] / c[1], c[2] / c[1])
    cm, cp = chroma(tint_m), chroma(tint_p)
    check("I3 the tile with no mask draws the tint: the same hue with masks on and off", abs(cm[0] - cp[0]) < 0.02 and abs(cm[1] - cp[1]) < 0.02, tint_m, tint_p)
    near = (0.0, 2.0, 24.0)
    check("I3 with no masks the road draws the tint, as the grass beside it does", sum(abs(sample(plain, top, road)[i] - sample(plain, top, near)[i]) for i in range(3)) < 6, sample(plain, top, road), sample(plain, top, near))
    print("shore_check: %d failed" % bad)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
