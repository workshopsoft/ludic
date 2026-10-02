bump: minor
type: feature
**The sun in the sky is drawn where the light comes from.** The sky photograph's own sun disc stands at one
elevation (48 degrees) however the day turns it, so at 19:24 in July the light came from 11 degrees while a bright
glow sat at 48. While a day runs, `sky.frag` now paints the photograph's disc and its glow out (the sky round them
fills it, 4 to 10 degrees from the disc) and draws the real sun instead: a disc and an aureole of the light's own
colour at the real direction (`daylight_set` keeps it in `sky_disc_dir` / `sky_disc_col`, apart from the light, which
is lifted to 3 degrees and handed to the moon at night), cut by the horizon, so a sun that is down draws nothing. A game
that never starts a day sees the photograph as before. The image-based light is unchanged: it is convolved with the
sun clipped, so the disc's energy was never in it, and only the clipped glow (about a tenth of the ambient, soft and
wide) stays where the photograph has it.
