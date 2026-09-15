bump: minor
type: feat
**Texture filtering and shadow resolution as settings a game can change while it runs.**

- `r3d_set_anisotropy(level)` sets the anisotropic filtering of every mipmapped texture already
  loaded, not only of later uploads, on OpenGL and Vulkan.
- `shadow_set_res(size)` remakes the cascades' depth layers at 1024, 2048 or 4096 (`shadow_res`
  replaces the `SHADOW_RES` constant); the lighting reads the texel size from the map.
