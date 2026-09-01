---
id: tiled-frame_gid
name: Tiled.frame_gid
category: tiled
kind: namespace-method
tokens: Tiled.frame_gid
sig: Tiled.frame_gid(map, gid: int, frame: int) -> int
tip: The current GID of an animated tile at a frame.
order: 18
ns: Tiled
member: frame_gid
---

Returns the GID an (animated) <code>gid</code> resolves to at engine <code>frame</code>: elapsed ms = <code>frame * 1000 / 60</code>, walked across the tileset <code>&lt;animation&gt;</code>'s frame durations to the current frame's tile — its flip flags preserved. A GID with no animation passes through unchanged.
