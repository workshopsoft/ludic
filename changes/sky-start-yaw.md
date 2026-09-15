bump: patch
type: perf
**The sky's light is baked once at start, not twice.** A game that turns the sky at boot sets
`sky_start_yaw` before `r3d_init`, and `sky_load` bakes the image-based light at that yaw; turning to
a yaw the light is already baked at (`sky_set_yaw`) no longer bakes it again. Without it, nothing
changes.
