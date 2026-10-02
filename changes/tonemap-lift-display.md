bump: patch
type: fix
**`ludic.render3d`: the grade's lift is applied in display space, as its numbers mean.** `tonemap.frag` added
`u_lift * (1 - c)` to the LINEAR colour after ACES, where a lift of 0.025 is a floor of 48/255 once the 2.2
is applied: `daylight_set`'s "blue at noon" shadow floor (`post_lift_b` 0.012 + 0.013) painted every open
shadow blue-grey - shaded grass in Maroon Lake measured (44, 60, 58) at 8:00, the blue channel above the
green. The lift and gain now go on after the 2.2 and the colour returns to linear for the rest of the
chain (saturation, vignette, HDR10), so the same numbers are the few-pixel floor they were written as: the
shade measures (42, 57, 42), dark green. A game that set its own `post_lift_*` sees its shadows' floor drop.
