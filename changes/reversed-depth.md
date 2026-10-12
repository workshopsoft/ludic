bump: minor
type: feat
**Reversed depth everywhere.** Every pass draws with Vulkan clip space and reversed depth: D32F, 1 at the
near plane and 0 at the far one, cleared to 0, compared `GREATER`. The camera's far plane is at infinity
(`m4_perspective_rz`, `r3d_proj_far`), unless a fog wall hides the land as well (`R3D_FOG_LAND=0`); then it
clips at the wall's reach, as before. A 5 cm near plane now resolves about 0.07 mm at 1000 m, where it
used to resolve about a metre. Shadow maps compare `GEQUAL` with a negative slope bias. Shaders read
depth through `depthClip(d)` and treat `DEPTH_SKY` (0) as the sky. The SPIR-V wrapper stops remapping depth,
and `kinst_planes` reads near and far in the new clip space; a far plane at infinity gives no plane. The
OpenGL `m4_perspective` and `m4_ortho` are kept for CPU math only.
