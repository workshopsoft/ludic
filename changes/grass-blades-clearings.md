bump: minor
type: feature
**`ludic.render3d`: the GPU blades keep to the clearings.** `grass_cull.comp` thins every blade by the clearings a
game hands over (`r3d_ground_clearing`, `_area`, `_strip`; a map's `GroundClearings` rows), at each one's floor and
feather, as `ground_clear_at` thins a trampled layer - so the long grass no longer grows through a camp's props, its
logs and crates or a cabin's floor. The list rides to the GPU in a storage buffer of its own (`grass_clear.ludic`),
sent again only when a clearing is put or the list let go, never per frame; the cull tests each clearing's box
first (`tests/grass_clear_test.ludic`). The per-vertex path (`R3D_GRASS_GPU=0`) and the mesh-shader blades do not
read them.
