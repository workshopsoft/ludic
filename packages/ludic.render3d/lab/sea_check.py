#!/usr/bin/env python3
"""sea_check.py <build/lab> - measured checks on the sea lab's shots (sea_lab.ludic): the shore foam, nothing on dry texels,
the horizon, no flicker, the river mouth.

Each check projects a world point through the shot's camera (lab_shot_at's pose, cam_fov 42 deg, 16:9; the screenshot's
row 0 at the top) and reads pixels there. The ground truth is the fixture's own height function (tests/maps/sea/make_sea.py).

  foam      (top_beach, noon and dusk) along the 4 % beach, by the depth of the water over the bed: foam (texture) where the
            water is under a metre deep, the swash zone strongest, and none at or past a metre; the old still-water plane is
            the control (no foam band).
  dry       (top_beach, top_platform: `sea` against `sea_none`, the same ground with no water) the dry platform in the sea,
            the dry dock and the land draw exactly what they do with no water: no water, no foam, off the border of a tile
            as well as on it (the platform's north edge is the tile border z = -64).
  horizon   (horizon, horizon_corner) the sea runs to the horizon: darker than the sky just under it, and no step in the rows
            below the horizon line (no edge of the surface, no gap of sky).
  flicker   (flick_a, flick_b: the same view a frame apart) what moved between two frames is small, and no more than the old
            still-water plane's.
  mouth     (top_mouth) where a river mesh and the sea plane share a height the mesh draws every pixel: the overlap has the
            river's colour and its smoothness.
Prints one line a check and exits 1 when any fails.
"""
import importlib.util
import math
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("make_sea", os.path.join(HERE, "..", "tests", "maps", "sea", "make_sea.py"))
make_sea = importlib.util.module_from_spec(spec)
sys.path.insert(0, os.path.join(HERE, "..", "tests", "maps", "shore"))
spec.loader.exec_module(make_sea)

FOV = math.radians(42.0)
W, H = 1920, 1080
FAILED = []


def pose_at(tx, ty, tz, dist, from_deg, up_deg):
    b, e = math.radians(from_deg), math.radians(up_deg)
    hd = dist * math.cos(e)
    cx, cz, cy = tx + math.sin(b) * hd, tz + math.cos(b) * hd, ty + dist * math.sin(e)
    return (cx, cy, cz), math.atan2(cx - tx, cz - tz), math.radians(-up_deg)


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


def load(lab, scene, shot):
    return np.asarray(Image.open(os.path.join(lab, scene, shot + ".png")).convert("RGB")).astype(float)


def px(img, pose, p):
    x, y = project(pose, p)
    xi, yi = int(round(x)), int(round(y))
    if not (0 <= xi < W and 0 <= yi < H):
        return None
    return img[yi, xi]


def lum(c):
    return 0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2]


def report(ok, name, detail=""):
    print(("ok   " if ok else "FAIL ") + name + ("  " + detail if detail else ""))
    if not ok:
        FAILED.append(name)


def foam_stats(lab, scene):
    """by the depth of the water over the bed along the beach: the high-pass energy of the picture (foam is texture: lace and
    bubbles; water and shallows over sand are smooth) and the share of pale pixels"""
    im = Image.open(os.path.join(lab, scene, "top_beach.png")).convert("L")
    a = np.asarray(im).astype(float)
    hp = np.abs(a - np.asarray(im.filter(ImageFilter.BoxBlur(5))).astype(float))
    rgb = load(lab, scene, "top_beach")
    pose = pose_at(-60.0, 0.0, -78.0, 90.0, 0.0, 89.0)
    energy = {"<0.5": [], "0.5-1": [], ">=1.03": [], "deep": []}
    lums = []
    pale = []
    for z in np.arange(-110.0, -70.0, 1.0):
        for u in np.arange(-44.0, 1.0, 0.25):
            x = make_sea.coast(z) + u
            depth = -make_sea.height(x, z)
            if depth < 0.0:
                continue
            X, Y = project(pose, (x, 0.0, z))
            xi, yi = int(round(X)), int(round(Y))
            if not (0 <= xi < W and 0 <= yi < H):
                continue
            if depth >= 1.2:
                energy["deep"].append(hp[yi, xi])
                lums.append(lum(rgb[yi, xi]))
            if depth >= 1.03:
                energy[">=1.03"].append(hp[yi, xi])
            key = "<0.5" if depth < 0.5 else ("0.5-1" if depth < 1.0 else None)
            if key:
                energy[key].append(hp[yi, xi])
            if depth >= 1.03:
                pale.append((rgb[yi, xi], depth))
    ref = float(np.median(lums))
    return {k: float(np.mean(v)) for k, v in energy.items()}, ref, pale


def check_foam(lab, scene, label):
    e, ref, pale = foam_stats(lab, scene)
    d = e["deep"]
    report(e["<0.5"] >= 2.5 * d, f"foam {label}: the swash zone (water under 50 cm) is foam: texture 2.5 times the open water's", f"{e['<0.5']:.2f} against {d:.2f}")
    report(e["0.5-1"] >= 1.25 * d, f"foam {label}: lace lies between 50 cm and a metre", f"{e['0.5-1']:.2f} against {d:.2f}")
    report(e[">=1.03"] <= 1.15 * d, f"foam {label}: no texture of foam where the water is a metre deep or more", f"{e['>=1.03']:.2f} against {d:.2f}")
    nfoam = sum(1 for c, depth in pale if lum(c) >= 1.5 * ref and (c.max() - c.min()) / c.max() < 0.32)
    report(nfoam == 0, f"foam {label}: and no pale pixel there (water luminance {ref:.0f})", f"{nfoam} of {len(pale)} samples")


def check_foam_control(lab):
    """the same measure on the old still-water plane: it has a wash, not a foam band, so the check can tell them apart"""
    e, ref, pale = foam_stats(lab, "sea_old")
    report(e["<0.5"] < 2.5 * e["deep"], "foam (the old plane): its shallows are not foam", f"{e['<0.5']:.2f} against {e['deep']:.2f}")


def diff_max(a, b):
    return float(np.max(np.abs(a - b)))


def check_dry(lab):
    # the dry platform in the sea, a tile border on its north edge. The scene's exposure and ambient occlusion shift the
    # frame by a few levels with or without water, so the dry places are compared with a tolerance of that size
    s = load(lab, "sea", "top_platform")
    n = load(lab, "sea_none", "top_platform")
    pose = pose_at(-98.0, 0.0, -58.0, 40.0, 0.0, 89.0)
    worst = 0.0
    count = 0
    for x in np.arange(-105.0, -90.0, 1.0):
        for z in np.arange(-61.0, -54.0, 1.0):
            worst = max(worst, diff_max(px(s, pose, (x, -0.5, z)), px(n, pose, (x, -0.5, z))))
            count += 1
    report(worst <= 14.0, "dry: the platform in the sea draws what it does with no water (no water, no foam on it)", f"{count} points, worst {worst:.1f}")
    # the north edge is the border of tiles (1, 0) and (1, 1): the platform from z = -64 on, the sea before it. Water is
    # blue over red; the sand of the platform is not. Half a metre of the mask's own texel either way would show.
    wrong_out, wrong_in, n_out, n_in = 0, 0, 0, 0
    for x in np.arange(-105.0, -90.0, 0.5):
        for z, y in ((-64.45, 0.0), (-64.6, 0.0), (-64.9, 0.0)):
            c = px(s, pose, (x, y, z))
            wrong_out += 0 if c[2] - c[0] > 5.0 else 1
            n_out += 1
        for z, y in ((-63.55, -0.575), (-63.4, -0.5), (-63.25, -0.5)):
            c = px(s, pose, (x, y, z))
            wrong_in += 1 if c[2] - c[0] > 5.0 else 0
            n_in += 1
    report(wrong_out == 0, "dry: water right up to the tile border outside the platform (no strip of ground showing)", f"{wrong_out} of {n_out} points")
    report(wrong_in == 0, "dry: no water over the border inside the platform's edge", f"{wrong_in} of {n_in} points")
    # the dock below the sea's level and the land, from the beach shot
    s = load(lab, "sea", "top_beach")
    n = load(lab, "sea_none", "top_beach")
    pose = pose_at(-60.0, 0.0, -78.0, 90.0, 0.0, 89.0)
    worst = 0.0
    for x in np.arange(-17.0, -1.0, 1.0):
        for z in np.arange(-97.0, -83.0, 1.0):
            worst = max(worst, diff_max(px(s, pose, (x, -3.0, z)), px(n, pose, (x, -3.0, z))))
    report(worst <= 8.0, "dry: the dock 3 m under the sea's level draws what it does with no water", f"worst {worst:.1f}")
    worst = 0.0
    for z in np.arange(-110.0, -70.0, 4.0):
        for u in np.arange(6.0, 30.0, 2.0):
            x = make_sea.coast(z) + u
            if make_sea.in_dock(x, z):
                continue
            a, b = px(s, pose, (x, make_sea.height(x, z), z)), px(n, pose, (x, make_sea.height(x, z), z))
            if a is not None:
                worst = max(worst, diff_max(a, b))
    report(worst <= 8.0, "dry: the land draws what it does with no water", f"worst {worst:.1f}")


def check_horizon(lab, shot, pitch_deg):
    img = load(lab, "sea", shot)
    rh = int(round(H / 2 + math.tan(math.radians(pitch_deg)) / math.tan(FOV / 2) * H / 2))
    cols = list(range(100, W - 100, 160))
    sky = np.mean([lum(img[rh - 12, c]) for c in cols])
    sea = np.mean([lum(img[rh + 10, c]) for c in cols])
    report(sky - sea >= 12.0, f"horizon {shot}: the sea is darker than the sky just under the horizon line (row {rh})", f"sky {sky:.0f} sea {sea:.0f}")
    steps = []
    for c in cols:
        col = lum(img[rh + 4: rh + 90, c - 4: c + 5].mean(axis=1))
        steps.append(float(np.max(np.abs(np.diff(col)))))
    report(max(steps) <= 10.0, f"horizon {shot}: no step in the rows below the horizon (no edge of the surface)", f"largest {max(steps):.1f}")
    # the light changes across the frame (the sun's side), the surface does not break: the line is smooth to its pixels
    band = lum(img[rh + 4: rh + 8, 100: W - 100].mean(axis=0))
    jump = float(np.max(np.abs(band[8:] - band[:-8])))
    report(jump <= 6.0, f"horizon {shot}: the sea just under the line has no seam across the frame", f"largest change over 8 pixels {jump:.1f}")


def check_flicker(lab):
    """two frames of one view, a sixtieth of a second apart. Every pixel of the renderer moves a little between frames (the
    temporal filter's jitter): the sky and a scene with no water change by about 1.7 levels. What the sea adds is what counts."""
    out = {}
    rows = slice(int(H * 0.55), H)                   # the water below the far shore
    for scene in ("sea", "sea_old", "sea_none"):
        a, b = load(lab, scene, "flick_a"), load(lab, scene, "flick_b")
        d = np.abs(a[rows] - b[rows]).max(axis=2)
        out[scene] = (float(d.mean()), float(np.percentile(d, 99.9)))
    m, p = out["sea"]
    mo, _ = out["sea_old"]
    mn, _ = out["sea_none"]
    report(m - mn <= 0.6, "flicker: the sea adds under 0.6/255 of change between two frames to the frame's own", f"{m:.3f} against {mn:.3f} with no water (the old plane {mo:.3f})")
    report(m <= mo + 0.3, "flicker: and no more than the old still-water plane does", f"{m:.3f} against {mo:.3f}")
    report(p <= 14.0, "flicker: 99.9 % of pixels change by under 14/255", f"{p:.1f}")


def check_mouth(lab):
    img = load(lab, "sea", "top_mouth")
    pose = pose_at(-57.0, 0.0, -45.0, 20.0, 0.0, 89.0)
    zc = 0.5 * (make_sea.RIVER_Z0 + make_sea.RIVER_Z1)
    cs = make_sea.coast(zc)

    def region(x0, x1):
        out = []
        for x in np.arange(x0, x1, 0.15):
            for z in np.arange(zc - 1.6, zc + 1.6, 0.15):
                c = px(img, pose, (x, 0.0, z))
                if c is not None:
                    out.append(c)
        return np.array(out)

    over = region(cs - 10.0, cs - 3.0)               # river and sea plane at one height
    land = region(cs + 8.0, cs + 16.0)               # the river alone
    dm = np.abs(over.mean(axis=0) - land.mean(axis=0)).max()
    so, sl = float(lum(over).std()), float(lum(land).std())
    report(dm <= 12.0, "mouth: where the river meets the sea plane it draws as the river does", f"mean differs by {dm:.1f}")
    report(so <= sl + 3.0, "mouth: and as smoothly (no fight between the two surfaces)", f"std {so:.1f} against {sl:.1f}")


def main():
    lab = sys.argv[1] if len(sys.argv) > 1 else "build/lab"
    check_foam(lab, "sea", "noon")
    check_foam(lab, "sea_dusk", "dusk")
    check_foam_control(lab)
    check_dry(lab)
    check_horizon(lab, "horizon", 0.0)
    check_horizon(lab, "horizon_corner", -1.0)
    check_flicker(lab)
    check_mouth(lab)
    print(f"sea_check: {len(FAILED)} failed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    sys.exit(main())
