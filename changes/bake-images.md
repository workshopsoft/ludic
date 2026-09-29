bump: minor
type: feature
**Bakes you can look at, and three more of the renderer's textures read from one.** `ludic.lab` writes
raw 8-bit pixels (1 to 4 channels) as a PNG (`lab_png_write`, `png_write.ludic`, importable alone with its
own `LabPngState`) and turns float textures into honest previews (`png_convert.ludic`: R32F min..max as
grey, RG16F as red and green x255, HDR RGBA16F as x/(1+x) then sRGB). `ludic.render3d` takes three bakes
the game names (`bake_load.ludic`) and makes each as before when one is missing or stale: an impostor's
atlases as BC7 with their baked mips, through the compressed upload (`impostor_from_baked`,
`impostor_fill_bc7`; a fog opening past its cards reads the bake again instead of painting), the sky's image-based light at the start yaw per prefilter width (`sky_baked_in`; any other
turn of the sky is convolved), and the grass carpet (`carpet_from_baked`, `carpet_bytes`).
`impostor_from_bytes` returns null, keeping nothing, when the bytes are not the impostor's shape.
