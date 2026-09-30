bump: patch
type: fix
**ludic.city streaming survives a non-finite position.** `city_stream` and `city_stream_step` with a NaN or infinite point
load and unload nothing (they returned a loop over garbage cell numbers and hung the game); a point 1e30 m away is clamped to a
cell, and `reach` is held to 0..32.
