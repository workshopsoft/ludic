bump: minor
type: fix
**`ludic.render3d`: auto-exposure adapts in seconds, not frames.** The eye's easing was a fixed 0.08 of the way
to the target per frame, so exposure settled in a quarter of the time at 240 Hz that it did at 60. It is now
`1 - exp(-dt / tau)` with `dt` the seconds between two `r3d_frame` clocks (a clock that goes back counts as one
60 Hz frame, a stall is held to half a second), so 30, 60, 144 and 240 Hz settle together. `tau` is 0.2 s as the
scene brightens - exactly the old 0.08 a frame at 60 Hz - and 0.5 s as it darkens, since dark adaptation is the
slow side of the eye (Ferwerda et al. 1996; Pattanaik et al. 2000). `post_adapt_speed(bright, dark)` sets them
(0 is at once). `adapt.frag`'s `u_rate` is a `vec2` of the two shares, made by `post_adapt_rate`.
