#!/usr/bin/env python3
"""plate_build.py - the lab's stage, built here so the package needs no downloads.

Writes packages/ludic.lab/plate/:
  plate.gltf / plate.bin   a flat disc, 40 m across, normals up, uv in metres / 4
  plate_diff.png           a pale grey-green ground with a line every metre, a heavier one every 5
  plate_arm.png            AO 1, roughness 0.9, metal 0
  sky.hdr                  a small clear sky (512 x 256 RGBE): blue overhead, pale at the horizon,
                           a dim ground below it, and a sun 40 degrees up - the plate's one fixed hour
Deterministic: the same bytes every run.
"""
import json, math, os, struct, sys
from PIL import Image

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'packages', 'ludic.lab', 'plate')
os.makedirs(OUT, exist_ok=True)

# ---- the disc -------------------------------------------------------------
R, SEG = 20.0, 96
pos, nrm, uv, idx = [], [], [], []
pos += [0.0, 0.0, 0.0]; nrm += [0.0, 1.0, 0.0]; uv += [0.5, 0.5]
for i in range(SEG):
    a = 2.0 * math.pi * i / SEG
    x, z = R * math.cos(a), R * math.sin(a)
    pos += [x, 0.0, z]; nrm += [0.0, 1.0, 0.0]; uv += [x / 4.0, z / 4.0]
uv[0], uv[1] = 0.0, 0.0
for i in range(SEG):
    a, b = 1 + i, 1 + (i + 1) % SEG
    idx += [0, b, a]
pb = struct.pack(f'<{len(pos)}f', *pos)
nb = struct.pack(f'<{len(nrm)}f', *nrm)
ub = struct.pack(f'<{len(uv)}f', *uv)
ib = struct.pack(f'<{len(idx)}I', *idx)
blob = pb + nb + ub + ib
with open(os.path.join(OUT, 'plate.bin'), 'wb') as f:
    f.write(blob)
n = len(pos) // 3
views, off = [], 0
for b in (pb, nb, ub, ib):
    views.append({'buffer': 0, 'byteOffset': off, 'byteLength': len(b)}); off += len(b)
doc = {
    'asset': {'version': '2.0', 'generator': 'ludic tools/lab/plate_build.py'},
    'scene': 0, 'scenes': [{'nodes': [0]}],
    'nodes': [{'name': 'plate', 'mesh': 0}],
    'meshes': [{'name': 'plate', 'primitives': [{'attributes': {'POSITION': 0, 'NORMAL': 1, 'TEXCOORD_0': 2}, 'indices': 3, 'material': 0}]}],
    'materials': [{'name': 'plate', 'pbrMetallicRoughness': {'baseColorTexture': {'index': 0}, 'metallicRoughnessTexture': {'index': 1}}}],
    'textures': [{'source': 0}, {'source': 1}],
    'images': [{'uri': 'plate_diff.png'}, {'uri': 'plate_arm.png'}],
    'buffers': [{'uri': 'plate.bin', 'byteLength': len(blob)}],
    'bufferViews': views,
    'accessors': [
        {'bufferView': 0, 'componentType': 5126, 'count': n, 'type': 'VEC3', 'min': [-R, 0.0, -R], 'max': [R, 0.0, R]},
        {'bufferView': 1, 'componentType': 5126, 'count': n, 'type': 'VEC3'},
        {'bufferView': 2, 'componentType': 5126, 'count': n, 'type': 'VEC2'},
        {'bufferView': 3, 'componentType': 5125, 'count': len(idx), 'type': 'SCALAR'},
    ],
}
with open(os.path.join(OUT, 'plate.gltf'), 'w') as f:
    json.dump(doc, f, indent=1)

# ---- its material: 4 m of ground per tile, a line a metre -----------------
T = 256
im = Image.new('RGB', (T, T), (142, 146, 132))
px = im.load()
for y in range(T):
    for x in range(T):
        heavy = x == 0 or y == 0
        light = x % (T // 4) == 0 or y % (T // 4) == 0
        if heavy:
            px[x, y] = (96, 100, 90)
        elif light:
            px[x, y] = (122, 126, 114)
im.save(os.path.join(OUT, 'plate_diff.png'))
Image.new('RGB', (4, 4), (255, 230, 0)).save(os.path.join(OUT, 'plate_arm.png'))

# ---- the sky: one fixed hour ----------------------------------------------
W, H = 512, 256
SUN_EL, SUN_AZ = math.radians(40.0), math.radians(135.0)
sx, sy, sz = math.cos(SUN_EL) * math.sin(SUN_AZ), math.sin(SUN_EL), math.cos(SUN_EL) * math.cos(SUN_AZ)

def rgbe(r, g, b):
    m = max(r, g, b)
    if m < 1e-32:
        return bytes((0, 0, 0, 0))
    e = math.frexp(m)[1]
    s = 256.0 / (2.0 ** e)
    return bytes((min(255, int(r * s)), min(255, int(g * s)), min(255, int(b * s)), e + 128))

rows = []
for y in range(H):
    th = (y + 0.5) / H * math.pi            # 0 at the zenith
    el = math.pi / 2 - th
    row = bytearray()
    for x in range(W):
        ph = (x + 0.5) / W * 2.0 * math.pi
        dx, dy, dz = math.sin(th) * math.sin(ph), math.cos(th), math.sin(th) * math.cos(ph)
        if el >= 0:
            t = 1.0 - min(1.0, el / (math.pi / 2)) ** 0.6
            r, g, b = 0.25 + 0.75 * t, 0.45 + 0.55 * t, 1.0
            k = 1.1
            r, g, b = r * k, g * k, b * k
        else:
            r, g, b = 0.22, 0.21, 0.18
        c = dx * sx + dy * sy + dz * sz
        if c > math.cos(math.radians(1.2)):
            r, g, b = 2600.0, 2450.0, 2250.0     # the sun: integrated past the clip, lights the plate
        elif c > math.cos(math.radians(8.0)):
            glow = (c - math.cos(math.radians(8.0))) / (1.0 - math.cos(math.radians(8.0)))
            r, g, b = r + 6.0 * glow, g + 5.5 * glow, b + 4.5 * glow
        row += rgbe(r, g, b)
    rows.append(bytes(row))
with open(os.path.join(OUT, 'sky.hdr'), 'wb') as f:
    f.write(b'#?RADIANCE\nFORMAT=32-bit_rle_rgbe\n\n')
    f.write(f'-Y {H} +X {W}\n'.encode())
    for r in rows:
        f.write(r)
print(f'plate: {OUT}')

# ---- a probe to look at: a box with a ball on it, two materials --------------
def box(s):
    P, N, U, I = [], [], [], []
    faces = [((1,0,0),(0,0,-1),(0,1,0)), ((-1,0,0),(0,0,1),(0,1,0)), ((0,1,0),(1,0,0),(0,0,-1)),
             ((0,-1,0),(1,0,0),(0,0,1)), ((0,0,1),(1,0,0),(0,1,0)), ((0,0,-1),(-1,0,0),(0,1,0))]
    for n, u, v in faces:
        base = len(P) // 3
        for a, b in ((-1,-1),(1,-1),(1,1),(-1,1)):
            p = [s * (n[k] + a * u[k] + b * v[k]) for k in range(3)]
            p[1] += s
            P += p; N += list(n); U += [(a + 1) / 2, (b + 1) / 2]
        I += [base, base + 1, base + 2, base, base + 2, base + 3]
    return P, N, U, I

def ball(r, cy, seg=32, rings=16):
    P, N, U, I = [], [], [], []
    for j in range(rings + 1):
        th = math.pi * j / rings
        for i in range(seg + 1):
            ph = 2 * math.pi * i / seg
            n = (math.sin(th) * math.cos(ph), math.cos(th), math.sin(th) * math.sin(ph))
            P += [r * n[0], cy + r * n[1], r * n[2]]; N += list(n); U += [i / seg, j / rings]
    for j in range(rings):
        for i in range(seg):
            a = j * (seg + 1) + i; b = a + seg + 1
            I += [a, a + 1, b, a + 1, b + 1, b]
    return P, N, U, I

parts = [box(0.4), ball(0.3, 1.1)]
blob2, views2, accs2, prims2 = b'', [], [], []
for m, (P, N, U, I) in enumerate(parts):
    for data, fmt, typ, comp in ((P, 'f', 'VEC3', 5126), (N, 'f', 'VEC3', 5126), (U, 'f', 'VEC2', 5126), (I, 'I', 'SCALAR', 5125)):
        b = struct.pack(f'<{len(data)}{fmt}', *data)
        views2.append({'buffer': 0, 'byteOffset': len(blob2), 'byteLength': len(b)}); blob2 += b
        cnt = len(data) // {'VEC3': 3, 'VEC2': 2, 'SCALAR': 1}[typ]
        acc = {'bufferView': len(views2) - 1, 'componentType': comp, 'count': cnt, 'type': typ}
        if typ == 'VEC3' and len(accs2) % 4 == 0:
            acc['min'] = [min(P[k::3]) for k in range(3)]; acc['max'] = [max(P[k::3]) for k in range(3)]
        accs2.append(acc)
    k = m * 4
    prims2.append({'attributes': {'POSITION': k, 'NORMAL': k + 1, 'TEXCOORD_0': k + 2}, 'indices': k + 3, 'material': m})
with open(os.path.join(OUT, 'probe.bin'), 'wb') as f:
    f.write(blob2)
Image.new('RGB', (4, 4), (196, 110, 52)).save(os.path.join(OUT, 'probe_box.png'))
Image.new('RGB', (4, 4), (225, 225, 220)).save(os.path.join(OUT, 'probe_ball.png'))
Image.new('RGB', (4, 4), (255, 140, 0)).save(os.path.join(OUT, 'probe_arm.png'))
doc2 = {
    'asset': {'version': '2.0', 'generator': 'ludic tools/lab/plate_build.py'},
    'scene': 0, 'scenes': [{'nodes': [0]}],
    'nodes': [{'name': 'probe', 'mesh': 0}],
    'meshes': [{'name': 'probe', 'primitives': prims2}],
    'materials': [
        {'name': 'probe_box', 'pbrMetallicRoughness': {'baseColorTexture': {'index': 0}, 'metallicRoughnessTexture': {'index': 2}}},
        {'name': 'probe_ball', 'pbrMetallicRoughness': {'baseColorTexture': {'index': 1}, 'metallicRoughnessTexture': {'index': 2}}},
    ],
    'textures': [{'source': 0}, {'source': 1}, {'source': 2}],
    'images': [{'uri': 'probe_box.png'}, {'uri': 'probe_ball.png'}, {'uri': 'probe_arm.png'}],
    'buffers': [{'uri': 'probe.bin', 'byteLength': len(blob2)}],
    'bufferViews': views2,
    'accessors': accs2,
}
with open(os.path.join(OUT, 'probe.gltf'), 'w') as f:
    json.dump(doc2, f, indent=1)
