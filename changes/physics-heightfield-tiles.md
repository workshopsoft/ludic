bump: patch
type: feature
**`ludic.physics`: `phys_heightfield_tiles`.** The same ground as `phys_heightfield` cut the way `ludic.render3d`'s terrain mesh cuts it. Jolt splits
a heightfield's cell from (i, j) to (i + 1, j + 1) and the renderer's level 0 from (i + 1, j) to (i, j + 1), so over four samples that are not in one
plane (a bluff, a crest, a quay's edge) the surface a body stands on and the surface that is drawn differ by up to a quarter of the twist (24 cm on a
2 m bluff over 1 m cells). This one lays the samples out a quarter turn round and turns the shape back inside its body, so the surface a ray finds is
the mesh's. Same arguments, same `PHYS_HOLE`s; a game that draws a `TileMap` stands its ground on this.
