bump: minor
type: feat
**More of the renderer's quality is a switch a game can offer.**

- `sky_set_quality(width)`: the prefiltered sky light at 256, 512 or 1024 wide (half as tall),
  baked again at once.
- `post_set_msaa(samples)`: 1, 2 or 4 samples for the scene on OpenGL, remaking the screen targets in
  place (`post_msaa_live()` is false on Vulkan, which has no sample counts yet); `post_free` now
  frees the multisampled framebuffer too.
- `STREAM_BUDGET_US` is a variable: the microseconds a frame may spend generating streamed cover.
- `r3d_fog_scale`: a multiplier over the fog density the daylight and the weather set.
