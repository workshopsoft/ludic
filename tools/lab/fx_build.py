#!/usr/bin/env python3
"""fx_build.py - the lab's effect props, for looking at blended actors (ludic.render3d actor_blend.ludic).

Writes packages/ludic.lab/plate/:
  fx.gltf / fx.bin   three nodes:
                       puff    a 1 m card in the x-y plane facing +z, centred, material fx_puff
                       glow    the same card, material fx_glow
                       bubble  a sphere of radius 1 (32 x 16), material fx_bubble: a pale blue base colour
  fx_puff.png        128 x 128 RGBA: white, its alpha a soft lumpy disc (a puff of smoke)
  fx_glow.png        128 x 128 RGBA: white, its alpha a gaussian falling to nothing at the edge (a glow)
Deterministic: the same bytes every run.
"""
import json, math, os, struct, sys
from PIL import Image

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'packages', 'ludic.lab', 'plate')
os.makedirs(OUT, exist_ok=True)

# ---- the card --------------------------------------------------------------
card_pos = [-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0]
card_nrm = [0.0, 0.0, 1.0] * 4
card_uv = [0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0]
card_idx = [0, 1, 2, 0, 2, 3]

# ---- the sphere ------------------------------------------------------------
SEG, RING = 32, 16
sph_pos, sph_nrm, sph_uv, sph_idx = [], [], [], []
for j in range(RING + 1):
    v = j / RING
    phi = math.pi * v
    for i in range(SEG + 1):
        u = i / SEG
        th = 2.0 * math.pi * u
        x, y, z = math.sin(phi) * math.cos(th), math.cos(phi), math.sin(phi) * math.sin(th)
        sph_pos += [x, y, z]; sph_nrm += [x, y, z]; sph_uv += [u, v]
for j in range(RING):
    for i in range(SEG):
        a = j * (SEG + 1) + i
        b = a + SEG + 1
        # counter-clockwise seen from outside
        sph_idx += [a, a + 1, b, a + 1, b + 1, b]

blob = b''
views, accessors = [], []
def add(data, fmt, count, typ, comp, extra=None):
    global blob
    b = struct.pack(f'<{len(data)}{fmt}', *data)
    views.append({'buffer': 0, 'byteOffset': len(blob), 'byteLength': len(b)})
    blob += b
    acc = {'bufferView': len(views) - 1, 'componentType': comp, 'count': count, 'type': typ}
    if extra: acc.update(extra)
    accessors.append(acc)
    return len(accessors) - 1

def mesh_accessors(pos, nrm, uv, idx):
    n = len(pos) // 3
    xs, ys, zs = pos[0::3], pos[1::3], pos[2::3]
    p = add(pos, 'f', n, 'VEC3', 5126, {'min': [min(xs), min(ys), min(zs)], 'max': [max(xs), max(ys), max(zs)]})
    q = add(nrm, 'f', n, 'VEC3', 5126)
    t = add(uv, 'f', n, 'VEC2', 5126)
    i = add(idx, 'I', len(idx), 'SCALAR', 5125)
    return {'POSITION': p, 'NORMAL': q, 'TEXCOORD_0': t}, i

card_attr, card_ix = mesh_accessors(card_pos, card_nrm, card_uv, card_idx)
sph_attr, sph_ix = mesh_accessors(sph_pos, sph_nrm, sph_uv, sph_idx)
with open(os.path.join(OUT, 'fx.bin'), 'wb') as f:
    f.write(blob)

doc = {
    'asset': {'version': '2.0', 'generator': 'ludic tools/lab/fx_build.py'},
    'scene': 0, 'scenes': [{'nodes': [0, 1, 2]}],
    'nodes': [{'name': 'puff', 'mesh': 0}, {'name': 'glow', 'mesh': 1}, {'name': 'bubble', 'mesh': 2}],
    'meshes': [
        {'name': 'puff', 'primitives': [{'attributes': card_attr, 'indices': card_ix, 'material': 0}]},
        {'name': 'glow', 'primitives': [{'attributes': card_attr, 'indices': card_ix, 'material': 1}]},
        {'name': 'bubble', 'primitives': [{'attributes': sph_attr, 'indices': sph_ix, 'material': 2}]},
    ],
    'materials': [
        {'name': 'fx_puff', 'alphaMode': 'BLEND', 'pbrMetallicRoughness': {'baseColorTexture': {'index': 0}, 'metallicFactor': 0.0, 'roughnessFactor': 1.0}},
        {'name': 'fx_glow', 'alphaMode': 'BLEND', 'pbrMetallicRoughness': {'baseColorTexture': {'index': 1}, 'metallicFactor': 0.0, 'roughnessFactor': 1.0}},
        {'name': 'fx_bubble', 'alphaMode': 'BLEND', 'pbrMetallicRoughness': {'baseColorFactor': [0.45, 0.75, 1.0, 1.0], 'metallicFactor': 0.0, 'roughnessFactor': 0.2}},
    ],
    'textures': [{'source': 0}, {'source': 1}],
    'images': [{'uri': 'fx_puff.png'}, {'uri': 'fx_glow.png'}],
    'buffers': [{'uri': 'fx.bin', 'byteLength': len(blob)}],
    'bufferViews': views,
    'accessors': accessors,
}
with open(os.path.join(OUT, 'fx.gltf'), 'w') as f:
    json.dump(doc, f, indent=1)

# ---- the textures ------------------------------------------------------------
T = 128
def smooth(e0, e1, x):
    t = min(max((x - e0) / (e1 - e0), 0.0), 1.0)
    return t * t * (3.0 - 2.0 * t)
def lump(x, y):
    # a few fixed soft blobs: a puff is not a perfect disc
    s = 0.0
    for (cx, cy, r, w) in ((0.30, 0.38, 0.30, 0.9), (0.66, 0.42, 0.28, 0.8), (0.48, 0.66, 0.32, 1.0), (0.52, 0.48, 0.36, 1.0)):
        d = math.hypot(x - cx, y - cy) / r
        s = max(s, w * (1.0 - smooth(0.2, 1.0, d)))
    return s
puff = Image.new('RGBA', (T, T))
glow = Image.new('RGBA', (T, T))
pp, gp = puff.load(), glow.load()
for y in range(T):
    for x in range(T):
        u, v = (x + 0.5) / T, (y + 0.5) / T
        r = math.hypot(u - 0.5, v - 0.5) / 0.5
        edge = 1.0 - smooth(0.55, 1.0, r)
        a = lump(u, v) * edge
        pp[x, y] = (255, 255, 255, int(round(255 * min(max(a, 0.0), 1.0))))
        g = math.exp(-r * r * 4.0) * (1.0 - smooth(0.8, 1.0, r))
        gp[x, y] = (255, 255, 255, int(round(255 * g)))
puff.save(os.path.join(OUT, 'fx_puff.png'))
glow.save(os.path.join(OUT, 'fx_glow.png'))
print('wrote', OUT)
