---
id: grid
title: Grid
order: 27
---

Tile geometry and pathfinding over the <a href="map"><code>Map</code></a> tilemap. A cell is passable unless it is out of bounds or holds the caller's <code>wall</code> tile (a char code, e.g. <code>'#'</code>), so any impassable glyph works. Everything is integer and deterministic — same map and query reproduce the same path every run. <a href="grid-line"><code>Grid.line</code></a>/<a href="grid-flood"><code>Grid.flood</code></a>/<a href="grid-a_star"><code>Grid.a_star</code></a> return <code>Cell</code> slices (index them with <code>len</code> / <code>[i]</code>; each cell has <code>.x</code> and <code>.y</code>).
