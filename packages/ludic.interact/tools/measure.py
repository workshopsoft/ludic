#!/usr/bin/env python3
"""measure.py - interaction points (ludic.interact) read from a glb, written as InteractPoint rows.

  python3 measure.py <file.glb> <node> [--obj NAME] [--empties] [--seats N --reach R [--width W]] [--from-root DX,DZ]

Two ways, the first preferred:
  --empties   every node under <node> named SOCKET_<name> (Unreal's FBX convention for static-mesh sockets) is a point: its
              translation and its yaw (about +y) in <node>'s frame; glTF extras {"part": "hand_r", "radius": 0.1} give the rest
              (part defaults from the name: seat* pelvis, stand* feet, grip*/wheel_r hand_r, support*/wheel_l hand_l, sight*/eye* eye)
  --seats N   a model without empties (the benches): N SEAT points measured from the mesh itself (--back B: the pelvis this far in front of the seat's back
              edge, default 0.12 m; --zlo/--zhi: the seat's depth band in the model when it is not the front 60%, a shelter's seat at its back). The seat's top is the highest
              upward-facing triangle under 0.7 m in the front half of the model's depth (the backrest and the arms left out), the
              places spread across its width like ludic.crowd's places (0.7 m apart about the middle); each SEAT's depth is the
              middle of that surface, and each STAND point is the SEAT moved forward by --reach (the sit clip's pelvis travel: the
              root place the sit-target solve gives, interact_solve with the pelvis's last-key offset)
The model's frame is ludic's: +z forward (the way a sitter faces), +x the facing's right, +y up. --from-root DX,DZ writes the points
relative to a place DX right and DZ forward of the model's origin (a scenario row that does not stand at the origin).
Prints .lres rows on stdout.
"""
import json, math, struct, sys
import numpy as np


def load(path):
    b = open(path, 'rb').read()
    assert b[:4] == b'glTF'
    n = struct.unpack_from('<I', b, 12)[0]
    js = json.loads(b[20:20 + n])
    off = 20 + n
    bn = struct.unpack_from('<I', b, off)[0]
    return js, b[off + 8: off + 8 + bn]


def accessor(js, binb, i):
    a = js['accessors'][i]
    v = js['bufferViews'][a['bufferView']]
    comp = {5126: ('f', 4), 5125: ('I', 4), 5123: ('H', 2), 5121: ('B', 1)}[a['componentType']]
    k = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}[a['type']]
    start = v.get('byteOffset', 0) + a.get('byteOffset', 0)
    stride = v.get('byteStride', comp[1] * k)
    dt = np.dtype('<' + comp[0])
    out = np.empty((a['count'], k), dtype=dt)
    for r in range(a['count']):
        out[r] = np.frombuffer(binb, dtype=dt, count=k, offset=start + r * stride)
    return out


def node_matrix(nd):
    if 'matrix' in nd:
        return np.array(nd['matrix'], dtype=float).reshape(4, 4).T
    t = nd.get('translation', [0, 0, 0])
    x, y, z, w = nd.get('rotation', [0, 0, 0, 1])
    s = nd.get('scale', [1, 1, 1])
    r = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                  [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                  [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])
    m = np.eye(4)
    m[:3, :3] = r * np.array(s)
    m[:3, 3] = t
    return m


def walk(js, i, m, out):
    nd = js['nodes'][i]
    mm = m @ node_matrix(nd)
    out.append((i, mm))
    for c in nd.get('children', []):
        walk(js, c, mm, out)


def find(js, name):
    for i, nd in enumerate(js['nodes']):
        if nd.get('name') == name:
            return i
    raise SystemExit(f'no node {name}')


def part_of(name):
    n = name.lower()
    for pre, part in (('seat', 'pelvis'), ('helm_sit', 'pelvis'), ('stand', 'feet'), ('board', 'feet'), ('leave', 'feet'),
                      ('helm', 'feet'), ('wheel_r', 'hand_r'), ('wheel_l', 'hand_l'), ('throttle', 'hand_r'), ('grip', 'hand_r'),
                      ('support', 'hand_l'), ('handle', 'hand_r'), ('sight', 'eye'), ('eye', 'eye'), ('mag', 'hand_l')):
        if n.startswith(pre):
            return part
    return 'root'


def row(obj, name, part, x, y, z, yaw, radius=0.0, ax=0.0, ay=0.0, az=0.0):
    s = f'{obj}.{name} {{ obj: "{obj}", name: "{name}", part: "{part}", x: {x:.3f}, y: {y:.3f}, z: {z:.3f}, yaw: {yaw:.1f}'
    if radius > 0:
        s += f', radius: {radius:.3f}'
    if ax or ay or az:
        s += f', ax: {ax:.3f}, ay: {ay:.3f}, az: {az:.3f}'
    return s + ' }'


def empties(js, root, obj):
    nodes = []
    walk(js, root, np.eye(4), nodes)
    inv = np.linalg.inv(nodes[0][1])
    rows = []
    for i, m in nodes[1:]:
        nd = js['nodes'][i]
        nm = nd.get('name', '')
        if not nm.startswith('SOCKET_'):
            continue
        name = nm[len('SOCKET_'):].lower()
        lm = inv @ m
        x, y, z = lm[:3, 3]
        fwd = lm[:3, 2]
        yaw = math.degrees(math.atan2(fwd[0], fwd[2]))
        ex = nd.get('extras', {})
        rows.append(row(obj, name, ex.get('part', part_of(name)), x, y, z, yaw, float(ex.get('radius', 0.0))))
    return rows


def mesh_tris(js, binb, root):
    nodes = []
    walk(js, root, np.eye(4), nodes)
    inv = np.linalg.inv(nodes[0][1])
    tris = []
    for i, m in nodes:
        nd = js['nodes'][i]
        if 'mesh' not in nd:
            continue
        lm = inv @ m
        for p in js['meshes'][nd['mesh']]['primitives']:
            pos = accessor(js, binb, p['attributes']['POSITION']).astype(float)
            pos = (lm[:3, :3] @ pos.T).T + lm[:3, 3]
            if 'indices' in p:
                ix = accessor(js, binb, p['indices']).reshape(-1)
            else:
                ix = np.arange(len(pos))
            tris.append(pos[ix.reshape(-1, 3)])
    return np.concatenate(tris)


def seats(js, binb, root, obj, n, reach, width, dx, dz, back, zlo=None, zhi=None):
    t = mesh_tris(js, binb, root)
    nrm = np.cross(t[:, 1] - t[:, 0], t[:, 2] - t[:, 0])
    area = np.linalg.norm(nrm, axis=1) * 0.5
    up = nrm[:, 1] / np.maximum(area * 2.0, 1e-12)
    c = t.mean(axis=1)
    zmin, zmax = t[:, :, 2].min(), t[:, :, 2].max()
    xmin, xmax = t[:, :, 0].min(), t[:, :, 0].max()
    w = width if width > 0 else (xmax - xmin)
    # upward faces under 0.7 m, in the front 60% of the depth, inside the middle 80% of the width (no arms)
    sel = (up > 0.9) & (c[:, 1] < 0.7) & (c[:, 1] > 0.2) & (c[:, 2] > (zlo if zlo is not None else zmin + 0.4 * (zmax - zmin))) & (c[:, 2] < (zhi if zhi is not None else zmax + 1.0)) & (np.abs(c[:, 0] - (xmin + xmax) * 0.5) < w * 0.4)
    if not sel.any():
        raise SystemExit('no seat surface found')
    top = c[sel, 1]
    # the seat's top: the area-weighted height of the highest band (slats a few mm apart are one surface)
    h = top.max()
    band = sel & (c[:, 1] > h - 0.03)
    y = float(np.average(c[band, 1], weights=area[band]))
    zs = t[band][:, :, 2]
    z0, z1 = float(zs.min()), float(zs.max())
    # the pelvis sits back on a seat: the hip joint `back` in front of the seat's back edge (the backrest's foot), not at the middle
    zseat = min(z0 + back, (z0 + z1) * 0.5)
    rows = []
    for k in range(n):
        off = (k - (n - 1) * 0.5) * 0.7
        rows.append(row(obj, f'seat_{k}', 'pelvis', off - dx, y, zseat - dz, 0.0, 0.25))
        rows.append(row(obj, f'stand_{k}', 'feet', off - dx, 0.0, zseat + reach - dz, 0.0, 0.3))
    print(f'# {obj}: seat top {y:.3f} m, seat depth {z0:.3f}..{z1:.3f} (front edge {z1:.3f}), width {xmax - xmin:.3f}', file=sys.stderr)
    return rows


def main():
    a = sys.argv[1:]
    path, node = a[0], a[1]

    def opt(k, d=None):
        return a[a.index(k) + 1] if k in a else d
    obj = opt('--obj', node)
    js, binb = load(path)
    root = find(js, node)
    dx, dz = (float(v) for v in opt('--from-root', '0,0').split(','))
    if '--seats' in a:
        out = seats(js, binb, root, obj, int(opt('--seats')), float(opt('--reach', '0.382')), float(opt('--width', '0')), dx, dz, float(opt('--back', '0.12')),
                    float(opt('--zlo')) if '--zlo' in a else None, float(opt('--zhi')) if '--zhi' in a else None)
    else:
        out = empties(js, root, obj)
    print('\n'.join(out))


if __name__ == '__main__':
    main()
