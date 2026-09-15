bump: patch
type: fix
**The meadow's grass draws on the Vulkan renderer again** — the chunked grass path uploaded its `vec4` tile
table with `u_fv`, which on Vulkan copies one float per array element, so every tile had no blades.
`u_f4v` uploads arrays of `vec4`.
