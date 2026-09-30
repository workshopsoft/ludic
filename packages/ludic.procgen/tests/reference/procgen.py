#!/usr/bin/env python3
"""A second implementation of ludic.procgen's algorithms, from the README alone (no Ludic code read).

    python3 tests/reference/procgen.py tests/procgen_golden.json

reads every case's INPUT from the golden file, runs the algorithm here, and compares the OUTPUT number
for number. It exits 0 when the two implementations agree. This is the shape a studio's preview takes:
the same integer arithmetic, the same order of draws.

All ludic ints are signed 32-bit and wrap; here they are kept as unsigned 32-bit inside the stream and
converted at the edges. Nothing here is floating point.
"""
import json
import sys

M = 0xFFFFFFFF
GOLDEN = 0x9E3779B9      # -1640531527
C1 = 0x85EBCA6B          # -2048144789
C2 = 0xC2B2AE35          # -1028477387
FNV = 16777619


def s32(x):
    x &= M
    return x - (1 << 32) if x & 0x80000000 else x


def mix(z):
    z &= M
    z ^= z >> 16
    z = (z * C1) & M
    z ^= z >> 13
    z = (z * C2) & M
    z ^= z >> 16
    return z


def hash2(a, b):
    return s32(mix((a & M) * FNV + mix((b & M) + GOLDEN)))


class Rng:
    def __init__(self, seed):
        self.s = seed & M

    def next(self):
        self.s = (self.s + GOLDEN) & M
        return mix(self.s) & 0x7FFFFFFF

    def below(self, n):
        if n <= 1:
            return 0
        return self.next() % n

    def between(self, lo, hi):
        return lo + self.below(hi - lo + 1)


# ---- dungeon -------------------------------------------------------------------------------------------

def dungeon(p, seed):
    W, H = p["width"], p["height"]
    rng = Rng(seed)
    cells = [0] * (W * H)
    rooms = []
    for _ in range(p["attempts"]):
        if len(rooms) >= p["rooms"]:
            break
        w = rng.between(p["room_min"], p["room_max"])
        h = rng.between(p["room_min"], p["room_max"])
        x = rng.between(1, W - w - 1)
        y = rng.between(1, H - h - 1)
        if x + w > W - 1 or y + h > H - 1:
            continue
        pad = p["pad"]
        if any(x < rx + rw + pad and rx < x + w + pad and y < ry + rh + pad and ry < y + h + pad
               for rx, ry, rw, rh in rooms):
            continue
        rooms.append((x, y, w, h))
    for x, y, w, h in rooms:
        for j in range(y, y + h):
            for i in range(x, x + w):
                cells[j * W + i] = 1
    n = len(rooms)
    centre = [(x + w // 2, y + h // 2) for x, y, w, h in rooms]

    def carve(i, j):
        ax, ay = centre[i]
        bx, by = centre[j]
        horizontal_first = rng.below(2) == 1
        path = []
        if horizontal_first:
            path += [(x, ay) for x in rng_range(ax, bx)]
            path += [(bx, y) for y in rng_range(ay, by)]
        else:
            path += [(ax, y) for y in rng_range(ay, by)]
            path += [(x, by) for x in rng_range(ax, bx)]
        for x, y in path:
            if cells[y * W + x] == 0:
                cells[y * W + x] = 2

    def rng_range(a, b):
        step = 1 if b >= a else -1
        return range(a, b + step, step)

    if n >= 2:
        in_tree = [False] * n
        in_tree[0] = True
        for _ in range(n - 1):
            best = None
            for i in range(n):
                if not in_tree[i]:
                    continue
                for j in range(n):
                    if in_tree[j]:
                        continue
                    d = abs(centre[i][0] - centre[j][0]) + abs(centre[i][1] - centre[j][1])
                    if best is None or d < best[0]:
                        best = (d, i, j)
            carve(best[1], best[2])
            in_tree[best[2]] = True
        for _ in range(p["loops"]):
            a = rng.below(n)
            b = rng.below(n)
            if a != b:
                carve(a, b)
    exit_room = 0
    if n >= 1:
        bestd = -1
        for i in range(n):
            d = abs(centre[i][0] - centre[0][0]) + abs(centre[i][1] - centre[0][1])
            if d > bestd:
                bestd = d
                exit_room = i
    return {"rooms": [list(r) for r in rooms], "start": 0, "exit": exit_room,
            "grid": ["".join(str(cells[j * W + i]) for i in range(W)) for j in range(H)]}


# ---- wave function collapse over sockets ---------------------------------------------------------------

DIRS = [(1, 0), (0, 1), (-1, 0), (0, -1)]       # east, south, west, north


def popcount(m):
    n = 0
    while m:
        n += m & 1
        m >>= 1
    return n


def wfc(c, seed):
    tiles = c["tiles"]
    nt = len(tiles)
    W, H = c["width"], c["height"]
    full = (1 << nt) - 1
    # compat[d][t]: the tiles that may lie next to t in direction d
    sock = [("e", "w"), ("s", "n"), ("w", "e"), ("n", "s")]
    compat = [[0] * nt for _ in range(4)]
    for d, (mine, theirs) in enumerate(sock):
        for t in range(nt):
            for u in range(nt):
                if tiles[t][mine] == tiles[u][theirs]:
                    compat[d][t] |= 1 << u
    for attempt in range(c["tries"]):
        rng = Rng(hash2(seed, attempt))
        mask = [full] * (W * H)
        stack = []
        bad = False

        def propagate():
            while stack:
                ci = stack.pop()
                cx, cy = ci % W, ci // W
                for d, (dx, dy) in enumerate(DIRS):
                    nx, ny = cx + dx, cy + dy
                    if nx < 0 or ny < 0 or nx >= W or ny >= H:
                        continue
                    allowed = 0
                    m = mask[ci]
                    for t in range(nt):
                        if m >> t & 1:
                            allowed |= compat[d][t]
                    ni = ny * W + nx
                    new = mask[ni] & allowed
                    if new == 0:
                        return False
                    if new != mask[ni]:
                        mask[ni] = new
                        stack.append(ni)
            return True

        if c["border"] >= 0:
            for y in range(H):
                for x in range(W):
                    if x == 0 or y == 0 or x == W - 1 or y == H - 1:
                        mask[y * W + x] &= 1 << c["border"]
                        if mask[y * W + x] == 0:
                            bad = True
                        stack.append(y * W + x)
        if not bad:
            stack.extend(range(W * H))          # every cell once, row by row
            if not propagate():
                bad = True
        if bad:
            continue
        while True:
            bestn = 0
            ties = []
            for i in range(W * H):
                k = popcount(mask[i])
                if k <= 1:
                    continue
                if bestn == 0 or k < bestn:
                    bestn = k
                    ties = [i]
                elif k == bestn:
                    ties.append(i)
            if not ties:
                break
            cell = ties[rng.below(len(ties))]
            total = sum(tiles[t]["weight"] for t in range(nt) if mask[cell] >> t & 1)
            r = rng.below(total)
            pick = -1
            acc = 0
            for t in range(nt):
                if mask[cell] >> t & 1:
                    acc += tiles[t]["weight"]
                    if acc > r:
                        pick = t
                        break
            mask[cell] = 1 << pick
            stack.append(cell)
            if not propagate():
                bad = True
                break
        if bad:
            continue
        rows = []
        for y in range(H):
            rows.append([mask[y * W + x].bit_length() - 1 for x in range(W)])
        return {"attempt": attempt, "grid": rows}
    return {"attempt": -1, "grid": [[-1] * W for _ in range(H)]}


# ---- scatter -------------------------------------------------------------------------------------------

def inside(reg, x, y):
    if reg["shape"] == "disc":
        dx, dy = x - reg["x"], y - reg["y"]
        return dx * dx + dy * dy <= reg["w"] * reg["w"]
    return reg["x"] <= x < reg["x"] + reg["w"] and reg["y"] <= y < reg["y"] + reg["h"]


def sample(reg, rng):
    if reg["shape"] == "disc":
        r = reg["w"]
        return reg["x"] - r + rng.below(2 * r + 1), reg["y"] - r + rng.below(2 * r + 1)
    return reg["x"] + rng.below(reg["w"]), reg["y"] + rng.below(reg["h"])


def scatter(c, seed):
    rng = Rng(seed)
    kinds = c["kinds"]
    total = sum(k["weight"] for k in kinds)
    pts = []
    md2 = c["min_dist"] * c["min_dist"]
    for ri, reg in enumerate(c["regions"]):
        for _ in range(reg["count"]):
            for _attempt in range(c["attempts"]):
                x, y = sample(reg, rng)
                if not inside(reg, x, y):
                    continue
                if any(inside(a, x, y) for a in c["avoid"]):
                    continue
                if md2 > 0 and any((px - x) ** 2 + (py - y) ** 2 < md2 for px, py, *_ in pts):
                    continue
                kind = 0
                if total > 0:
                    r = rng.below(total)
                    acc = 0
                    for ki, k in enumerate(kinds):
                        acc += k["weight"]
                        if acc > r:
                            kind = ki
                            break
                angle = rng.below(360)
                lo, hi = (kinds[kind]["scale_lo"], kinds[kind]["scale_hi"]) if kinds else (1000, 1000)
                scale = rng.between(lo, hi)
                pts.append([x, y, kind, angle, scale, ri])
                break
    return {"points": pts}


# ---- the golden ----------------------------------------------------------------------------------------

def check(golden):
    bad = 0
    for v in golden["rng"]:
        r = Rng(v["seed"])
        got = [r.next() for _ in range(len(v["next"]))]
        if got != v["next"]:
            print("rng", v["seed"], got, v["next"])
            bad += 1
        r = Rng(v["seed"])
        got = [r.below(n) for n in v["below_n"]]
        if got != v["below"]:
            print("below", v["seed"], got, v["below"])
            bad += 1
    for a, b, want in golden["derive"]:
        if hash2(a, b) != want:
            print("derive", a, b, hash2(a, b), want)
            bad += 1
    for k in ("dungeon", "wfc", "scatter"):
        fn = {"dungeon": dungeon, "wfc": wfc, "scatter": scatter}[k]
        for case in golden[k]:
            got = fn(case["input"], case["seed"])
            if got != case["output"]:
                print(k, case.get("name"), "DIFFERS")
                bad += 1
    return bad


if __name__ == "__main__":
    g = json.load(open(sys.argv[1]))
    n = check(g)
    print("ok: every case agrees" if n == 0 else f"{n} cases differ")
    sys.exit(1 if n else 0)
