bump: minor
type: feat
**render3d takes what a frame draws as callbacks.** A program used to have to define
`scene_draw`, `scene_draw_casters` and `stream_fill` by name - a contract only the linker
enforced, whose shape nothing checked (two examples defined `scene_draw_casters` with no
parameter while the renderer passed one), and one scene per program. It registers them now:
`r3d_on_draw(fn ...)`, `r3d_on_casters(fn ...)`, `r3d_on_stream_fill(fn ...)` (hooks.ludic).
render3d also declares `numbers float` itself, so a program that imports it without the line
still gets a working renderer. The Noise functions check their argument count: a call one
short crashed the compiler, or - where it happened to fit - put fbm2's octaves in its seed.
