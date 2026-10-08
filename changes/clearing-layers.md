bump: minor
type: feature
**`ludic.render3d`: a clearing thins only the layers it names.** A `GroundClearing` row has `layers` (`"scatter"` for the
layers that are not solid, `"solid"` for trees, rocks, stones and gatherables, `"blades"` for the GPU grass); none named
keeps the old rule, every layer. `ground_clear_for(st, class, x, z)` is the question per class (`ground_clear_at` asks
scatter), `r3d_ground_clearing_only(st, mask)` sets the clearing put last, and `grass_cull.comp` skips a clearing whose
mask leaves the blades out, so a view corridor can open the trees and leave the meadow. A clearing is `GD_CLEAR_W` 11
floats now (the mask is the last).
