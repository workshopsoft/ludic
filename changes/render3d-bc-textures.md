bump: minor
type: feature
**A texture with a `.dds` beside its `.png` goes to the GPU BC-compressed, its mips included.**
`tex_load` (and everything built on it: glTF materials, the terrain's materials, ludic.ui's
pictures) looks for `<name>.dds` when the device has `textureCompressionBC` - every desktop GPU,
Apple silicon through MoltenVK too - and uploads its blocks as they are: BC7 (colour in sRGB,
or data read as it is), BC5 or BC4, a quarter of RGBA8 or less in video memory, no decoding and
no mipmapping on the load. Only a DX10 `.dds` carrying the whole chain to 1x1 is taken; anything
else is reported and the `.png` is used, as it is for a cut-out atlas (padded from the `.png`).
`gpu_tex_compressed` and `R3D_BC7` / `R3D_BC7_SRGB` / `R3D_BC5` / `R3D_BC4` are the backend's
entry; `examples/rendering/bc.ludic` is the check, and ludic.lab's plate carries its `.dds`.
