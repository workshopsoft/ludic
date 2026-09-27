# ludic.nav

A walkable mesh of the world and the ways across it, over
[Recast & Detour](https://github.com/recastnavigation/recastnavigation) (zlib) built here from a
pinned tag (phase 17). Uses `ludic.base` and nothing else.

```ludic
import "ludic.nav"
```

## The rules it keeps

- **One mesh per kind of walker.** `NAV_PERSON` (0.35 m wide, the hiker's 0.55 m step),
  `NAV_LARGE` (an elk, a bear, a horse) and `NAV_SMALL` (a hare, a marmot) each have their own,
  because what a hare slips between a bear walks round. A `NavConfig` says what a mesh is built
  for: its voxels and its walker's height, radius, step and steepest slope.
- **Built from ground, or loaded from a bake.** A `NavGround` is triangles - each with an area
  byte, 0 not walkable and 1..62 a kind of ground - and what nothing stands in: cylinders (a trunk,
  a post) and convex footprints (a boulder). Ground steeper than the slope is cleared whatever its
  area. `nav_build` makes one mesh of it; a map is square tiles (`nav_tiled`, then `nav_tile_build`
  for each tile from the ground under it and a few metres round), and a tile must be a whole number
  of cells across or its seams never join - the shim refuses one that is not. A game bakes its maps
  once and loads the bytes (`nav_save_file` / `nav_load_file`, one format for one tile or many): a
  map is never built at start-up. Polygon refs are 64-bit, so a map may have 16384 tiles.
- **A path is corners.** `nav_path` answers the way from one point to another as the corners
  where it turns, the first the start and the last the end. When the end cannot be reached the
  path stops as near it as the mesh allows and `nav_partial` says so - a walker goes there and
  gives up, never through a river. Either end off the mesh is `-1`.
- **A wander's goal is somewhere it can go.** `nav_random_near` answers a point about r away that a
  walker standing at the start can reach - never across a river without a ford - from a seed the
  caller draws from its own `Rng`, so the same seed is the same point on every machine.
- **A kind of ground has a cost** (`nav_area_cost`): a trail cheaper than a meadow, scree dearer.
- **The same question gets the same answer.** Detour is deterministic for the same mesh and the
  same points, so co-op's order of dice is untouched by asking it.

## API

| | |
| --- | --- |
| `NAV_PERSON`, `NAV_LARGE`, `NAV_SMALL`, `NAV_CORNERS` | the kinds of walker, and a path's most corners (256) |
| `NavConfig { cell, cell_h, height, radius, climb, slope }` | what a mesh is built for (a person by default, 0.25 m cells) |
| `NavGround { v, nv, t, nt, area, cyl, nc, foot, nf }` | what it is built from: triangles, an area byte each, cylinders (`x, y, z, r, h`) and footprints (`n`, n points `x z`, `ymin`, `ymax`) |
| `nav_build(kind, ground, config) -> bool`, `nav_polygons(kind)` | one mesh over all of it |
| `nav_tiled(kind, ox, oz, tile, max_tiles, max_polys) -> bool`, `nav_tile_build(kind, tx, tz, ground, config) -> int` | a map of square tiles, a tile at a time (its polygons, 0 none, -1 failed) |
| `nav_save_file(kind, path)`, `nav_load_file(kind, path)`, `nav_reset()` | a baked mesh written and read; every mesh let go |
| `nav_nearest(kind, x, y, z) -> bool`, `nav_near_x/y/z()` | the nearest walkable point within a couple of metres |
| `nav_path(kind, sx, sy, sz, ex, ey, ez) -> int`, `nav_corners()`, `nav_corner_x/y/z(i)`, `nav_partial(kind)` | a way as corners |
| `nav_straight(kind, sx, sy, sz, ex, ez) -> bool` | does the straight line stay walkable |
| `nav_random_near(kind, x, y, z, r, seed) -> bool`, `nav_near_x/y/z()` | a reachable point about r away, from the caller's seed |
| `nav_area_cost(kind, area, cost)` | how dear a kind of ground is to cross |

## Tests

```bash
ludic test packages/ludic.nav
```

A 40 m meadow built by hand: a path round a post and a boulder's footprint, over a river's ford,
stopping at the bank of a river with none, the nearest point, random points that never cross the
river, and a saved mesh answering as the built one did. And a 128 m meadow as four tiles: a path
across the seams, a tile under water with no polygons, and the set saved and loaded.

## The native library

`native/build.sh` fetches Recast & Detour v1.6.0, checks its SHA-256, and builds Recast, Detour
and the shim (`native/shim/nav_shim.cpp`) into `lib/<target>/` - the same script on the Mac and on
the PC (Git Bash, the LLVM installer's clang). `native/LICENSE-recastnavigation` ships with it.
