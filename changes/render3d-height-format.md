bump: patch
type: perf
**The terrain's height field takes half the GPU memory.** The baked height and surface normal
shared one 4096^2 RGBA32F (256 MB); the height now stays alone in its R32F - the same 32 bits
every placement, the CPU read-back and physics read - and the normal goes beside it as x and z in
an RG16F (`ter_normal_tex`, bound as `u_ter_normal`), y rebuilt where it is read: 128 MB. The grass
cull takes it as a third texture (binding 6). In Maroon Lake's play: 2793 -> 2647 MB; the camp's
frame differs in 0.066% of pixels by more than 8, single grass blades at the slope gate.
