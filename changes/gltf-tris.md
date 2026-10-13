bump: patch
type: feature
**`ludic.render3d`: `gltf_accessor_ints` and `gltf_tris`.** `gltf_accessor_ints` gives an accessor's integer components (bytes, shorts or
ints, signed or not) as `words`, the way `gltf_accessor_floats` gives the float ones. `gltf_tris` reads the triangles of every node a prefix
names into two shared lists (points, and three point numbers a triangle), for a game's physics mesh or nav ground: one scratch serves every
file, a model's own transforms are not applied. Both beside `gltf_points`, which reads the points of a model's convex collision pieces.
