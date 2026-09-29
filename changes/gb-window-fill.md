bump: patch
type: feature
**The blades' density window can be filled without a GPU.** grass_density.ludic's gb_frame is split: gb_window_fill
fills the GB_TILES x GB_TILES window of density tiles round the camera's (zeros off the map) and sets its corner,
and gb_frame sends it. The same bytes as before; a test reads gb_win after gb_window_fill.
