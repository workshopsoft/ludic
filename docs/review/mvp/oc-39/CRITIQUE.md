# Sea surface (render3d, gpp lab fixture `sea`)

Shots: `coast_pairs_*.png` (six coast bookmarks, noon | dusk), `before_after.png` (old plane | sea), `noon_*.png`, `dusk_horizon.png`.
Measured: `sea_check.txt` (25 checks, 0 failed), `gpu_time.txt`. Reproduce: `packages/ludic.render3d/lab/sea_lab.ludic`, then
`lab/sea_check.py build/lab`.

What reads well
- The shore: a white swash line at the waterline, lace out to a metre of depth, nothing beyond; it follows a meandering 4 % beach,
  a cliff, a quay wall, a rock, a shoal and a river mouth, and stops dead at the dry platform and the dock (no foam, no water).
- The sea is one calm colour that deepens with depth and is the same over the map's edge as over its bed (no edge in the
  shoal shot); the horizon is a clean line with no step in the rows under it, from the map's corner as well.
- A river mesh meeting the sea at one height wins every pixel (planes sit a hair behind): no fight in the mouth.

What does not, and why it is left
- Swells show as regular streaks at middle distance in the noon shots (the long ones, 71 and 29 m). They are flat to the horizon and
  fade before they can crawl, but a 71 m swell seen at a 10 degree angle is a stripe. A swell texture with a longer period would
  hide it; the budget below is the reason it was not done here.
- The lab's ground is one tint per land-use class and blurs at the edges (the lab's own render path); judge the water, not the sand.
- Foam is paler than the lit sand by little in the tone-mapped frame (the sand is already bright); its texture, not its
  brightness, separates it (the measured check uses that).
- Cost: the water pass is 1.1 ms at the beach, 0.85 at the horizon and 1.4 ms with the sea filling the frame, on an M4 Pro
  (about a third of the old plane's). The contract's 1.0 ms is for an M1, about 3 times slower than this machine: NOT MET and not
  measured on an M1. Where it goes (open sea, ms): swell normals 0.4, fog 0.35, sky reflection 0.2, shadow tap 0.1, fixed
  (scene mips, raster, mask) 0.2, the rest small.
