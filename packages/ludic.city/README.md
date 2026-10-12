# ludic.city

A city as **authored data**: districts a designer outlines, blocks outlined and built through Blender, every
building placed with a stable id, landmarks, and the zoning rules and generator presets they draw on. Nothing is
generated at run time. The package streams the cells of buildings in and out as the player moves, answers queries
over what is loaded (by cell, rectangle, radius and id; homes and workplaces by capacity; the district, zoning and
ambient density at a point), and works the head counts out of the authored floor area and zoning, so "hundreds of
thousands of people" comes from content that exists. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.city"
```

**Why it does not generate.** The map (roads, districts, where each building stands, the towns) is the designer's.
Procedural buildings and blocks are made **offline, in Blender**, by a generator the studio drives with parameters;
what comes back is an ordinary glTF file and the parameters that made it, written as rows. The game loads rows and
assets, like anything else it ships. (An earlier draft of this package generated streets, lots and buildings at run
time from seeds; it was dropped for this.)

## How a designer authors a city

1. **Districts** - outline land in the studio; each polygon has a zoning (`downtown`, `residential_high`, `port`, `park`,
   `rural` ... whatever the game declared as `ZoningRules`), a density guide, style `tags` for the generator, the
   generator preset new blocks start from, and optionally its own ambient `crowd` and `traffic`.
2. **Blocks** - outline a block (`CityBlock.pts`), pick a preset (`BuildingGenerators`), set its knobs (`values`) and a seed.
   The studio sends outline, preset, knobs and seed to Blender.
3. **Blender builds it** - the generator the preset names runs with those parameters and exports one glTF for the block,
   a node for each building (or, for a preset whose `output` is `building`, a glTF a building).
4. **The studio writes the rows back** - the block's `asset` (and `node`), `built_hash` (see below), and one `Buildings` row per
   building in the glTF: its `model` and `node`, transform, footprint, floors, height, `lot` and `address`, doors, interior class.
   A building may instead be an instance of a **kit** (`BuildingKits`): a whole prefab the game modelled, placed by hand.
5. **Edit by hand** - nudge a building, turn a door, change a `use` or `residents`; the row is the truth. Re-running the
   generator on a block replaces its buildings (keys the studio keeps stable: a moved building keeps its key).
6. **Landmarks** - mark what the city is known by.

The studio knows a block is **stale** - its outline or knobs changed after the glTF was built - by `built_hash` against
`city_block_hash(block)`. The hash is integer arithmetic a studio repeats exactly (see "The block hash").

## The data

Game tables, declared by the game (`def ZoningRules from "zoning.lres"`, open, append-only, constants `ZR_*`, `CKIT_*`, `BG_*`, `IA_*`):

| table | a row |
| --- | --- |
| `ZoningRules` | `kind`, `res_pct` (share of floor area that is homes), `m2_per_person`, `m2_per_job`, `crowd` and `traffic` (ambient, per mille) |
| `BuildingKits` | a prefab building: `model` and `node`, footprint `w` x `d`, `floors`, `floor_h`, `tags` |
| `BuildingGenerators` | a Blender generator preset: `generator` id, `script`, `description`, `output` (block or building), `tags`, and `params`, each a `GenParam` (`name`, `type` int / float / bool / choice, `min`, `max`, `default_value`, `choices`, `label`, `unit`) for the studio to show as a slider, toggle or list |

Map tables, under `maps/<map>/city/` (`@PerMap`; `ludicc --check` reads every map against them, refs included):

| table | file | a row |
| --- | --- | --- |
| `Districts` | `districts.lres` | `zoning`, `density`, `tags`, `generator`, `crowd`, `traffic` (-1: the zoning's), `pts` polygon |
| `CityBlocks` | `blocks/{cx}_{cz}.lres` (**chunked**) | `x`, `z`, `district`, `preset`, `seed`, `values` (`GenValue`: `name`, `value`, `text`), `asset`, `node`, `built_hash`, `pts` outline |
| `Buildings` | `buildings/{cx}_{cz}.lres` (**chunked**) | see below |
| `Landmarks` | `landmarks.lres` | `kind`, `x`, `z`, `yaw`, `model`, `node`, `building`, `radius` |

A **chunked** table is read 256 m at a time: a row lives in the file of the cell its `(x, z)` is in (`cx = floor(x / 256)`,
negative allowed: `-1_0.lres`). A key is unique across the whole map, so a building moved into another chunk keeps it: its id
is `(map, key)`, stable because it is data. A `Buildings` row:

| field | meaning |
| --- | --- |
| `key` | its stable id |
| `block`, `district`, `use` | its block; its district (`""`: the one its position is in); a `ZoningRules` key that overrides the district's |
| `kit` | a `BuildingKits` key when it is an instance of a kit, else `model` + `node` (a generated block's glTF and the node in it) |
| `x`, `y`, `z`, `yaw`, `scale` | the transform (metres, degrees, 0 faces +z) |
| `w`, `d`, `floors`, `height` | footprint, floors, height (0: floors times the kit's `floor_h`, 3.5 m without a kit) |
| `roof` | the roof's kind, a word the game's kits know (`gable`, `hip`, ...); `""` is flat |
| `interior` | `none`; `fake` (a ludic.render3d `InteriorAtlases` key in `atlas`); `enterable` (the map whose key is `interior_map` holds the inside) |
| `lot`, `address` | the tags a property can be bought by |
| `residents`, `jobs` | capacity; -1: worked out from the floor area and zoning |
| `entrances` | doors: `x`, `z`, `yaw` (the way a person faces stepping in), `kind` door / garage / service |
| `footprint` | its real plan for colliders: a simple polygon of 3 points or more (`x`, `z`; either way round) in the model's own frame (origin at the middle of the footprint, before `yaw` and `scale`); empty: the rectangle `w` x `d`. The studio writes it when a generated block is accepted: the generator knows the plan |

## Running it

The tables are the compiler's states, passed in by the caller: `Districts`, `Buildings`, `CityBlocks`, `Landmarks`, plus this
package's `CityState` (which cells are loaded, the district index, a queue of facts). A row is a pooled record: keep its key
or its `(cell, row)` for the frame, never the record.

```ludic
# doc-check: skip - a frame of a game
function city_frame(city_st: mut CityState, bl: mut Buildings, districts: Districts, p: Player) -> void {
  city_stream_step(city_st, bl, "metro", p.x, p.z, 2)     # one cell in a frame, nearest first, the far ones out
  let fs = q_drain(city_facts(city_st))                   # CITY_LOADED / CITY_UNLOADED: batch or drop a cell's instances
}
```

| | |
| --- | --- |
| `city_index(st, districts)` | after `districts_load`: a bounding box a district |
| `city_stream(st, bl, map, x, z, reach)` | keep exactly the cells within `reach` of the point loaded; how many changed |
| `city_stream_step(...)` | the same, **one load a call**, nearest first, returning how many are still missing: a stream spread over frames |
| `city_stream_idle(st, x, z, reach)` | has the last stream call for this point's cell and reach nothing left to do: false until the first call, and after the point moves to another cell until the next call |
| `city_cell_in(st, bl, map, cx, cz)`, `city_cell_out(...)`, `city_clear(...)` | one cell by hand; `city_cell_in` returns its building count (0: nobody built there; -1: a bad file) |
| `city_cell_of / _count / _cx / _cz / _size` | the loaded cells, as indexes |
| `city_facts(st)` | `CityFact { what: CITY_LOADED or CITY_UNLOADED, cx, cz, count }` per cell in or out - drain it every frame |

**Queries** fill a `CityHits` (`cell`, `row`, `d2`) you keep and clear; `city_building(st, bl, cell, row)` is the record.

| | |
| --- | --- |
| `city_in_cell`, `city_in_rect`, `city_near(st, bl, x, z, r, out)` | buildings by position, in the loaded cells |
| `city_find(st, bl, key, out)` | by id, among the loaded cells. To find a building a save or a property remembers, `city_cell_in` the cell of the position it remembers first |
| `cityhits_nearest(out)` | the nearest hit |
| `city_district_at(st, districts, x, z)` | the first district holding the point (row index), or -1 |
| `city_zoning_at`, `city_crowd_at`, `city_traffic_at` | the zoning (an index into `ZoningRules`) and the ambient pedestrians and traffic, per mille, a point asks for: the district's own number, else its zoning's, 0 outside every district. `ludic.crowd` and `ludic.roads` read these |
| `city_landmarks_near(lm, x, z, out)` | the landmarks whose `radius` holds a point |

**Capacity and head counts.** A building holds what its row says (`residents`, `jobs`, when 0 or more); otherwise, with
`A = floor(w * d) * floors` (`city_floor_area`) and its zoning rule (its `use`, else its `district`, else the district at its
position):

```
residents = A * res_pct / 100 / m2_per_person         jobs = A * (100 - res_pct) / 100 / m2_per_job      (integer divisions)
```

| | |
| --- | --- |
| `city_residents(st, districts, b)`, `city_jobs(...)`, `city_zone_of(...)` | one building |
| `city_homes_near(st, bl, districts, x, z, r, kind, out)`, `city_workplaces_near(...)` | the buildings within `r` with room for residents (or with jobs), nearest found with `cityhits_nearest`; a `kind` (a `ZoningRule.kind`) other than `""` keeps those zoned that way. **This is how `ludic.citizens` reads homes and workplaces**: through a port the game binds to these |
| `city_census_cell(...)`, `city_census(st, bl, districts, map, cx0, cz0, cx1, cz1, out)` | a `CityCensus` (`buildings`, `homes`, `workplaces`, `residents`, `jobs`, `floor_area`) of a cell, or of a range of the map, one cell in memory at a time (a cell already loaded stays; no facts): an offline check that an authored city holds what its designers meant |

**For the renderer, interiors and property.** `city_instances(st, bl, cell, out)` appends a cell's buildings to a
`CityInstances` (`id`, `kit`, `model`, `node`, `x`, `y`, `z`, `yaw`, `scale`, `w`, `d`, `h`, `floors`, `roof`; a kit's model and node stand in
when the row names none), and with the `CITY_LOADED` / `CITY_UNLOADED` facts that is a batch per cell. `city_interior_class(b)`
is 0 none, 1 fake, 2 enterable; `city_entrances(b, out)` the doors (for `ludic.property`: a lot is bought by its `lot` / `address`,
entered by these); `city_kit_of(b)`, `city_height(b)`.

**For physics: colliders, baked** (`colliders.ludic`). What a building stops a body with is its `footprint` polygon (an L, a U, a warehouse with
a lean-to), else the rectangle `w` x `d`, stood up from the row's `y` to its height. It is worked out once, offline: `city_colliders_bake(city_st, bl,
map, maps_root, dir)` cuts every plan into convex pieces (a convex plan is one, a rectangle is one, a concave one is triangulated by ear clipping;
`city_footprint_problem(points)` says what is wrong with a plan that is not a simple polygon, and the bake uses its bounding rectangle with a line
saying so) and writes one file a chunk, `collider_<cx>_<cz>.lwk` (little-endian: magic `LWK1`, version, cx, cz, chunk size, piece count; each
piece: a hash of the building's key, y0, y1, n, then n x, z pairs in metres from the chunk's corner, counter-clockwise). The game only loads
them: `city_colliders_in(cs, dir, cx, cz)` reads a chunk's file and hands each piece to the `CityPhysics` port (`add(CityPiece) -> int`, `remove(int)`),
`city_colliders_out(cs, cx, cz)` takes the chunk's bodies out again; both go in step with `CITY_LOADED` / `CITY_UNLOADED`. The bake is a program of the game's
(it `def`s the registries the rows name; `tests/colliders_test.ludic` is one, on the fixture) run by a person or a `hook before build`.
The binding to ludic.physics is two lines (`phys_prism` makes the convex shape of a piece):

```ludic
# doc-check: skip - a game's glue
function city_add_piece(physics_st: mut PhysicsState, p: CityPiece) -> int {
  return phys_static_add(physics_st, phys_prism(physics_st, p.pts, p.n, p.y0, p.y1), 0.0, 0.0, 0.0, 0.0)
}
function city_drop_piece(physics_st: mut PhysicsState, id: int) -> void { phys_remove(physics_st, id) }
bind CityPhysics { add: fn city_add_piece, remove: fn city_drop_piece }
```

**For the renderer, baked.** The instanced kits and the cell files the large world streams come from the rows by `tools/cells_bake_city.ludic`
(`city_cells_bake`): one kit a (model, node, atlas) so every building of a model shares one mesh, drawn instanced per cell; see ludic.render3d's README,
"Kits and cells from placed things". `tests/cells_bake_test.ludic` runs it on the fixture city. A model and node registered as a box kit (`kitbake_box`) is placed at each
building's own `w` and `d` and its eave, floors times its kit's `floor_h`, the kit's parapet or roof drawn on top.

### The block hash

`city_block_hash(block)` is the number a block's `built_hash` holds once it has been built: the preset's key, the seed, every knob and
the outline, folded through the stream's `hash2` (the same counter and finaliser as `ludic.procgen`'s). Every operation is a
wrapping signed 32-bit integer:

```
mix(z):      z ^= z >>> 16;  z *= 0x85EBCA6B;  z ^= z >>> 13;  z *= 0xC2B2AE35;  z ^= z >>> 16
hash2(a, b): mix(a * 16777619 + mix(b + 0x9E3779B9))
str(h, s):   h = hash2(h, length of s in bytes);  for each byte c of s: h = hash2(h, c);  return h
round(v, k): floor(v * k + 0.5)

h = str(17, preset);  h = hash2(h, seed)
for each knob in order:  h = str(h, name);  h = hash2(h, round(value, 1000));  h = str(h, text)
h = hash2(h, number of outline points)
for each outline point:  h = hash2(h, round(x, 100));  h = hash2(h, round(z, 100))
```

Knob values are authored to the thousandth and points to the centimetre, so a float and a double agree. The asset, node, district
and `built_hash` itself are not in it. `city_block_fresh(block)` is "there is an asset and its `built_hash` is this". The test holds it
to numbers worked out by a second implementation written from this description (`blk_core_1`: -172806178).

`city_block_problem(block)` says what is wrong before a block goes to Blender, or `""`: no preset or an unknown one, a knob the
preset does not have, a value outside its `min` .. `max` (a toggle that is not 0 or 1, a choice past its list), an outline of fewer
than three points. `city_generator_find(key)` is a preset's row.

## Scale

Measured on a synthetic authored city (a scratch generator, not in the repository) over a 16384 m square: 64 x 64 = 4096 chunks,
a downtown of towers, a mid-rise ring, suburbs, farms, four nested districts. On an M-class Mac, one thread:

| | buildings | residents | jobs | census of all 4096 cells |
| --- | --- | --- | --- | --- |
| a plausible city | 88,652 | 639,825 | 656,356 | 116 ms |
| a stress set (dense everywhere) | 382,080 | 3.3 M | 3.2 M | 795 ms |

Streaming one cell boundary (three cells out, three in; up to 300 buildings a cell) took 80 to 330 microseconds; `city_near` within
60 m and `city_homes_near` under a microsecond over the 3 x 3 loaded cells; `city_district_at` 6 ns with four districts. The whole
test process peaked at 140 MB. The cost is reading the files (about 2 microseconds a building), so the rule is to stream with
`city_stream_step` and let the facts drive instancing; a `city_stream` over a long jump (a teleport) loads a whole window at once.

Scans are linear in the loaded cells' rows and the districts: hundreds of buildings a cell and tens of districts are nothing; a
map with thousands of district polygons wants the spatial index in "v2".

## Tests

`ludic test packages/ludic.city`, on `tests/maps/metro` (five districts including an overlap and a negative-coordinate one, six
chunks of buildings with every kind of row - kits, generated assets, `use` and `district` overrides, explicit head counts, doors, both
interior classes - four blocks, two landmarks) and the zoning, kits, presets and atlases beside it.

## v2

A spatial index for the districts and a per-cell grid for near queries; the studio's Blender round trip as a tool the package
names (the row shape is here; the launching is the studio's); a `ludic.citizens` port bound to these queries in the package that owns it;
parking, sidewalks and props as rows a block carries; level-of-detail names for a building's far model; a save section for which
buildings a player has changed at run time (owned, damaged), keyed by the stable id.
