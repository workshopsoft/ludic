bump: patch
type: fix
Still water reads as water rather than polished metal. The planar reflection is
returned at 0.72 of the scene's own exposure instead of all of it, the fresnel mix
is capped at 0.70 rather than 0.86, and absorption falls from `(0.55, 0.24, 0.14)`
to `(0.34, 0.15, 0.09)` per metre - so the bed is visible through the surface at the
angles a player actually stands at, and a clear lake stops going opaque a metre and a
half down. The ripple field is roughly halved and its normals flattened further
(slope 0.26 -> 0.15), the reflection's ripple nudge halved with it, and the surface
goes flat by 400 m rather than 600, so a sheltered lake is one sheet of water with a
mountain in it instead of open chop to the horizon. Sun glitter and wind-streak foam
come down to match.
