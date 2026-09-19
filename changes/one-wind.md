bump: minor
type: feat
One wind, and everything in the valley is moved by it.

The grass had a gust built from two sines and the trees had NO gust term at all - just a
per-instance wobble - so the meadow rippled and the canopy above it swayed to an unrelated
rhythm and nothing ever crossed the valley. A real gust is a WAVE: you watch it come over
the grass, it reaches you, and it goes on into the trees behind you.

wind.glsl is prepended to EVERY stage, so the grass's vertex shader, the crown's vertex
shader and the water's fragment shader read the same field at the same world position and
cannot drift apart. No uniforms are declared in it on purpose - u_time and u_wind already
exist in several of those files and redeclaring them is a compile error in whichever stage
includes both - so the caller passes what it already has.

Two numbers mattered. The gust's WAVELENGTH has to fit inside a view or nothing is ever
seen to travel: the first cut was 209 m crest to crest, longer than the meadow you can see,
so the whole frame sat in one phase and read as everything breathing together. It is 74 m
now and a front crosses a normal view in a couple of seconds. And `stiff` lets one field
move a blade a long way and a bole hardly at all.

R3D_DEBUG_WIND=1 paints the field on the ground, which is the only way to SEE a gust in a
still: two shots a moment apart show the fronts and show them moving.

Measured: no cost. 400 frames, GL 6.9 s, VK 7.2 s.
