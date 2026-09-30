bump: major
type: breaking
**OpenGL is gone from the toolchain; rendering is Vulkan only (MoltenVK on macOS).** The `Gl.*`
namespace and everything behind it are removed: `runtime/native/gl.ludic`, the generated
`gl_api.ludic` (478 entry points, 901 `GL_*` constants), the ABI thunks (`gl_thunks.ll`,
`gl_thunks_win.ll`), the CGL / NSOpenGL / WGL context code (`gl.ll`, `gl_win.ll`, `win32_gl.ll`,
the GL half of `cocoa.ll`), the `ludic-dev glgen` command with `tools/ludic-cli/glgen.ludic`, the
`examples/rendering/gl_triangle.ludic` example, the `Gl` docs section, and the `-framework OpenGL` /
`-lopengl32` link flags. A program that names `Gl.*` no longer compiles.

What the OpenGL runtime carried besides OpenGL stays, under names that say what it is:

- `runtime/native/window.ludic` (was `gl.ludic`), spliced by `Vk.*` and by `Time.now_us` /
  `Time.sleep_us`: `gl_width` / `gl_height` / `gl_pixel_scale` / `gl_set_drawable` /
  `gl_set_pixel_scale` are now `gfx_*`, `gl_set_window` / `gl_toggle_fullscreen` / `gl_set_retina`
  are `gfx_set_window` / `gfx_toggle_fullscreen` / `gfx_set_retina`, and the float-buffer helpers
  `gl_floats`, `gl_bytes_of`, `gl_put`, `gl_get`, `gl_put_bits`, `gl_get_bits`, `gl_ptr`, `gl_f32`,
  `gl_fixed` are `fbuf_*`. The state is `RtWinState` (`rt_win_st`).
- `rtlib.ll` (`rtlib_win.ll` on Windows, was `gl.ll` / `gl_win.ll`): the `f_*`, `mem_*` and
  `fx_to_f32` helpers, and the clock, now `clock_now_us` / `clock_sleep_us` (were `gl_now_us` /
  `gl_sleep_us`). The window's `win_gl_resize` / `win_gl_drawable` / `win_gl_scale` /
  `win_gl_retina` are `win_resize` / `win_drawable` / `win_scale` / `win_retina`
  (`win32_window.ll`, `win_nowin.ll` on Windows). The context-only `win_gl_attach`, `win_gl_swap`,
  `win_gl_swap_interval` and `win_gl_update`, and `gl_vsync`, `gl_open`, `gl_swap`, `gl_screenshot`
  and `gl_resize_check`, are gone.
- render3d's own vocabulary for formats, filters and blend factors, which was the `GL_*` constants,
  is now `GPU_*` in `packages/ludic.render3d/gpu_enums.ludic` (same values): `GL_LINEAR` is
  `GPU_LINEAR`, `GL_RGBA8` is `GPU_RGBA8`, and so on.

`Time.now_us()` and `Time.sleep_us()` no longer need the program to name `Vk.*` or `Gl.*` to link.
The compiler's seeds are regenerated (`g_uses_gl` became `g_uses_win`).
