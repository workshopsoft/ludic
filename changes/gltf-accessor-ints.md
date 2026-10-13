bump: patch
type: feature
**`ludic.render3d`: `gltf_accessor_ints`.** An accessor's integer components (bytes, shorts or ints, signed or not) as `words`, the way
`gltf_accessor_floats` gives the float ones: a game that builds a physics mesh or a nav ground from a model's triangles reads the
indices with it. A float accessor answers an empty list.
