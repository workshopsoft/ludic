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
