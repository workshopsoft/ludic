# ludic.procgen

Deterministic, seeded level generators as data: room-and-corridor dungeons, tile maps from adjacency rules
(wave function collapse over edge sockets), and scattered placement within regions. A generator is a pure
function of its recipe and a seed, in **integer arithmetic only**, so an editor reproduces the output exactly and
a save need only keep the seed. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.procgen"
```

**Not `ludic.dungeon`.** That package builds arena rooms straight into the engine tilemap (`Map.*`) and draws from the
global `Random.*`, which cannot be reproduced outside the engine; it is left as it is, and these generators fill
grids the caller owns.

## Conformance: the golden file

[`tests/procgen_golden.json`](tests/procgen_golden.json) holds the stream's first numbers, `hash2` vectors and 19
cases (5 dungeons, 9 tile maps, 5 scatters) each as its INPUT and the OUTPUT the algorithms below must make of it.
`tests/procgen_test.ludic` holds the package to it line for line; regenerate it, after a deliberate change, with

```bash
bin/ludic run packages/ludic.procgen/tests/gen/procgen_golden.ludic --headless
```

[`tests/reference/procgen.py`](tests/reference/procgen.py) is a second implementation written from this README alone;
`python3 tests/reference/procgen.py tests/procgen_golden.json` reads the inputs, runs it and compares every output
number for number. **A studio's preview does the same**: implement what follows, read the file, agree.

## The arithmetic

Every number is a signed 32-bit integer; `+` and `*` wrap; `>>>` is a logical shift; `x % n` and `x / n` are
only applied to non-negative `x` and positive `n`. There is no floating point anywhere.

### The stream

```
mix(z):      z ^= z >>> 16;  z *= 0x85EBCA6B;  z ^= z >>> 13;  z *= 0xC2B2AE35;  z ^= z >>> 16;  return z
next():      s = s + 0x9E3779B9;  return mix(s) & 0x7FFFFFFF                 # s starts as the seed itself
below(n):    n <= 1 ? 0 : next() % n                                          # n <= 1 draws NOTHING
between(lo, hi) = lo + below(hi - lo + 1)                                     # inclusive; hi <= lo is lo, no draw
hash2(a, b): mix(a * 16777619 + mix(b + 0x9E3779B9))                          # a new seed from a seed and an index
```

The constants are the signed numbers they wrap to (`-1640531527`, `-2048144789`, `-1028477387`). "Draws nothing"
matters: where a choice has one possible value the stream does not move, so its position depends only on real
choices. The API: `pg_mix`, `pg_hash2`, `pg_rng_new(seed)`, `pg_seed`, `pg_next`, `pg_below`, `pg_between`.

### Dungeons: `pg_dungeon(row, seed, out) -> rooms`

Recipe `ProcDungeon { width, height (8..256), rooms, room_min, room_max, pad, attempts, loops }`. Output
`ProcDungeonOut`: `grid` (cell `(x, y)` is `cells[y * w + x]`: 0 wall, 1 room floor, 2 corridor floor), the rooms
`rx, ry, rw, rh` in the order placed, `start` (always 0), `exit`.

1. `rng = stream(seed)`. Up to `attempts` times, stopping when `rooms` are placed: `w = between(room_min, room_max)`,
   `h = between(room_min, room_max)`, `x = between(1, width - w - 1)`, `y = between(1, height - h - 1)` (in that
   order). Skip it if `x + w > width - 1` or `y + h > height - 1`. Skip it if it touches a placed room: with `pad`,
   reject when `x < rx + rw + pad and rx < x + w + pad and y < ry + rh + pad and ry < y + h + pad` for any room.
   Otherwise keep it.
2. Every room cell becomes 1.
3. Centres: `cx = x + w / 2`, `cy = y + h / 2` (integer division). With n >= 2 rooms, join them as a **minimum
   spanning tree (Prim) by Manhattan distance between centres**, starting from room 0: n - 1 times, over tree rooms `i`
   in index order and non-tree rooms `j` in index order, take the pair with the smallest distance (the first wins a
   tie: strictly less replaces); join it, then add `j` to the tree.
4. **Join(i, j)**: draw `below(2)`. If 1: carve the horizontal run along `y = cy_i` from `cx_i` to `cx_j`, then
   the vertical run along `x = cx_j` from `cy_i` to `cy_j`. If 0: the vertical run along `x = cx_i` first, then the
   horizontal run along `y = cy_j`. A run includes both ends and steps by +1 or -1; a carved cell that is 0 becomes 2
   (room cells stay 1).
5. Then `loops` times: `a = below(n)`, `b = below(n)` (both drawn); if `a != b`, Join(a, b). (With n < 2 there are no
   corridors and no loops.)
6. `exit`: the room with the greatest Manhattan centre distance from room 0, the lowest index on a tie (strictly
   greater replaces, starting from room 0 at distance 0). Returns the number of rooms; an out-of-range row (size
   outside 8..256, `room_min < 1`, `room_max < room_min`) returns 0 with a 1 x 1 grid.

### Tile maps: `pg_wfc(tiles, nt, width, height, border, tries, seed, out) -> attempt`

Tiles `ProcTile { weight, n, e, s, w }` (sockets are ints; a set has at most 32 tiles, numbered in order), a map
`ProcMap { set, width, height (1..64), border (a tile key, "" none), tries }`. Tile `u` may lie **east** of tile `t`
when `t.e == u.w`, **south** when `t.s == u.n`, **west** when `t.w == u.e`, **north** when `t.n == u.s`. Directions
are numbered 0 east, 1 south, 2 west, 3 north; `compat[d][t]` is the bit mask (bit `u` set) of the tiles that may lie
in direction `d` of `t`. For attempt `a` in `0 .. tries - 1`:

1. `rng = stream(hash2(seed, a))`. Every cell's mask is all tiles (`(1 << nt) - 1`, all 32 bits for 32 tiles).
2. If `border >= 0`, each cell on the map's edge (`x == 0`, `y == 0`, `x == width - 1` or `y == height - 1`) has its
   mask ANDed with `1 << border`; an empty mask fails the attempt.
3. **Propagate** (from every cell, row by row, so a set that cannot lie together fails here): a stack; pop a cell `c`; for
   each direction `d` (0 to 3) with a neighbour `n` inside the map (no wrapping): `allowed` = the OR of `compat[d][t]`
   over the tiles `t` in `mask[c]`; `new = mask[n] & allowed`; if 0 the attempt fails; if it changed, store it and push
   `n`. The fixed point does not depend on the order.
4. **Loop**: among cells with more than one tile left, take the fewest left (a count of set bits); if there are none, the
   attempt has worked. Let `k` be how many cells tie; `i = below(k)` picks the `i`-th (from 0, row by row). Collapse it:
   `total` = the sum of the weights of its tiles, `r = below(total)`, take the first tile (by index) whose running
   weight sum exceeds `r`; its mask becomes that one bit; propagate from it; a contradiction fails the attempt.
5. A worked attempt writes the tile index of every cell (row by row) and returns `a`. All `tries` failing returns -1
   with every cell -1; an out-of-range call (`nt` not 1..32, size not 1..64, `border >= nt`) returns -2.

### Scatter: `pg_scatter(row, seed, out) -> points`

Recipe `ProcScatter { min_dist, attempts, regions, avoid, kinds }` with `ProcRegion { shape, x, y, w, h, count }`
(`rect`: `x <= px < x + w`, `y <= py < y + h`; `disc`: centre `(x, y)`, radius `w`, `(px - x)^2 + (py - y)^2 <= w^2`) and
`ProcKind { weight, scale_lo, scale_hi }`. Coordinates are whole units within +-16383 (so a squared distance fits an int).

For each region in order, `count` times: up to `attempts` tries, each: draw the candidate (**rect**: `px = x + below(w)`,
`py = y + below(h)`; **disc**: `px = x - w + below(2w + 1)`, `py = y - w + below(2w + 1)`); reject it if it is not in its
region, is in any `avoid` region, or is nearer than `min_dist` to any point placed so far (`dx^2 + dy^2 < min_dist^2`,
and only when `min_dist > 0`, over every region's points). An accepted point draws, in this order: its kind
(`r = below(sum of weights)`, the first kind whose running sum exceeds `r`; 0 and no draw without kinds), its angle
`below(360)`, its scale `between(scale_lo, scale_hi)` of that kind (1000 without kinds), is stored as
`(x, y, kind, angle, scale, region)` and ends the tries. A point that finds no place in `attempts` tries is given up; the next
starts. `out` is `ProcPoints { x, y, kind, angle, scale, region }` lists.

## The data

Open, append-only registries with editor attributes (`@Range`, `@OneOf`, `@Unit`), so an editor offers every recipe: `ProcDungeons`
(`PGD_*`), `ProcTiles` (`PGT_*`; a tile's `set` names its tile set), `ProcMaps` (`PGM_*`), `ProcScatters` (`PGS_*`; nested
`regions`, `avoid`, `kinds` lists).

```
# scatters.lres
meadow {
  min_dist: 6
  attempts: 40
  regions: [{ shape: "rect", x: 0, y: 0, w: 100, h: 80, count: 30 }, { shape: "disc", x: 300, y: 300, w: 25, count: 10 }]
  avoid: [{ shape: "disc", x: 50, y: 40, w: 15 }]
  kinds: [{ key: "fern", weight: 3, scale_lo: 800, scale_hi: 1200 }, { key: "rock", weight: 1, scale_lo: 500, scale_hi: 500 }]
}
```

## Running a recipe, and what is saved

The pure functions take their outputs from the caller (`procdungeon_new()`, `procgrid_new(w, h)`, `procpoints_new()`: made once,
filled again by every run; nothing is made per generation after the first). The state runs a recipe of the tables by index:

| | |
| --- | --- |
| `procgen_dungeon(recipe, seed)`, `procgen_map(recipe, seed)`, `procgen_scatter(recipe, seed)` | run it; the result as above (`procgen_map`: -3 no such recipe, -2 a tile set or border tile that is wrong) |
| `procgen_dungeon_out()`, `procgen_map_out()`, `procgen_points_out()` | the latest output of each; copy what the game keeps |
| `procgen_seed_for(world_seed, name)` | a seed for a named thing from the world's |
| `procgen_ran(kind, recipe)`, `procgen_seed_of(kind, recipe)` | what has been run |
| `procgen_facts()` | a `PROCGEN_DONE` (kind, recipe, seed, result, count) per run |
| `procgen_system()` | `procgen` in `PH_SIMULATE`, no tick |

**The save is the seeds**: each recipe's key and the seed it last ran with (section `procgen`, version 1). A load runs them
again; the same seed makes the same level, so a save does not carry a level. A recipe the build no longer has is left out.

## Limits

Dungeon grids at most 256 x 256, tile maps 64 x 64 with at most 32 tiles a set, scatter coordinates within +-16383. `pg_dungeon`
compares every room with every room placed (quadratic in rooms); `pg_scatter` every candidate with every point placed
(quadratic in points; a few thousand are fine); `pg_wfc` rescans the map for the fewest-left cell each step.

## v2

Fixed cells and a pre-painted map as WFC constraints; a per-tile count cap; overlapping-model WFC; doors and room kinds in dungeons (key rooms,
secret rooms); wider corridors; BSP and cellular-automata dungeons; Poisson-disc with a spatial hash for large scatters; a scatter that follows
a painted density; the same algorithms in the studio's preview (this golden is its test).
