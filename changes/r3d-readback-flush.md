bump: patch
type: fix
**A bake reads what was drawn.** `gpu_tex_read_all` (every bake's `bake_pack`) copied a texture on a
submit of its own without submitting the frame's draws first, so it read whatever the image held before
them: the sky bake's BRDF table came out all zeros for one light width and right for another, depending on
whether something else had flushed. It flushes first now, and so does `gpu_tex_write_all`.
