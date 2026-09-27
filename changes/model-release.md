bump: minor
type: feature
**A loaded model can be let go of: `model_release(model)`.** Its meshes are freed at once, and
each texture once no other model uses it - the glTF loader shares textures between models (one
path loaded once, a LOD chain borrowing its LOD0's material), so every cached texture now counts
the primitives using it, and the last one frees it and forgets it, with any remembered material
that named it. A game can unload a species' kit or a map's models when nothing of them is left,
and loading one again afterwards is a fresh load. A scatter layer takes room for what it holds
instead of its whole capacity up front (it doubles as it fills, to its cap), which in Maroon Lake
was 0.4 GB of never-filled instance arrays. `examples/rendering/release.ludic` is the check.
