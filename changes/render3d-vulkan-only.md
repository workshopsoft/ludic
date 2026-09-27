bump: major
type: breaking
**render3d draws with Vulkan only; its OpenGL backend is gone.** `gpu.ludic` keeps its seam -
every `gpu_*` and `u_*` call a renderer or a game makes is unchanged - but each now speaks to the
Vulkan backend alone: no `gl_*` entry point is called from the package, and the GLSL source is
no longer assembled at run time (the same files are still what `ludic-dev shaders` compiles to
SPIR-V). `gpu_request` accepts any name and runs Vulkan; there is no fallback, so a machine whose
Vulkan cannot start is told why (`gpu_fallback_reason`, printed) and `r3d_init` fails.
`gpu_is_gl()` stays, always false, for callers that still ask. The `R3D_GLCHECK` error checks went
with the backend (their messages were built on every call, checked or not). A program that uses
`Vk.*` now also links the runtime's window layer, which still lives with its OpenGL
(`gl_width`, `gl_set_drawable`, ...); separating the two is the runtime's own decision.
