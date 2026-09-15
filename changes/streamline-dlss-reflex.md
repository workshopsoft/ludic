bump: minor
type: feat
**NVIDIA DLSS super resolution and Reflex on the Vulkan renderer** — through NVIDIA Streamline 2.14.1.

- **The loader** — on Windows `Vk.open()` takes `sl.interposer.dll` beside the executable in place of
  `vulkan-1.dll` when a program asks (`Vk.sl_prefer`), falling back to plain Vulkan without it; the `sl*`
  exports and feature functions are reachable from Ludic.
- **render3d** — `r3d_dlss(mode)` upscales the lit HDR frame before bloom and the tonemap, jittered on a
  Halton cycle, with preset K in every mode (the default M cost 18 ms a frame at 4K on an RTX 3070 Ti);
  `r3d_dlss_render_w/h` give the size to render at. `r3d_reflex(mode)` sleeps each frame and marks
  simulation, submit and present. `R3D_DLSS`, `R3D_REFLEX`, `R3D_DLSS_PRESET`, `R3D_SL_LOG` for tests.
- **Commands the interposer lacks** — it exports no `vkSetHdrMetadataEXT`, `vkCmdDrawMeshTasksEXT` or
  acceleration-structure command; `Vk.has` checks one and `vkGetDeviceProcAddr` reaches it.
