bump: minor
type: feature
**Textures a game baked at build time are read before the PNG.** `png_decode` first takes
`assets/baked/png/<path>.tex` (a game's `ludic bake` output: the samples, ready to upload), and a cut-out
load (`tex_load_ex` with dilate) first takes `assets/baked/cutouts/<path>.bc7` (padded as `tex_dilate`
pads, then BC7 with its mips) - so a boot decodes, pads and converts nothing it can take ready-made. Both
are ludic.base's baked form, read by hand (baked_tex.ludic: the "LBAK" header, the key and version); a
missing or stale one falls back to the PNG as before. `tex_load_dds_at` reads a .dds at an offset.
