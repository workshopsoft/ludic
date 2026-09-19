bump: minor
type: feat
The world answers to a body standing in it. `grass_push(x, z, r)` bends every blade
within a radius away from a point and presses it down, so a walker opens a bow wave
through a meadow instead of passing through it; `water_wade(x, z, strength)` puts
spreading rings and a patch of churn into the lake's normals at a point, so a wader
marks the surface and a swimmer disturbs the whole of it. Both are one uniform each
(`u_push`, `u_wade`) read in the vertex and fragment stage that was already running -
no extra pass, no extra draw.
