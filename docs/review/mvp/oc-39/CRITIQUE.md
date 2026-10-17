# Sea surface (render3d, gpp lab fixture `sea`)

Shots: `coast_pairs_*.png` (six coast bookmarks, noon | dusk), `before_after.png` (old plane | sea), `noon_*.png`, `dusk_horizon.png`.
Measured: `sea_check.txt` (27 checks, 0 failed), `gpu_time.txt`. Reproduce: `packages/ludic.render3d/lab/sea_lab.ludic`, then
`lab/sea_check.py build/lab` and `lab/sea_proof.py build/lab <dir>` (these sheets), `lab/sea_budget.py <lab binary>` (the time).

What reads well
- The shore: a white swash line at the waterline, lace out to a metre of depth, nothing beyond; it follows a meandering 4 % beach,
  a cliff, a quay wall, a rock, a shoal and a river mouth, and stops dead at the dry platform and the dock (no foam, no water).
- The sea is one calm colour that deepens with depth and is the same over the map's edge as over its bed (no edge in the
  shoal shot); the horizon is a clean line with no step in the rows under it, from the map's corner as well.
- A river mesh meeting the sea at one height wins every pixel (planes sit a hair behind): no fight in the mouth.

What does not, and why it is left
- The swell is soft, not sharp: it is read from two tiling textures (256 m and 16 m) at the mip a pixel can resolve, so what a far
  swell has is a darkening and brightening of the blue and no crest line, and the near ripples show only within 30-50 m. No stripes
  now (the long swells were parallel streaks at middle distance in the noon shots: the new tiles' waves come from a cone of
  directions), and no repeat of the tile is visible in the shots (the long tile is read twice, the second turned and stretched). The
  swell does not travel the way waves do (the tiles slide), which a calm sea hides.
- The lab's ground is one tint per land-use class and blurs at the edges (the lab's own render path); judge the water, not the sand.
  A faint vertical line in the cliff shot is that ground's patch edge (it is there with no water drawn).
- Foam is paler than the lit sand by little in the tone-mapped frame (the sand is already bright); its texture, not its
  brightness, separates it (the measured check uses that).
- Cost: see gpu_time.txt. Three times cheaper than the first sea: 0.47 ms with the sea filling the frame, 0.27 at the horizon and 0.45 at
  the beach on an M4 Pro. The contract's 1.0 ms is for an M1, about 3 times slower than this machine (0.33 ms here): MET for the
  horizon and the land views, NOT MET for the beach and a full-frame sea (about 1.4-1.5 ms on an M1) and not measured on an M1. The
  raster and the writes of 2 M pixels alone are about a third of an M1's budget. The owner has to amend the line or give the sea less to
  do; the work cannot.
