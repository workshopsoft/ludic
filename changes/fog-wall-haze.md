bump: patch
type: fix
**`ludic.render3d`: the fog wall hides things in the haze of the hour, not in the photograph's horizon.**
`fogWallCol` was the sky photograph prefiltered at roughness 0.6 just above the horizon: half that lobe is a
puresky image's slate lower half and the rest its own clouds, and the prefilter is never relit - so a clear
morning in Maroon Lake drew a dark slate storm on the side away from the photograph's sun (0.11, 0.13, 0.19)
and white milk on the other (0.59, 0.67, 0.80), and the drawn sky turned to the photograph's clouds above
the band. The wall's colour is now the whole sky's light (its mean radiance, the irradiance an upward face
takes) coloured as the drawn sky is at the horizon at this hour (`analyticSky`, by the same `u_sky_relight`),
plus the sun scattered forward as before: the camp's morning wall measures (0.32, 0.38, 0.52). `analyticSky`
and `u_sky_relight` move from `sky.frag` to `lighting.glsl`, and `daylight_bind` binds the relight for every
lit program. A game with no fog wall draws as before.
