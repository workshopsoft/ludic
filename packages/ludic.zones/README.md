# ludic.zones

Where a world is simulated: a disc per player - `(x, z, r)`, `r = zones_radius(fog)`, that is the
fog distance plus 40 m and never under 150 m, 900 m with no fog - and the discs that overlap merged
into clusters with a bounding circle. Uses `ludic.base` and nothing else.

- `zones_set(pid, x, z, r)`, `zones_clear(pid)`, `zones_reset()`; `zones_merge()` once a frame
  after the discs are set, for the clusters.
- `zones_contains(x, z)`: inside any disc. `zones_nearest(x, z)`: metres to the nearest disc's
  edge, 0 inside. With no disc set, everywhere is inside (0) - a world before its first frame
  freezes nothing.
- `zones_clusters()`, `zones_cluster_x / _z / _r / _n(c)`, `zones_cluster_of(pid)`.

The rules it keeps: fixed arrays of `ZONES_MAX` (16) slots, nothing made after the state; the
questions allocate nothing. A world gates its ticks on `zones_contains` so what is outside every
zone keeps its state and draws no dice.
