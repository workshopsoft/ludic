bump: minor
type: feature
**`ludic.render3d`: the ground's rock line is the map's, the forest floor is a floor, and a meadow has
forbs.** The terrain went to bare rock by height alone from a fixed 170-300 m of world y; on a map whose
datum puts that in the middle of its spruce-fir (Maroon Lake: 3,130 m), the forest floor was painted with
the maroon rock sheet, whose tiling read as ploughed furrows. It is now `ter_rock_line` / `ter_rock_band`
(`u_rock_line`, `u_rock_band`; defaults 170 and 130, so a game that sets nothing draws what it drew).
Where the photograph says dense conifer the ground is `forestFloor`: needle litter, darker humus and
patches of low green (whortleberry, moss) a few metres across, with the turf sheet's own grain, and the
photograph (a picture of crowns there) weighs a third as much. The meadow's own patches - the blades'
patchiness, dry patches, tussocks and a new swale field (`grass_cull.comp`, `grass.vert` and the ground
alike) - multiply the photograph as well as the ground under it, over their own mean, so they keep their
strength. And a `GrassKind` can carry forbs in flower: `forb_share` of the GPU blades, in patches of
`forb_patch` m, stand upright, `forb_wide` and `forb_tall` of a blade, the top `forb_tip` of each in one
of three colours (`forb_a_*` .. `forb_c_*`); `grass_forbs_bloom` lets the game's season scale the share.
0 (the default) draws none. The cull's Params block grew to 20 vec4s.
