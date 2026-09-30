# ludic.render3d

A physically based 3D renderer over Vulkan. `FEATURES.md` lists what is implemented and where.

## Painted ground layers

A ground layer is a density painted over the map (R the chance a cell keeps one, G its scale, 2 m texels
baked into an LGD2 file, `ground_density.ludic`) and a `GroundFill` row of numbers. Everything it grows is
a pure function of those two - the same on every machine and in the editor's preview.

- **The candidate** (`ground_cand.ludic`): for (layer, chunk, band, cell) `ground_candidate` answers
  whether one stands there and its x, z, scale, yaw, seed and wind, into a `GroundCand` the caller holds.
  Its steps are pure: `gf_along` (the jitter, draws 0 and 1), `gf_keeps` (draw 2 under the chance),
  `gf_scale` (G and draw 6), `gf_yaw` (3), `gf_seed` (4), `gf_wind` (5). `ground_fill` draws exactly
  these. Numbers are IEEE single precision, `Math.lerp` is `a + (b - a) * t`, `gf_hash` is 32-bit
  integer arithmetic with a logical `>>`, and the model shader turns local (x, z) to
  `(c x + s z, -s x + c z)` - three.js's rotation about +Y.
- **Cover and solid.** A cover layer (grass, flowers, pebbles) is filled at its band's step, so a far
  band is a different, sparser sample. A layer with `solid: true` (rocks, trees) is filled at `step0`
  with band 0's hashes whatever the band, and a far band draws the subset whose draw 7 falls under
  `(step0 / step_band)^2`; its scale ignores `band_grow`. Nothing solid moves with the camera.
- **Solid ids** (`ground_solid.ludic`): `ground_solid_id(layer, cx, cz, i, j, cells)` =
  `((layer * 256 + cz + 128) * 256 + cx + 128) * 512 + i * cells + j`, a positive 31-bit int, stable
  while the painting under it is. It holds chunks -128 .. 127 about the stream's corner and at most 22
  cells a chunk side (a step of at least 32 / 22 m on 32 m chunks); a cell past that has no id and is
  not grown. `ground_solid_list` fills a caller's `GroundSolids` (made once, `ground_solids_new`) with a
  chunk's things for physics, the nav bake or a save; `ground_solid_at` answers one by id.
- **The trample as data** (`ground_clear.ludic`): `r3d_ground_clearing(x, z, r_in, r_out, floor)` hands
  over a clearing - `floor` inside `r_in`, back to full at `r_out` on a smoothstep, the shape of the
  camp's ring and the town's yard. A layer with `trample` multiplies its chance by the game's callback
  (`r3d_on_ground_trample`, kept for now) and then by every clearing. A game should use one or the other.
- **The layers as a map's data** (`ground_layers.ludic`): one row a layer in the map's own
  `assets/maps/<map>/ground_layers.lres` (a `@PerMap` registry, `GroundLayers`, loaded with
  `ground_layers_load(layers, map)`): the painted `density` image (`@Asset("png", map)`), its `texel`, what
  grows (`kind`, a row of the open `GroundKinds`: a model and a node) and the numbers of a `GroundFill`
  by the same names, plus `foot` and the bands' radii. `ground_layer_fill(out, row, index)` writes the
  `GroundFill` a row means (its `layer` is the row's own or its place), `ground_layers_fills(layers)` makes
  the list once at map open. A game that builds each `GroundFill` by hand still can; that is the older
  way. A game's own registry named `GroundLayers` or `WaterBodies` collides with these and is dropped for
  the package's (its record is a superset).
- **Still water as a map's data** (`water_bodies.ludic`): one row a plane in `water.lres` (`WaterBodies`,
  `@PerMap`): `level`, the bounds as a centre `cx`, `cz` and half extents `ex`, `ez`, and `reflect` (only
  the first reflecting plane is mirrored). `water_bodies_apply(render3d_st, bodies)` replaces the
  renderer's water with the rows (8 at most) and answers how many it took; `water_init` for one reflecting
  plane is the older way.
- **Conformance**: `tests/ground_fill_test.ludic` holds the package to `tests/ground_fill_golden.json`
  (gf_hash, lerp, yaw, one cover chunk and one solid chunk over a hand-written density), which the
  studio's own test reads. After a deliberate change, rebuild it from the repository root:
  `bin/ludic run packages/ludic.render3d/tests/gen/ground_fill_golden.ludic --headless`, and commit it.

## Models: glTF and GLB

`gltf_load(st, dir, file, node)` (and `gltf_cached`) reads one named node's mesh from a **`.gltf` with its one external `.bin`, or from a
binary `.glb`** - the studio's Blender generators export `.glb`, and a row's `@Asset("gltf")` names either. The two are told apart by the
file's first bytes (the magic `glTF`), not its name. A `.glb` is the 12-byte header, the JSON chunk and the BIN chunk (`glb.ludic`:
`glb_scan` finds the two without reading them); the JSON is the document and the accessors read only the byte ranges they need from
the BIN chunk, exactly as from a `.bin`. A header of another version, a chunk that overruns the file or a file with no BIN chunk is
refused with a line saying so. Textures stay files beside the model (`images[].uri`); an image inside the BIN chunk is not read.
`gltf_open(st, dir, file)` (the document and its binary, for a reader that wants the accessors: `tests/glb_test.ludic` holds a triangle as
`tri.gltf` + `tri.bin` and as `tri.glb` to the same answers) and `gltf_bin_reopen(st, dir)` (`ludic.anim` reads its clips through it, so a
`.glb` animates too).

## Large worlds: a city of hundreds of thousands of buildings on a 16 km map

Everything here is game-agnostic: it knows cells, kits and transforms, not what a game puts in them. The logic that needs no
device (`bigworld.ludic`, imported by `r3d.ludic`) is tested on its own, with no window; the GPU halves (`kgpu`, `hlod_gpu`,
`oimp_gpu`, `imi_gpu`, `bigworld_gpu`) are compile-checked here and their shaders validated by `ludic-dev shaders`. A number
is a float under `numbers float`, so **a `double` literal in such a file is rounded to a float first**: build a world
coordinate from integers (`double(40000123) / 1000.0`) or from a computation, never from a decimal literal.

| capability | files | tests |
| --- | --- | --- |
| floating origin, `CellPos` | `forg.ludic` | `tests/forg_test.ludic` |
| world partition row, cell streaming scheduler | `wpart.ludic`, `wstream.ludic` | `tests/wstream_test.ludic` |
| cell files, index, building kits | `cellfile.ludic` | `tests/cellfile_test.ludic` |
| kits and cells baked from placed things (a city's buildings) | `kitbake.ludic`, `packages/ludic.city/tools/cells_bake_city.ludic` | `tests/kitbake_test.ludic`, `packages/ludic.city/tests/cells_bake_test.ludic` |
| the ground from the studio's height tiles: data, bake, stream, draw | `tilemap.ludic`, `tilemap_bake.ludic`, `tilemap_lwt.ludic`, `tilemap_draw.ludic`, `tools/terrain_bake.ludic` | `tests/tilemap_test.ludic` |
| HLOD bake (+ tool) | `hlod.ludic`, `tools/hlod_bake.ludic`, `hlod_gpu.ludic` | `tests/hlod_test.ludic` |
| instancing: culling, binning, budgets | `kinst.ludic` (CPU), `kgpu.ludic` + `kinst_*.comp` (GPU), `karena.ludic` | `tests/kinst_test.ludic`, `tests/karena_test.ludic`, `tests/bigworld_gpu_test.ludic` |
| stress benchmarks | `bench/kinst_stress.ludic`, `bench/kgpu_stress.ludic` | (run by a person) |
| octahedral impostors | `oimp.ludic`, `oimp_gpu.ludic`, `oimp.vert/.frag` | `tests/oimp_test.ludic` |
| fake interiors (interior mapping) | `interior_atlas.ludic`, `imi.ludic`, `imi_gpu.ludic`, `kit.frag` (`INTERIOR_MAP`) | `tests/imi_test.ludic` |
| real interiors: portals and rooms | `portal.ludic` | `tests/portal_test.ludic` |
| multi-map and instanced interiors | `intr.ludic` | `tests/intr_test.ludic` |
| the whole as one object | `bigworld_gpu.ludic` (`BigWorld`) | compile-checked |

### Large coordinates (`forg.ludic`)

A float is good to a millimetre at 8 km and to two at 16, and the view matrix loses the same bits, so walls shimmer and wheels
swim. Nothing the GPU sees may be a large number.

- **World space** is `double` (sub-micron at 100 km): the game's saves, physics and AI. **Render space** is `float`, relative
  to a `ForgOrigin`: `render = world - origin`. Everything the renderer draws (`cam_set`, instances, stream corners, actors) is in render space.
- `forg_new(grid, threshold)`: the origin is always a multiple of `grid` (raised to a power of two, 256 m by default);
  `forg_update(o, cx, cy, cz)` (the camera's world position, every frame) moves it to the camera's nearest grid point when
  the camera is more than `threshold` (1024 m; raised to at least twice the grid) from it, and answers true when it did. The
  shift (`o.shift_x/y/z`, exact) is what every render-space number moved by: `new = old - shift`, **bit for bit** where the float holds it
  (the subtraction of two doubles near the origin is exact). `o.serial` changes at every rebase, for caches keyed on it.
- No jitter: a rebase changes no number by more than the shift, and the threshold exceeds the grid, so a camera pacing a boundary
  never rebases twice (hysteresis). Height rebases only past `vthreshold` (4096 m), so a driving game never does.
- Convert with `forg_rx/ry/rz(o, world)` and back with `forg_wx/wy/wz(o, render)`; `forg_to_render` writes three floats.
  `forg_reset(o, x, y, z)` for a teleport or a map load (no shift, no callback). `forg_on(o, f)` registers `f(dx, dy, dz)`
  to run after each rebase, and `forg_shift_floats(a, n, stride, dx, dy, dz)` applies a shift to `n` records' first three floats.
- `CellPos` is the other form: an integer cell plus a float offset (`cellpos_from_world`, `cellpos_add`, `cellpos_sub`): exact
  to add across cells, precision that does not degrade with distance. Cell content is stored that way (below).
- **What follows the origin.** The big world's own data does (cell tables, kits, HLOD, interior instances: one offset each, no
  records rewritten). What a game keeps in render space itself (actors, scatter layers, stream corners `Stream.ox/oz`,
  `ter_ox/ter_oz`) must be shifted by `o.shift_*` in the frame `bw.rebased` (or `forg_update`) says so. The baked terrain is still one
  8 km tile (`TERRAIN_HALF`); a map larger than that draws its ground from tiles ("Terrain from the studio's tiles" below).

### World partition and streaming (`wpart.ludic`, `wstream.ludic`, `cellfile.ludic`, `hlod.ludic`)

The map is a grid of square cells. Their size and the streaming numbers are data, one row of the map's
`world_partition.lres` (`WorldPartitions`, `@PerMap`, loaded with `world_partitions_load(wp, map)`):

```text
city { cell_size: 256.0, full_radius: 900.0, hlod_radius: 4000.0, margin: 48.0,
       load_ms: 2.0, memory_mb: 768, max_jobs: 4 }
```

**Per-cell content (the contract for whatever generates the city).** For each cell that has anything in it, write
`<dir>/cell_<cx>_<cz>.lwc` (`cell_save(dir, content)`) and, once, `<dir>/cells.lwi` (`cell_index_save`). Build a cell with
`cell_content_new(cx, cz, size, cap)` and `cell_add(c, kit, x, y, z, yaw, scale, tint, variation, flags)`:

- `cx`, `cz`: the cell, `floor(world / size)`; **positions are relative to the cell's corner** (`x`, `z` in metres; `y` is the height
  itself), so they are exact floats however far the cell is. World position = `cx * size + x`, in double (`cell_world_x`).
- `kit`: the id of a kit = its row's index in the map's `render_kits.lres` (`RenderKits`, `@PerMap`; rows only ever appended):
  `model` and `node` (a glTF), `w`, `d`, `h` (the footprint and height in metres, origin at the footprint's middle on the ground),
  `near` and `far` (mesh inside `near`, impostor card to `far`, nothing past it), `impostor`, `proxy_r/g/b` (the colour of its HLOD box),
  `interior` (the key of an `InteriorAtlases` row for its windows) and `win_w`, `win_h` (the window cell in metres), `casts_shadow`.
- `yaw` in radians, turned as the renderer turns an instance (`x' = c x + s z`, `z' = -s x + c z`); `scale` uniform.
- `tint`: RGBA8 (`cell_rgba(r, g, b, a)`), multiplied into the albedo; `variation` (0 .. 65535): seeds the per-instance
  shade and, for a building with windows, **which room each window shows** (`imi.ludic`). Same variation, same rooms.
- `flags`: the game's own bits, carried through to the instance record untouched (`instance[7]`).

`cells.lwi` lists each cell with its content size and its proxy's size; `cell_index_register(ix, sched)` feeds the scheduler.

**The scheduler** (`WStream`) says which cells should be in memory, at which of two layers, in what order, under what budgets.
It is pure: the game does the loading and tells it what it cost.

- Layers: **HLOD** (the merged far proxy) wanted within `hlod_r` of the camera, **FULL** (the real instances) within `full_r`. A cell shows FULL
  if it has it, else HLOD: loading FULL never frees HLOD until it is in, dropping FULL leaves HLOD under it. A layer is kept `margin` past
  its radius (hysteresis), so pacing a radius loads and drops nothing.
  So far buildings are layered by distance: inside `full_radius` a cell's instances draw as the mesh (to each kit's `near`) and then as impostor cards (to its
  `far`, capped by the cell being FULL); past it the cell is its HLOD proxy boxes out to `hlod_radius`; past that, nothing.
- A frame: `ws_begin_frame(s, budget_us)`, `ws_update(s, x, z, fwd_x, fwd_z)` (cheap when the camera sat still), then `ws_next_job(s)` until -1
  (each is `slot * 4 + layer`: start the load, then `ws_job_done(s, slot, layer, cost_us)` now or on a later frame, or `ws_job_fail`), then
  `ws_next_drop(s)` until -1 (release that layer). Or all at once: `ws_run(s, load_fn, drop_fn)`.
- Order: nearest first, a cell ahead of the camera `bias` metres nearer, FULL before proxies. Budgets: `load_us` a frame (estimated from
  bytes times the measured cost per byte, refined by every finished job; the first job of a frame is always allowed, a job is never split),
  `mem_bytes` over everything resident or loading (a nearer cell may evict a farther resident layer to fit, never the reverse), `max_jobs` in flight.
- `ws_pin` holds a cell loaded whatever the distance; `ws_hold(s, true)` freezes streaming (an interior is open).

**HLOD.** `hlod_bake(content, kits, cluster_m, height_band, max_growth, out)` turns a cell into a merged proxy: each building a box
(footprint x height, yaw, scale), buildings grouped by a ground grid of `cluster_m` metres *and* a height band, each group of two or more
replaced by one box if it is not more than `max_growth` times the volume of what it replaces; no bottom faces (five faces a box,
7 floats a vertex: position, normal, RGBA8 colour in the float's bits). The bake is **a person's task**, not a frame's:

```text
ludic build packages/ludic.render3d/tools/hlod_bake.ludic
./build/hlod_bake <map> <cells_dir> <out_dir> [cluster_m=32] [height_band=12] [max_growth=4]
```

It reads the content files and writes `cell_<cx>_<cz>.lwh` beside an updated `cells.lwi`; no window, no device. `tests/hlod_test.ludic`
runs the same code on small inputs (faces wound outward, yaw as the renderer turns it, a merged box contains what it replaces, determinism,
files round-trip and refuse damage). `hlod_gpu.ludic` uploads a proxy (one mesh a cell, drawn with the cell's render-space offset as a
uniform by `hlod.vert/.frag`).

### Instancing at scale (`kinst.ludic`, `kgpu.ludic`, `karena.ludic`)

An instance is 12 floats (three vec4s): `x y z scale | sin cos seed flags | tint.rgb variation`. The same layout is what the vertex
stage (`kit.vert`) reads, what the CPU culler lists and what the GPU pass writes.

- **CPU** (`KCull`): `kinst_add_cell` when the scheduler loads a FULL layer, `kinst_remove_cell` when it drops it. `kinst_begin(k, view_proj, cam)`
  then `kinst_cull(k)`: cells are culled **whole** by their box against the six frustum planes and the far distance, then the instances of the cells
  that remain by distance and a sphere-vs-planes test; survivors are copied, in render space, into one list per (kit, level): 0 the mesh (inside `near`),
  1 the impostor card (to `far`). `kinst_rebase` follows the floating origin. Budgets: `max_per_bin` caps a list (excess counted in `overflow`), and
  `kinst_adapt(k, target_visible, step)` moves a distance scale (0.25 .. 1) toward a target, with a dead band, so a busy street shows a bit less
  far, smoothly, rather than hitching. `kinst_hide` hides a cell (a room the portals cannot see).
- **GPU** (`KGpu`): every resident cell's instances sit in one arena buffer (16 floats each, ranges from `karena.ludic`: first fit, neighbours merged, a
  freed range held three frames so a frame in flight is never overwritten). `kgpu_frame` runs, before the frame's first pass, `kinst_reset.comp`,
  `kinst_cull.comp` (count), `kinst_args.comp` (an exclusive scan of the per-bin counts, clamped to the output buffer, and the indirect draw records) and
  `kinst_cull.comp` again (scatter): one invocation an instance, so 500 000 instances are 7 800 workgroups twice, where the older `scatter_cull.comp` walks
  its list in one thread. Survivors are packed per (kit, level) in render space. The draw is one indirect call a material of each kit's mesh and one for its
  card: no CPU work grows with the instance count. `cpu_only: true` builds the same draws over lists from `kinst_cull` (`kgpu_draw_lists`).
- Registration: `r3d_on_prepare(st, fn prepare)` (new; runs before the frame's first pass, where a compute dispatch may not split one) calls `kgpu_frame`;
  `r3d_on_draw` calls `kgpu_draw`; `r3d_on_casters` calls `kgpu_draw_casters`. A kit's `Model` is its own: its meshes take this file's instance layout, so
  load a model again for a scatter layer.
- **Stress.** `bench/kinst_stress.ludic` (CPU culling alone, no window; `KB_INSTANCES=500000 KB_FRAMES=600 KB_TARGET=0|n KB_SPEED=m/s`) and
  `bench/kgpu_stress.ludic` (`ludic build ... --headless`, the GPU pass and draws offscreen on a plate; also `KB_IMPOSTOR=1`) fly a camera through a
  500 000-building city and print the frame time average, median, 99th percentile and worst, printing `STRESS OK` when the 99th percentile is within three
  times the median. Nothing runs them for you: a run is heavy on a shared machine.

### Impostors for far buildings (`oimp.ludic`, `oimp.vert/.frag`, `oimp_gpu.ludic`)

A kit past its `near` distance is one card that faces the camera and shows a photograph from the direction the camera looks from. The photographs are
an n x n atlas of frames laid out by the **hemi-octahedral map** of the viewing direction (`oimp_encode/decode`): neighbouring frames are neighbouring
directions, and any direction has three frames around it, blended by barycentric weights (`oimp_pick`), each read at the card's point *as that frame's own
orthographic view sees it* (`oimp_basis`, `oimp_project`) so edges stay put as the camera swings. The instance's yaw is turned out of the view direction
first (`oimp_local_dir`), so one atlas serves every turn. `kgpu_bake_kit` renders the frames (n x n orthographic views of the kit's model through
`kit.vert` + `bake.frag`, MRT: albedo with coverage, model-frame normal with occlusion): **a person's click, once a kit**. No mips yet (v2). The atlas costs
`oimp_bytes(n, frame_px)`, e.g. 8 x 8 frames of 128 px = 8 MB a kit. Far shadows are not cast by cards.

### Fake interiors: interior mapping (`interior_atlas.ludic`, `imi.ludic`, `kit.frag`)

Behind each window of a facade the shader ray-marches a box room and paints it from an atlas: no geometry. A kit opts in by naming an atlas row
(`RenderKit.interior`), which selects the `INTERIOR_MAP` program variant: that variant *is* the material flag.

- **Data**: `InteriorAtlases` (open registry, the game's `def InteriorAtlases from "interior_atlases.lres"`): `image` (`@Asset("png")`), `cols` x `rows`
  room tiles, `rooms` painted, `depth` (m), `night_lit` (the share of rooms lit at full night), `lit_gain`, `dark_gain`, `lit_r/g/b`, `frame`, `curtain`.
  A tile holds six faces in a 3 x 2 block: `left | back | right` over `ceiling | floor | (spare)`; left and right run far to near (u) and up (v), the
  back across and up, ceiling and floor across (u) and far to near (v). Painted in daylight; the shader turns the lights on at night.
- **The facade** is measured in the **model's own frame** (so nothing moves when the origin does, and a turned or scaled instance carries its windows):
  the wall is cut into cells of `win_w` x `win_h`, the middle of each (inside `frame` on every side) is glass, the room is `win_w` wide, `win_h` high,
  `depth` deep. Walls are the four axis-aligned ones; roofs and oblique walls are left alone.
- **Which room** (`imi_room`): a PCG hash of the instance's variation, the wall and the window's cell: deterministic, even over a facade, neighbours
  differ. **Lights** (`imi_lit`, `imi_night`): a window's own roll `r < night * night_lit`, with night from the sun's height (`u_sun_dir.y`), so rooms switch
  on one by one through dusk and stay on; by day a room shows its look under the sky's light. The glass is a dark glossy dielectric (sky and sun reflect in
  it); what is behind shows by what it does not reflect. `imi_hit` and `imi_atlas_uv` are the reference of the ray-box and the atlas lookup; the hash has
  golden values from an independent 32-bit implementation in `tests/imi_test.ludic`.

### Real interiors: rooms and portals (`portal.ludic`)

An interior is a graph: rooms (boxes) and portals (quads between two rooms, open or shut; room -1 is outdoors). `pg_visible(g, cam, view_planes, start_room,
max_depth, vis)` walks it from the camera's room (`pg_room_at`) with a frustum that narrows at every portal it passes (the portal must face the camera
from the entering side, touch the frustum so far, and the next frustum is the old planes plus one through the camera and each edge of the portal). A room is visible if
any path reaches it: conservative, never dropping a room that could be seen. From outside (`start = -1`) it enters through the open portals to the exterior. The verdict
drives the culler: each room's things are a cell whose slot is `base + room`, and `pg_apply` (`KCull`) / `pg_apply_gpu` (`KGpu`) hide the rest. An interior map
supplies its rooms and doors as data (`interior_rooms.lres`, `interior_doors.lres`: `InteriorRooms`, `InteriorDoors`, `@PerMap`), built into a graph by `intr_graph_build`.

### Multi-map and instanced interiors (`intr.ludic`)

**The contract with `ludic.property` (or any game system):** *it* decides which interior and which instance; it calls
`intr_enter(m, def, owner_id, ret_x, ret_y, ret_z, ret_yaw, custom, sx, sy, sz, syaw)` with the interior's index (`intr_def_find(m, key)`) and the owner's id
(any int: a property, a party, a mission). `intr_exit(m)` goes back. Everything else is here.

- `InteriorDefs` (open registry, `def InteriorDefs from "interiors.lres"`): `map` (the interior's own map directory), `max_instances`, `size`, `fade_out`,
  `fade_in`, `keep` (seconds its content stays loaded after the last person leaves), `spawn_x/y/z/yaw` in the interior's own frame.
- **Instances**: one (def, owner) each, in a slot; the origin of slot *g* is on a grid `spacing` metres apart from `(zone_x, zone_z)` far from the city, so
  every instance has a place of its own and two are never on top of each other; the content is loaded **once per def** however many instances exist (an instance is an
  origin, not a copy: `intr_rehome(m, inst, content)` puts the content at that origin exactly). The same owner gets the same instance back. When a def's slots are
  full the least recently used instance nobody is in is evicted (event `IE_EVICT`); `INTR_FULL` when everybody is in one.
- **Transition** (`intr_update(m, dt)` each frame, `intr_next_event(m)` drained): fade out, `IE_LOAD_DEF` (once) until the game answers `intr_def_loaded` (or
  `intr_def_failed`, which puts the player back), `IE_HOLD`, `IE_SPAWN` (screen black: move the player and camera to the event's world `x, y, z` and `yaw`, and `forg_reset` there), fade in,
  `IE_ENTERED`; going out: `IE_RELEASE`, `IE_SPAWN` at the door outside, `IE_EXITED`. `intr_fade(m)` is 0 (clear) .. 1 (black) for the overlay. `intr_bind_stream(m, sched)`
  holds the city's scheduler while inside. `intr_ref(m, inst, +1/-1)` is a friend who joined (the def stays loaded for them); `intr_release(m, def, owner)` ends an owner's lease.
- A door from one interior into another keeps the way back to the street.

### `BigWorld` (`bigworld_gpu.ludic`)

`bw_open(st, dir, row, kits.rows, use_gpu, assets_dir, max_instances)`, `bw_setup_kits(st, bw, impostor_n, frame_px)` (models, impostor frames, interior atlases: a person's
load), then each frame `bw_frame(st, bw, wx, wy, wz, yaw, pitch, load_us)` with the camera's **world** position; `bw_prepare` in `r3d_on_prepare`, `bw_draw` in `r3d_on_draw`,
`bw_draw_casters` in `r3d_on_casters`. It owns the origin, scheduler, cell files, instancer and proxies and does the loads within the budget.

### Kits and cells from placed things (`kitbake.ludic`)

Everything the large world draws is **baked**, not made in play: the game loads files and rows. `kitbake.ludic` is the bake of the first
two: from a list of placements it writes the map's `RenderKits` rows (**one kit for each model, node and interior atlas**, so every
building that names the same model shares one mesh, drawn instanced by its cell) and the cell files and index `bw_open` reads.

```text
let kb = kitbake_new(256.0)                       # the map's WorldPartition.cell_size
kitbake_seed(kb, kits.rows)                       # rows already written keep their ids: kits are only ever appended
let id = kitbake_kit(kb, "city/block_3.glb", "tower_a", 30.0, 30.0, 120.0, "")     # model, node, footprint w, d, height, atlas
kitbake_place(kb, id, x, y, z, yaw_radians, 1.0, cell_rgba(255, 255, 255, 255), variation, flags)
kitbake_write(kb, "assets/maps/meridian/cells")   # cells.lwi and cell_<cx>_<cz>.lwc
Fs.write_text("assets/maps/meridian/render_kits.lres", kitbake_rows(kb, 0))        # or kitbake_rows(kb, kb.seeded) to append
```

It knows nothing of what placed the things. ludic.city's rows go through `packages/ludic.city/tools/cells_bake_city.ludic`
(`city_cells_bake`: every `Buildings` row that has a model, its own or its kit's; interior class in the cell's flags, the row's `atlas`
on the kit, a hash of the key for the variation), a program of the game's own that `def`s the registries the rows name; its
example and test is `packages/ludic.city/tests/cells_bake_test.ludic` on the fixture city: 72 buildings in 6 kits, the culler drawing them
as one list a kit. A kit's `near`, `far`, `w`, `d`, `h` and the window cell are the row's to edit afterwards (the studio's RenderKits
table): a re-bake keeps the rows and appends only new kits. A model's node must have its origin at the middle of its footprint, on the
ground. The far layers are baked after it: `tools/hlod_bake.ludic` (the merged proxy of every cell) and, a person's click, a kit's
impostor atlas (`kgpu_bake_kit`).

The order is: rows change, then `city_cells_bake`, then `hlod_bake`; the game's `package.ludic` can run them as `hook before build`.

### Terrain from the studio's tiles (`tilemap.ludic`, `tilemap_draw.ludic`)

The studio writes a map's ground as 16-bit greyscale PNG tiles (`world_create`, `terrain_sculpt`); the map's row says how. One
`TileMap` is that row's numbers, passed as the row's fields (the names are the studio's `world_create` scaffold and the game's
studio.lres binding: `tiles`, `tile_size`, `tile_res`, `tile_cols`, `tile_rows`, `origin_x`, `origin_z`, `height_min`, `height_max`, and
the `height_offset` a binding may have):

```text
let tm = tmap_new(m.tiles, m.tile_size, m.tile_res, m.tile_cols, m.tile_rows, m.origin_x, m.origin_z, m.height_min, m.height_max, 0.0, 300.0)
```

The layout: tile (tx, tz) is the file `tiles` with `{tx}` and `{tz}` filled in; it covers x in `origin_x + tx * tile_size` for `tile_size`
metres (z likewise), `tile_res` samples a side and none shared with a neighbour; sample (i, j) is along +x and +z, **image row 0 is the low
z**, its centre at `origin + (tile * res + i + 0.5) * texel`; `height = offset + height_min + raw / 65535 * (height_max - height_min)`.
Between texel centres the ground is bilinear, across a tile's edge as well; past the map it holds the edge texel; a tile with no file (or
not a `res` x `res` 16-bit grey PNG) is flat at `offset + height_min`, known once, never asked for again. No size is fixed in code.

**The ground as data** (no device): `tmap_stream(st, tm, x, z, radius, budget)` once a frame loads the tiles within `radius` nearest first
(`budget` a frame; a tile is 2 bytes a texel, in a pool sized for `radius`, the least recently wanted let go) and `tmap_ensure` loads them
all now (a spawn, a teleport). Then `tmap_height(tm, x, z)` is the port everything asks - allocation free, pure, what is not loaded is flat
and `tmap_ready` says so; `tmap_height_sync` loads what it needs first; `tmap_normal`, `tmap_slope`. **Physics**: `tmap_field(tm, h, n, ox, oz,
cell, PHYS_HOLE)` fills the `n x n` array `phys_heightfield` takes, with a hole where a tile is not loaded:

```text
function ground_h(x: float, z: float) -> float { return tmap_height(game_tm, x, z) }        # bind CharacterGround.height to it
let holes = tmap_field(game_tm, h, 33, ox, oz, 2.0, PHYS_HOLE)                            # a 64 m chunk of ground
if holes == 0 { phys_ground_add(physics_st, phys_heightfield(physics_st, h, 33, ox, oz, 2.0)) }
```

**The ground drawn is baked** (levels of detail are a bake, never made in play). `tools/terrain_bake.ludic` cuts every tile into
patches (`patch_texels` texels, 128 by default) and every patch into levels (each halves the cells, down to 4), samples heights where
`tmap_height` reads the ground and normals one cell apart, and writes one `.lwt` file a tile beside the PNG (`tiles` with `.lwt`, or the
row's own `tile_mesh` pattern): quantized heights (16 bits over the row's range) and normals, the format of `tilemap_lwt.ludic`, its
header holding the row's numbers so a file baked for other numbers is refused, never drawn wrong. Run it by hand or as a
`package.ludic` `hook before build` (the arguments are the row's fields):

```text
ludic build packages/ludic.render3d/tools/terrain_bake.ludic
./build/terrain_bake "assets/maps/meridian/terrain/{tx}_{tz}.png" 1024 512 16 16 -8192 -8192 -40 600
```

Then `tilemap_draw.ludic`: `tmd_new(st, tm, radius)` and, each frame, `tmd_frame(st, td, cam_x, cam_z, origin_x, origin_z, radius)`: tile tables
are read a frame within budget, the patches inside `radius` are read and uploaded nearest first (`build_budget` a frame) at the level their
distance asks (`tm.lod_dist` doubling each level, with hysteresis), each an `Actor` so the renderer's own model pass lights, shadows and fogs
it (set `td.color`, `td.rough`; `r3d_plate_mode(st, true)` for the sky and sun without the old 8 km terrain), a skirt under every edge hides
the cracks between levels, the actors follow the floating origin. A frame allocates nothing but the mesh and model a patch's new level
needs. It is tested with no device (`tests/tilemap_test.ludic`: layout, bilinear across edges, streaming, pool, heights for physics, the
bake, the file's checks, the levels agreeing on shared vertices) and looked at on a lab plate.

### What is still made at load, and is a gap

The impostor atlas of a kit is rendered on the device by `bw_setup_kits` (`kgpu_bake_kit`) unless a bake file is named
(`impostor_from_baked`, `bake_load.ludic`); the window atlases of `imi_load` and the shadow and IBL textures are likewise made at
start by the older paths. Those are the renderer's own bakes, not content, and stay until they are moved to a build step of their own.

### Not yet (v2)

Ground streams that follow a rebasing origin; impostor atlases with mips and cards that cast shadows; a depth-corrected impostor (parallax);
mesh LOD chains per kit (`layer_set_lods` has them for vegetation; kits go mesh to card); occlusion culling of the city by the depth buffer (only portals inside buildings);
multi-player instance visibility beyond `intr_ref`; HLOD with merged textures and a window/roof texture instead of banding.
