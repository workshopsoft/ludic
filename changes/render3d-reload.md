bump: minor
type: feat
**ludic.render3d: replace the world at run time** — a game can swap its terrain, scatter, colliders, actors and water for another map's without restarting.

- `terrain_reload(dem, emin, emax, base, ox, oz, ortho, half)` releases the current map's height field, survey, photograph and patch bounds and generates another at any `TERRAIN_HALF`; `terrain_unload()` is the release on its own.
- `scatter_clear_all()` (with `stream_clear_all()`), `actor_clear_all()` and `col_reset()` empty the scene for the next map; `mesh_free()` releases a mesh's GL objects.
- **Water bodies** — `water_body_add(level, cx, cz, ex, ez, reflect)` and `water_bodies_clear()` draw several still-water planes at their own levels; the first that reflects gets the planar reflection. `water_init` still means one reflecting plane.
- **Fix:** the terrain's patch quadtree placed patches at a fixed 32 m leaf, so any `TERRAIN_HALF` other than 4096 put patch bounds in the wrong place; leaves now scale with the map.
- **Fix:** `water_init` built a new mesh and compiled a new program on every call.
- `terrain_sea(level)` separates the sea's level (the coast, the strand, the shoreline, forest and scree shading) from the carved lake's, so a lake can sit above the sea. Unset, the sea is the lake's level as before.
