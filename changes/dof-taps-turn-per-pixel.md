bump: patch
type: fix
The viewfinder's depth of field no longer draws vertical streaks through grass.

Every pixel gathered its circle of confusion with the same sixteen offsets, so a thin dark blade of
grass was copied sixteen times in one fixed pattern, and a meadow of vertical blades read as vertical
streaks over the whole frame. The spiral of taps is now turned by a different amount at every pixel
(interleaved gradient noise) and has twenty-four taps, so the copies fall as fine grain. Measured on
the meadow of a Maroon Lake viewfinder shot at f/4: horizontal-over-vertical gradient 1.27 -> 1.06, the
column-to-column streak measure 1.64 -> 1.36. SPIR-V rebuilt with `ludic-dev shaders` (only
`dof.frag`'s changed).
