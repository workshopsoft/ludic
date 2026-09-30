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
