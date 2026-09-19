bump: minor
type: feat
Rain that leaves something behind.

Rain fell and the ground did not change: the weather was a curtain of particles in front
of a dry valley, and a shower was something you waited out rather than something that
happened to the place.

One scalar, u_wet, 0 dry to 1 soaked, doing the three things a wet surface does. It
darkens the albedo. It drops the roughness hard, which is what makes a soaked meadow read
as SOAKED rather than merely dark - the sky glances off it. And it pools: a wet ground
does not darken evenly, water finds the low places and the flat ground holds what a slope
sheds, so the puddle mask is the macro noise the materials already use gated on slope,
and a puddle takes the world's up for its normal rather than the ground's relief.

It joins the shore's existing wet band rather than fighting it - the same term, from a
different cause.

Measured: 34.1% of the frame changes between dry and soaked, and no cost - GL 7.1 s
either way over 400 frames.
