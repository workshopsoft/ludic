bump: minor
type: feature
**`ludic.render3d`: a grass kind.** The GPU blades' per-kind numbers - the cell, the spacing and its
doubling distance, the reach, the row bands and rows, the blade's profile, heights, tussocks, width and
arch, where it grows (slope, snow line, the photograph's green), its root, tip and gone-to-seed colours,
the far tufts, the root's occlusion, roughness, sheen and wind - are a `GrassKind` record a game hands
over with `grass_kind_set`, not constants in `grass.ludic` and the blade shaders. The defaults are the
old constants, so a game that sets nothing draws what it drew. `grass_quality(s0_min, r_max)` holds a
kind to a settings tier; `grass_profile_w` / `grass_profile_bend` are the one blade profile, for the
meshes and a game's own preview of a kind.
