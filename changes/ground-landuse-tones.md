bump: minor
type: feat
**Land-use tones on the tile ground.** `tilemap_draw` reads a per-tile 8-bit class mask
(`<tile>.mask.png`, `tmd_mask_pattern`) and a table of up to 8 flat tones (`tmd_tone_set`, or `GroundTone`
rows with `tmd_tones_apply`). The tones are vertex colours averaged over each level's cells, so they add no
shader and no texture. A tile with no mask draws the old tint, and so does a class with no tone.
