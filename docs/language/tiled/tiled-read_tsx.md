---
id: tiled-read_tsx
name: Tiled.read_tsx
category: tiled
kind: namespace-method
tokens: Tiled.read_tsx
sig: Tiled.read_tsx(path: string) -> value
tip: Read a tileset file into a value object.
order: 2
ns: Tiled
member: read_tsx
---

Reads a standalone Tiled tileset file at <code>path</code> (TSX or TSJ) and returns a tileset <a href="value"><code>Value</code></a> object: <code>name</code>, <code>tilewidth</code>/<code>tileheight</code>, <code>spacing</code>, <code>margin</code>, <code>columns</code>, <code>tilecount</code>, the <code>image</code> and its size, and a <code>tiles</code> list of per-tile metadata (animation frames, collision shapes, properties). This is what a map's external <code>{firstgid, source}</code> tileset reference resolves to.
