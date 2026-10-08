bump: minor
type: feature
**`ludic.render3d`: a map's own rock, how its air thickens toward dusk, and a thinner wall haze.** The terrain's
rock was dyed one fixed maroon in the shader, so every map had the Bells' mudstone. It is now `ter_rock_r` /
`ter_rock_g` / `ter_rock_b` (`u_rock_tint`: the rock's mean albedo, linear) and `ter_rock_strata`
(`u_rock_strata`: how hard the bedding shows on the steep faces), whose defaults are the old constants, so a
game that sets nothing draws what it drew. The horizon's thickening of the air (`1 + 1.5 * lowsun` in
`daylight_set`) is `day_lowsun_haze`, default 1.5: a high, dry basin sets less and a low sun's veil no longer
buries the alpenglow. The haze the fog wall puts over the land past it falls to 0.05 at a kilometre (was 0.2), so
a wall at 645 m takes about 0.11 of the horizon's colour instead of 0.24: a dark red face two kilometres off
read lilac under it.
