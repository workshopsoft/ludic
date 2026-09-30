bump: minor
type: feat
**`ludic.render3d`: painted ground layers grow solid things, with ids, and the trample is data.**
`ground_fill`'s candidate is its own function, `ground_candidate` (pure `gf_*` steps with the density read
between them, into a caller-held `GroundCand`), and `ground_fill` draws exactly its answers - the same
operations in the same order as before, so every cover layer grows bit for bit what it did. A layer with
`solid: true` is filled at `step0` with band 0's hashes whatever the camera, a far band drawing a stable
subset; each thing has an int id from (layer, chunk, cell) (`ground_solid_id`), and `ground_solid_list` /
`ground_solid_at` answer a chunk's things or one by id for physics, the nav bake and saves.
`r3d_ground_clearing(x, z, r_in, r_out, floor)` hands the trample over as discs the editor can see, beside
the `r3d_on_ground_trample` callback, which still works. `tests/ground_fill_test.ludic` holds all of it to
`tests/ground_fill_golden.json` (written by `tests/gen/ground_fill_golden.ludic`), the file the studio's
TypeScript generator is tested against.
