---
id: tiled-read
name: Tiled.read
category: tiled
kind: namespace-method
tokens: Tiled.read
sig: Tiled.read(path: string) -> value
tip: Read a map file into the intermediate value tree.
order: 1
ns: Tiled
member: read
---

Reads a Tiled map file at <code>path</code> — auto-detecting TMX (XML) vs TMJ (JSON) by its first byte — and returns the intermediate map <a href="value"><code>Value</code></a> tree in Tiled's JSON schema: <code>orientation</code>, <code>width</code>/<code>height</code>, <code>tilewidth</code>/<code>tileheight</code>, a <code>tilesets</code> list and a <code>layers</code> list. Every tile layer's <code>data</code> is decoded to a dense GID int list (CSV split, or base64 → zlib/gzip inflate → little-endian u32s), so the two formats yield structurally identical trees.
