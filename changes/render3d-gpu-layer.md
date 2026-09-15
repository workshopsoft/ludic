bump: minor
type: feat
Vulkan for Ludic, and the start of a second renderer beside OpenGL.

- **`Vk.*`**: every command of Vulkan 1.0-1.4 and of the extensions a modern renderer is
  built around (swapchain, HDR colour spaces, ray query and acceleration structures, opacity
  micromaps, mesh shaders, variable rate shading, memory budget, pipeline libraries, NVIDIA
  low latency, portability for MoltenVK), with every constant and every struct's size
  (`<Struct>_sizeof`) and field offsets (`<Struct>_<field>`). Generated from the Vulkan
  registry by **`ludic-dev vkgen`** into `runtime/native/vk_api.ludic` and `vk_thunks.ll`;
  structs are plain memory filled by name with `Vk.put_i32` / `put_i64` / `put_ptr`. Every
  size and offset was checked against the SDK's C headers (3128 facts). A C float is float
  bits in an int; 64-bit values and non-dispatchable handles are `long`.
- **The loader is opened at run time**, never linked: `vk_win.ll` (`vulkan-1.dll`) and
  `vk_mac.ll` (`libvulkan.1.dylib`, MoltenVK). `Vk.open()` returning 0 means no Vulkan, and
  the program carries on. `ludicc` and `ludic build` link both files for any program that
  uses `Vk.*`.
- `examples/rendering/vk_probe.ludic` reports what a machine's Vulkan can do;
  `vk_compute.ludic` runs a Slang compute shader (`vk_compute.slang`) and reads the picture
  back - on an RTX 3070 Ti and on an M4 Pro through MoltenVK, clean under the validation layer.
- **render3d `gpu.ludic`**: the seam between the renderer and a graphics API. Render state
  and uniforms go through `gpu_*` / `u_*` and nowhere else (OpenGL frames unchanged);
  `R3D_GFX=gl|vk` or `gpu_request` chooses a backend, falling back to OpenGL with a reason;
  `gpu_caps_probe()` detects, on Windows, the Vulkan 1.3 floor, ray tracing, mesh shaders,
  the NVIDIA RTX generation, Reflex and HDR, for a settings screen to grey out what a machine
  cannot use (`R3D_CAPS=rtx50|rtx40|rtx30|amd|intel|none` pretends, for tests).
