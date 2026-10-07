bump: minor
type: feature
**`ludic.render3d`: the fog wall leaves the land.** Past `r3d_fog_wall` nothing that costs is drawn - scatter
layers, streams, actors, shadow cascades and the terrain's pages keep the wall's reach - but the terrain and the
water draw to the camera's far plane under the day's aerial perspective and a share of the wall's haze
(`u_fog_haze`: 0.5 at a 30 m wall, 0.35 at 175 m, 0.2 at a kilometre), so a skyline and its peaks stay in view at
every fog distance. What the wall takes is dissolved by a dither over its last 30 m (six tenths of a nearer wall:
`u_fog_cut`, `fogCut` in lighting.glsl, in model/depth/impostor/kit/oimp/hlod.frag) instead of ending in a line,
and the sky's fog band and thick-fog cover take the same share. A cascade the wall left no layer for now reads lit
(`shadow_cascade_none`) rather than sampling the last layer. New: `fog_land.ludic` (`r3d_fog_land`,
`r3d_fog_land_set`, `r3d_view_far`, `cam_sphere_land`), `cam_sphere_in_view` (the frustum alone);
`R3D_FOG_LAND=0` or `r3d_fog_land_set(false)` is the old wall. Maroon Lake, camp at fog 175 m: mean frame
19.6 -> 20.3 ms (fog off 24.8), terrain pages unchanged (68 slots, 985 KB).
