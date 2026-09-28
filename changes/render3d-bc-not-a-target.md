bump: patch
type: fix
**A compressed texture is never drawn into.** On Vulkan, binding a texture to a sampler by name
did not make it the bound texture, as it did on OpenGL, so a following `gpu_tex_param` or
`gpu_tex_mips` acted on whatever was bound last. The water's reflection asked for its mip chain
that way and, once kit textures came as BC7 (23.3), built one into a kit texture: MoltenVK blits
through a render pass, and Metal aborted ("BC7 is not color renderable"). Binding for a sampler
now binds, as OpenGL's did; mip generation leaves a compressed texture alone (its levels came with
it); and a pass that would have a compressed image as a colour attachment leaves it out and says so.
