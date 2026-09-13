bump: patch
type: perf
**Dense forest renders faster** — a depth prepass for the near tree foliage in `ludic.render3d`.

A crown of needle cards is many cut-out quads deep, and a shader that can `discard` turns
early depth rejection off, so every card behind the front one ran the full lighting shader.
In a dense stand at 3840x2160 that made the vegetation pass the largest in the frame. The near
tree LODs now write depth first with `depth.frag` (the same alpha coverage test), the terrain
beneath them is rejected before shading, and the lit pass draws them with no `discard` and an equal depth test. `R3D_NOPREPASS=1` restores the old path for comparison.
