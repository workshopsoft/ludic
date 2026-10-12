#!/usr/bin/env python3
"""make_boxkits.py - the `boxkits` fixture: unit kits whose vertices carry anchors (kitbox.ludic), deterministic.

kits.glb, three nodes, each one primitive with POSITION and NORMAL (flat faces), and for the box kits _ANCHOR (VEC4: sx, sz,
sh, sd) and _OFFSET (VEC3: ox, oy, oz). POSITION is the kit drawn at the reference instance w 20, d 10, h 10.

  flat    a body (walls from the ground to the parapet's top) with a parapet 1.0 m high and 0.25 m thick round a roof deck
          at the eave: the parapet's top is (sh 1, oy 1.0), its inner faces are inset (ox / oz -+0.25)
  gable   a body to the eave and a 30 degree gable roof, the ridge along x (the long side, w) at the middle of the depth:
          the ridge is (sz 0, sh 1, sd tan(30) / 2), so it rises d / 2 x tan 30 over the eave at any depth
  door    an ordinary mesh, 1.0 m wide, 2.2 m tall, 0.1 m deep, origin at the middle of its foot: no anchors

Run from anywhere: python3 make_boxkits.py  (writes beside itself).
"""
import json
import math
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
W, D, H = 20.0, 10.0, 10.0
T30 = math.tan(math.radians(30.0))


def at(a):
    """a vertex as anchors (sx, sz, sh, sd, ox, oy, oz) -> its position at the reference instance"""
    sx, sz, sh, sd, ox, oy, oz = a
    return (sx * W + ox, sh * H + sd * D + oy, sz * D + oz)


def V(sx=0.0, sz=0.0, sh=0.0, sd=0.0, ox=0.0, oy=0.0, oz=0.0):
    return (sx, sz, sh, sd, ox, oy, oz)


class Mesh:
    def __init__(self):
        self.pos, self.nrm, self.anc, self.off, self.idx = [], [], [], [], []

    def face(self, vs, want):
        """a convex polygon (anchor tuples or plain positions), its front toward the direction `want` (x, y, z)"""
        ps = [at(v) if len(v) == 7 else v for v in vs]
        ax, ay, az = (ps[1][k] - ps[0][k] for k in range(3))
        bx, by, bz = (ps[2][k] - ps[0][k] for k in range(3))
        n = (ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx)
        if n[0] * want[0] + n[1] * want[1] + n[2] * want[2] < 0:
            vs, ps = vs[::-1], ps[::-1]
            n = (-n[0], -n[1], -n[2])
        l = math.sqrt(sum(c * c for c in n))
        n = tuple(c / l for c in n)
        base = len(self.pos)
        for v, p in zip(vs, ps):
            self.pos.append(p)
            self.nrm.append(n)
            if len(v) == 7:
                self.anc.append(v[0:4])
                self.off.append(v[4:7])
        for k in range(1, len(vs) - 1):
            self.idx += [base, base + k, base + k + 1]


def flat():
    m = Mesh()
    P = 0.25
    # outer walls, ground to the parapet's top
    for s, axis in ((0.5, "x"), (-0.5, "x"), (0.5, "z"), (-0.5, "z")):
        if axis == "x":
            c = [V(sx=s, sz=-0.5), V(sx=s, sz=0.5), V(sx=s, sz=0.5, sh=1, oy=1.0), V(sx=s, sz=-0.5, sh=1, oy=1.0)]
            m.face(c, (s, 0, 0))
        else:
            c = [V(sx=-0.5, sz=s), V(sx=0.5, sz=s), V(sx=0.5, sz=s, sh=1, oy=1.0), V(sx=-0.5, sz=s, sh=1, oy=1.0)]
            m.face(c, (0, 0, s))
    # the deck at the eave, inside the parapet
    m.face([V(sx=-0.5, sz=-0.5, sh=1, ox=P, oz=P), V(sx=0.5, sz=-0.5, sh=1, ox=-P, oz=P), V(sx=0.5, sz=0.5, sh=1, ox=-P, oz=-P), V(sx=-0.5, sz=0.5, sh=1, ox=P, oz=-P)], (0, 1, 0))
    # the parapet's inner faces, deck to top, facing in
    for s in (0.5, -0.5):
        i = -P if s > 0 else P
        m.face([V(sx=s, sz=-0.5, sh=1, ox=i, oz=P), V(sx=s, sz=0.5, sh=1, ox=i, oz=-P), V(sx=s, sz=0.5, sh=1, ox=i, oz=-P, oy=1.0), V(sx=s, sz=-0.5, sh=1, ox=i, oz=P, oy=1.0)], (-s, 0, 0))
        m.face([V(sz=s, sx=-0.5, sh=1, oz=i, ox=P), V(sz=s, sx=0.5, sh=1, oz=i, ox=-P), V(sz=s, sx=0.5, sh=1, oz=i, ox=-P, oy=1.0), V(sz=s, sx=-0.5, sh=1, oz=i, ox=P, oy=1.0)], (0, 0, -s))
    # the parapet's top: four strips
    for s in (0.5, -0.5):
        i = -P if s > 0 else P
        m.face([V(sx=s, sz=-0.5, sh=1, oy=1.0), V(sx=s, sz=0.5, sh=1, oy=1.0), V(sx=s, sz=0.5, sh=1, oy=1.0, ox=i, oz=-P), V(sx=s, sz=-0.5, sh=1, oy=1.0, ox=i, oz=P)], (0, 1, 0))
        m.face([V(sz=s, sx=-0.5, sh=1, oy=1.0), V(sz=s, sx=0.5, sh=1, oy=1.0), V(sz=s, sx=0.5, sh=1, oy=1.0, oz=i, ox=-P), V(sz=s, sx=-0.5, sh=1, oy=1.0, oz=i, ox=P)], (0, 1, 0))
    return m


def gable():
    m = Mesh()
    R = T30 / 2.0
    for s in (0.5, -0.5):
        # the long walls, ground to eave
        m.face([V(sx=-0.5, sz=s), V(sx=0.5, sz=s), V(sx=0.5, sz=s, sh=1), V(sx=-0.5, sz=s, sh=1)], (0, 0, s))
        # the gable ends, a pentagon to the ridge
        m.face([V(sx=s, sz=-0.5), V(sx=s, sz=0.5), V(sx=s, sz=0.5, sh=1), V(sx=s, sh=1, sd=R), V(sx=s, sz=-0.5, sh=1)], (s, 0, 0))
        # the roof's two slopes, eave to ridge
        m.face([V(sx=-0.5, sz=s, sh=1), V(sx=0.5, sz=s, sh=1), V(sx=0.5, sh=1, sd=R), V(sx=-0.5, sh=1, sd=R)], (0, 1, s))
    return m


def door():
    m = Mesh()
    w, h, d = 0.5, 2.2, 0.05
    corners = lambda xs, ys, zs: [(x, y, z) for x, y, z in zip(xs, ys, zs)]
    m.face([(-w, 0, d), (w, 0, d), (w, h, d), (-w, h, d)], (0, 0, 1))
    m.face([(-w, 0, -d), (w, 0, -d), (w, h, -d), (-w, h, -d)], (0, 0, -1))
    m.face([(w, 0, -d), (w, 0, d), (w, h, d), (w, h, -d)], (1, 0, 0))
    m.face([(-w, 0, -d), (-w, 0, d), (-w, h, d), (-w, h, -d)], (-1, 0, 0))
    m.face([(-w, h, -d), (w, h, -d), (w, h, d), (-w, h, d)], (0, 1, 0))
    return m


def glb(path, meshes):
    blob = b""
    views, accs, gl_meshes, nodes = [], [], [], []

    def add(data, fmt, count, ty, target, minmax=False, ctype=5126):
        nonlocal blob
        b = b"".join(struct.pack(fmt, *(v if isinstance(v, tuple) else (v,))) for v in data)
        views.append({"buffer": 0, "byteOffset": len(blob), "byteLength": len(b), "target": target})
        blob += b
        a = {"bufferView": len(views) - 1, "componentType": ctype, "count": count, "type": ty}
        if minmax:
            a["min"] = [min(v[k] for v in data) for k in range(3)]
            a["max"] = [max(v[k] for v in data) for k in range(3)]
        accs.append(a)
        return len(accs) - 1

    for name, m in meshes:
        attrs = {"POSITION": add(m.pos, "<3f", len(m.pos), "VEC3", 34962, True), "NORMAL": add(m.nrm, "<3f", len(m.nrm), "VEC3", 34962)}
        if m.anc:
            attrs["_ANCHOR"] = add(m.anc, "<4f", len(m.anc), "VEC4", 34962)
            attrs["_OFFSET"] = add(m.off, "<3f", len(m.off), "VEC3", 34962)
        ix = add(m.idx, "<I", len(m.idx), "SCALAR", 34963, ctype=5125)
        gl_meshes.append({"primitives": [{"attributes": attrs, "indices": ix}]})
        nodes.append({"name": name, "mesh": len(gl_meshes) - 1})
    doc = {"asset": {"version": "2.0", "generator": "make_boxkits.py"}, "scene": 0, "scenes": [{"nodes": list(range(len(nodes)))}],
           "nodes": nodes, "meshes": gl_meshes, "accessors": accs, "bufferViews": views, "buffers": [{"byteLength": len(blob)}]}
    js = json.dumps(doc, separators=(",", ":"), sort_keys=True).encode()
    js += b" " * ((4 - len(js) % 4) % 4)
    blob += b"\0" * ((4 - len(blob) % 4) % 4)
    out = struct.pack("<III", 0x46546C67, 2, 12 + 8 + len(js) + 8 + len(blob))
    out += struct.pack("<II", len(js), 0x4E4F534A) + js + struct.pack("<II", len(blob), 0x004E4942) + blob
    with open(path, "wb") as f:
        f.write(out)


if __name__ == "__main__":
    ms = [("flat", flat()), ("gable", gable()), ("door", door())]
    glb(os.path.join(HERE, "kits.glb"), ms)
    print("boxkits:", ", ".join(f"{n} {len(m.pos)} vertices" for n, m in ms))
