---
id: tiled-project
name: Tiled.project
category: tiled
kind: namespace-method
tokens: Tiled.project
sig: Tiled.project(map, layer: int) -> void
tip: Project a collision layer to the byte tilemap.
order: 11
ns: Tiled
member: project
---

Designates tile <code>layer</code> as the collision layer and projects it onto the legacy byte tilemap: an empty cell is a space (passable), a GID whose tile carries the bool <code>oneway</code> property is <code>'='</code>, any other non-zero GID is <code>'#'</code> (solid). <a href="tiled-load"><code>Tiled.load</code></a> calls this automatically for a layer named <code>collision</code>/<code>solids</code>/<code>walls</code>.
