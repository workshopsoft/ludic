#!/usr/bin/env python3
# check.py DIR - prints `OK <glyphs>` when DIR's font.json and font.png hold together: the metrics are
# there for the characters a game localises into ('A' advances; Turkish ş İ ğ; Romanian ș; Greek Ω;
# Cyrillic б; €), the atlas has a cell for every glyph, and the PNG's chunks check out and inflate to
# the size its header gives. Run by `ludic-dev test-fonts`.
import json, struct, sys, zlib
d = sys.argv[1]
j = json.load(open(d + "/font.json"))
c, a = j["codes"], j["adv"]
assert len(c) == len(a) and c == sorted(set(c)), "codes and adv disagree, or codes are not ascending"
assert j["cols"] * j["rows"] >= len(c) and j["cell"] >= j["em"], "cells"
for cp in (32, 63, 65, 0x15F, 0x130, 0x11F, 0x219, 0x3A9, 0x431, 0x20AC):
    assert cp in c, "missing " + hex(cp)
assert a[c.index(65)] > 0.3 and a[c.index(32)] > 0, "advances"
assert 0 < j["pad_x"] < 1 and 0 < j["base_y"] < 1
p = open(d + "/font.png", "rb").read()
assert p[:8] == b"\x89PNG\r\n\x1a\n", "not a PNG"
i, z, w, h = 8, b"", 0, 0
while i < len(p):
    n, = struct.unpack(">I", p[i:i + 4]); t = p[i + 4:i + 8]; b = p[i + 8:i + 8 + n]
    assert zlib.crc32(t + b) & 0xffffffff == struct.unpack(">I", p[i + 8 + n:i + 12 + n])[0], "crc of " + str(t)
    if t == b"IHDR":
        w, h, bd, ct = struct.unpack(">IIBB", b[:10]); assert (bd, ct) == (8, 6), "RGBA8"
    if t == b"IDAT": z += b
    i += 12 + n
assert w == j["cols"] * j["cell"] and h == j["rows"] * j["cell"], "atlas size"
assert len(zlib.decompress(z)) == (w * 4 + 1) * h, "inflated size"
print("OK", len(c))
