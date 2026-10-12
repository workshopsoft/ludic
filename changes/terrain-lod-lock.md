bump: minor
type: feat
**Terrain LOD lock: coarse levels no longer move roads, pads and shores.** `terrain_bake` takes a comma-separated list
of land-use classes to lock and a tolerance (`... [patch_texels] "3,4,5,1" [mask] [tol]`, default 5 mm;
`tmb_lock_new` in `tilemap_bake.ludic`). A coarse patch level whose triangles would move a locked texel by more than the
tolerance is cut down to level 0's cells along the locked ground, graded 2:1 so it has no slivers, and stored as a
locked mesh. Every other level, and any bake with no lock or no mask, is written byte for byte as before.

**Breaking (file format):** a tile with a locked level is written as **LWT version 2** (level kind 1, a locked mesh);
older readers refuse it. Version 1 tiles read unchanged. Rebuild the tools and rebake terrain with the lock to use it.
