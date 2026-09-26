bump: minor
type: feature
**render3d's Vulkan renderer runs in a macOS window, through MoltenVK.** `R3D_GFX=vk` (or
`gpu_request("vulkan")`) now presents to a `CAMetalLayer` on the window (`VK_EXT_metal_surface`,
the runtime's `win_metal_layer()`), where it used to fall back to OpenGL. The loader also opens
MoltenVK on its own - `Contents/Frameworks/libMoltenVK.dylib` in a bundle, beside the executable,
or `$VULKAN_SDK/lib` - so a game needs no Vulkan SDK to ship it. A covered window is not drawn to
(its layer would hold every frame for a second), and on macOS one frame stays in flight so the CPU
runs the next tick while the GPU draws. OpenGL stays the default: on an M4 Pro the Vulkan frame is
still about a third slower, most of it in the alpha-tested foliage.
