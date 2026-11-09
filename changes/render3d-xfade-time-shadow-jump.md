bump: patch
type: fix
A scatter layer's near mesh and far card now crossfade over time, not over a 15 m distance band: an instance that crosses the switch
fades in 0.25 s (Unreal's r.LODFadeTime) whether the camera stands still or races past, with 2 m of hysteresis so the edge does not
flicker (R3D_LOD_XFADE_TIME=0 brings the distance band back; R3D_LOD_XFADE_HYST sets the hysteresis). The sun's cached shadow cascades
are drawn again at once when the light turns more than a degree in one frame (a clock jump, the sun handing over to the moon), so a
day's cached shadows no longer show at night (R3D_UE_SHADOW_CACHE_SUN_JUMP=0: the old background rebuild).
