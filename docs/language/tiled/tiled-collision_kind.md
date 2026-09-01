---
id: tiled-collision_kind
name: Tiled.collision_kind
category: tiled
kind: namespace-method
tokens: Tiled.collision_kind
sig: Tiled.collision_kind(map, gid: int) -> int
tip: Classify a GID's collision from its tile metadata.
order: 15
ns: Tiled
member: collision_kind
---

Returns the collision kind a GID resolves to from its tile metadata, in the design's priority order (per-tile <code>&lt;objectgroup&gt;</code> hitboxes, then the property convention): <code>0</code> none, <code>1</code> solid, <code>2</code> one-way, <code>3</code> trigger. The collision-layer fallback (any non-zero GID solid) is applied by <a href="tiled-project"><code>Tiled.project</code></a>, not here.
