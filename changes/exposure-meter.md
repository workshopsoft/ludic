bump: minor
type: feature
**`ludic.render3d`: auto-exposure meters a histogram, favours the centre, and by day stays near the day's light.**
It was the mean of the whole frame (the top of the mip chain), so a frame of shade was metered as if it were open
ground: under a tree the exposure reached 7.0 against 0.83 on the meadow beside it and the shade read as noon.
`adapt.frag` now sorts a 32-cell-wide grid of the frame into log-luminance bins, weighted toward the centre, drops
the darkest 30 % and the brightest 2 % of the weight and averages the rest - Unreal's eye adaptation and Frostbite's
camera (Lagarde & de Rousiers 2014) meter the same way; the band is averaged as light, as the old mean was, since a
log mean raised a dusk frame a stop. By day the result is then held within 3 stops under and 1.5 over the exposure
open ground would get from the sky's light on a level face and the sun's, and the hold fades out toward night: the
tree is now 2.2. `post_metering(lo, hi, centre, below, above)` and `post_metering_open(share)` set it; (0, 1, 0, 16,
16) meters the whole frame's mean as before. `post_key`'s default is 0.28 (the band mean's target; 0.19 was the whole frame's), and the
adaptation's speed is unchanged.
