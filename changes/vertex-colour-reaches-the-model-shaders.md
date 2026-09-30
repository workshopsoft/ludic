bump: patch
type: fix
glTF vertex colours (COLOR_0) now reach the model and kit shaders.

The loader ignored COLOR_0, so a model coloured by vertex colour on shared materials (the
studio's generated buildings) drew untextured grey. It now reads vec3 or vec4 COLOR_0, float or
normalized unsigned byte or short, and uploads it as RGBA8 normalized on attribute 7. kit.vert and
model.vert pass it on and kit.frag and model.frag (the plain lit path) multiply it into base
colour, after the material factor and texture, as the glTF spec has it. A mesh without COLOR_0
leaves the input unfed; Vulkan reads that as all zero, which the vertex shaders turn into white,
so nothing allocates per frame and every other mesh draws as before. The scatter arena copies
the colour buffer across LODs. SPIR-V rebuilt with `ludic-dev shaders`. Not yet covered: the
foliage and card paths of model.frag, and the bake passes (bake.frag).

Every vertex shader paired with model.frag now writes every varying it declares (v_col as white,
and v_near and v_lh as neutral values): skin.vert, grass.vert, grass.mesh and grass_inst.vert.
The first attempt wrote v_col only in model.vert and kit.vert, and MoltenVK refused every
pipeline that paired another vertex shader with model.frag. `ludic-dev shaders` (and so
`--check`) now fails when a fragment input has no vertex output at its location.
