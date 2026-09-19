bump: minor
type: feat
Three things a crown and a hand light were getting wrong.

**An aspen's trunk quaked with its leaves.** `layer_flutter`'s mask was the vertex's
HEIGHT alone — anything more than 1.2 m up trembled — so on a ten metre aspen the whole
bole moved, and a tree that is supposed to shiver read as a column of cloth. What
separates a leaf from a bole is not height, it is distance from the model's own centre
line: the leaves are out at the edge of the crown and the trunk is on the axis. The mask
is radial now, and small plants keep the old one, because a flower is all leaf.

**Foliage in the camera's face.** A third-person camera walks into a crown and the branch
between it and the body is an opaque wall a metre from the lens; in first person it is the
whole screen. `#define NEAR_FADE` dithers tree foliage out inside arm's length of the
camera — in the depth PREPASS, so the lit pass never sees those pixels either and the
equal-depth optimisation is untouched. `gl_Position.w` is the view depth for a perspective
projection, so it costs one varying and no uniform. Blades, cards and flowers are left
alone on purpose: they live at the player's feet, they are always that close, and fading
them opens a hole in the meadow. Nor is the BOLE ever faded: a trunk and its needle cards
are one mesh drawn by one program, so the first cut dissolved the trunk into a dither
pattern as you walked up to it - a solid tree you can see through reads as a fault, where
a branch getting out of your way reads as the camera being polite. The mask is the same
signal the quake uses. The shadow pass keeps every leaf, or a tree would stop shading the
ground it stands on as you walked up to it.

**A hand light had the reach of a candle, whatever it was meant to be.** `handLight`'s
falloff was an inverse square windowed off between 26 and 6 metres, with both numbers
hard-coded: two per cent of its own near field by ten metres out, so carrying a torch at
night lit your boots and nothing else. `daylight_hand` takes a `reach` in metres now and
the falloff is a gentle power out to it — about nine tenths at a metre, half at half the
reach, a tenth at nine tenths of it, nothing past it. A pool of light with a gradient in
it rather than a hotspot with a cliff.
