---
id: tiled-resolve
name: Tiled.resolve
category: tiled
kind: namespace-method
tokens: Tiled.resolve
sig: Tiled.resolve(map, gid: int) -> gidinfo
tip: Decode a GID into tileset, local id and flip flags.
order: 5
ns: Tiled
member: resolve
---

Decomposes a raw GID: strips the three flip flags (<code>0x80000000</code> horizontal, <code>0x40000000</code> vertical, <code>0x20000000</code> anti-diagonal), keeps the low 29 bits as the global tile id, and finds the owning tileset. Returns a value with fields <code>tileset</code> (index, -1 if none), <code>local</code> (id within that tileset), <code>fh</code>/<code>fv</code>/<code>fd</code> (the flip flags) and <code>empty</code> (1 when the GID was 0).
